import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';
import '../models/game_config.dart';
import '../constants/colors.dart';
import '../widgets/board/board_canvas.dart';
import '../widgets/board/piece_widget.dart';
import '../widgets/controls/action_panel.dart';
import '../utils/board_geometry.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('飞行棋'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('重新开始'),
                  content: const Text('确定要重新开始游戏吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<GameStateProvider>().restartGame();
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<GameStateProvider>(
        builder: (context, gameState, child) {
          return Column(
            children: [
              _buildPlayerBar(gameState),
              Expanded(
                child: Center(
                  child: _buildBoard(context, gameState),
                ),
              ),
              ActionPanel(gameState: gameState),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayerBar(GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: gameState.players.map((player) {
          final color = BoardGeometry.getPlayerColor(player.color);
          final isCurrent = player == gameState.currentPlayer;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrent ? color.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isCurrent ? Border.all(color: color, width: 2) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  player.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? color : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${player.finishedCount}/${player.pieces.length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBoard(BuildContext context, GameStateProvider gameState) {
    final screenSize = MediaQuery.of(context).size;
    final availH = screenSize.height - 200;
    final side = screenSize.width < availH ? screenSize.width * 0.9 : availH * 0.85;
    final squareSize = Size(side, side);

    return Stack(
      children: [
        BoardCanvas(boardSize: squareSize),
        ..._buildAllPieces(gameState, squareSize),
        if (gameState.phase == GamePhase.gameOver)
          _buildGameOverOverlay(context, gameState, squareSize),
      ],
    );
  }

  List<Widget> _buildAllPieces(GameStateProvider gameState, Size boardSize) {
    List<Widget> pieces = [];
    for (var player in gameState.players) {
      for (var piece in player.pieces) {
        pieces.add(
          PieceWidget(
            piece: piece,
            boardSize: boardSize,
            isMovable: gameState.movablePieces.contains(piece),
            onTap: gameState.movablePieces.contains(piece)
                ? () => gameState.selectPiece(piece)
                : null,
          ),
        );
      }
    }
    return pieces;
  }

  Widget _buildGameOverOverlay(BuildContext context, GameStateProvider gameState, Size boardSize) {
    return Container(
      width: boardSize.width,
      height: boardSize.height,
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  '${gameState.winner?.name ?? ""} 获胜！',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('共 ${gameState.turnCount} 回合', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => gameState.restartGame(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: const Text('再来一局'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('返回主菜单'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
