import 'package:flutter/material.dart';
import '../../providers/game_state_provider.dart';
import '../../models/game_config.dart';
import '../../constants/colors.dart';
import '../../utils/board_geometry.dart';
import '../dice/dice_widget.dart';

class ActionPanel extends StatelessWidget {
  final GameStateProvider gameState;

  const ActionPanel({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 状态消息
          Text(
            gameState.statusMessage,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // 当前玩家和骰子
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 当前玩家指示
              _buildPlayerIndicator(),
              // 骰子
              DiceWidget(
                value: gameState.dice.value,
                targetValue: gameState.dice.targetValue,
                isRolling: gameState.phase == GamePhase.rolling,
                onRoll: gameState.phase == GamePhase.waitingForRoll && !gameState.currentPlayer.isAI
                    ? () => gameState.rollDice()
                    : null,
              ),
              // 回合信息
              _buildTurnInfo(),
            ],
          ),

          // 可移动棋子选择（仅人类玩家显示）
          if (gameState.phase == GamePhase.waitingForAction &&
              gameState.movablePieces.length > 1 &&
              !gameState.currentPlayer.isAI)
            _buildPieceSelector(),
        ],
      ),
    );
  }

  Widget _buildPlayerIndicator() {
    final color = BoardGeometry.getPlayerColor(gameState.currentPlayer.color);
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          gameState.currentPlayer.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTurnInfo() {
    return Column(
      children: [
        Text(
          '回合 ${gameState.turnCount}',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        if (gameState.dice.isSix)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '再掷一次！',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPieceSelector() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        children: gameState.movablePieces.map((piece) {
          final color = BoardGeometry.getPlayerColor(piece.color);
          return ElevatedButton.icon(
            onPressed: () => gameState.selectPiece(piece),
            icon: const Icon(Icons.airplanemode_active, size: 18),
            label: Text('飞机 ${piece.index + 1}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}
