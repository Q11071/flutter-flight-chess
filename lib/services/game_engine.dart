import '../models/game_config.dart';
import '../models/piece.dart';
import '../models/player.dart';
import 'path_service.dart';
import 'collision_service.dart';

class GameEngine {
  final PathService _pathService = PathService();
  final CollisionService _collisionService = CollisionService();

  PathService get pathService => _pathService;
  CollisionService get collisionService => _collisionService;

  /// 获取可移动的棋子列表
  List<Piece> getMovablePieces(Player player, int diceValue) {
    List<Piece> movable = [];
    for (var piece in player.pieces) {
      if (piece.state == PieceState.finished) continue;

      if (piece.state == PieceState.hangar) {
        // 在机库中，只有掷6才能起飞
        if (diceValue == GameConfig.takeOffRoll) {
          movable.add(piece);
        }
      } else {
        // 检查移动后是否超出冲刺道
        if (_pathService.canMove(piece, diceValue, player.color)) {
          movable.add(piece);
        }
      }
    }
    return movable;
  }

  /// 执行移动，返回移动后的碰撞棋子列表
  Future<List<Piece>> movePiece(Piece piece, int steps, List<Player> allPlayers, Function onStep) async {
    List<Piece> collidedPieces = [];

    // 起飞（掷6后棋子直接放到起点，不额外跳格）
    if (piece.state == PieceState.hangar) {
      piece.state = PieceState.track;
      piece.position = GameConfig.startPositions[piece.color]!;
      onStep();
      await Future.delayed(const Duration(milliseconds: 300));

      // 检查碰撞
      collidedPieces = _collisionService.checkCollision(piece, allPlayers);
      return collidedPieces;
    }

    // 逐格移动 (动画)
    for (int i = 0; i < steps; i++) {
      final result = _pathService.getNextPosition(piece);
      piece.position = result.$1;
      if (result.$2 != null) piece.state = result.$2!;
      onStep();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // 移动完成后检查是否触发跳格
    if (piece.state == PieceState.track && _pathService.isColorCellForPlayer(piece.position, piece.color)) {
      // 落在颜色格上，额外跳跃4格
      for (int j = 0; j < 4; j++) {
        final result = _pathService.getNextPosition(piece);
        piece.position = result.$1;
        if (result.$2 != null) piece.state = result.$2!;
        onStep();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    // 移动完成后检查碰撞
    collidedPieces = _collisionService.checkCollision(piece, allPlayers);
    return collidedPieces;
  }

  /// 检查是否有玩家获胜
  Player? checkWinner(List<Player> players) {
    for (var player in players) {
      if (player.allFinished) return player;
    }
    return null;
  }

  /// 处理连续掷6的惩罚（3次连续掷6，最远的棋子回机库）
  void handleTripleSixPenalty(Player player) {
    // 找到跑道上最远的棋子
    Piece? farthestPiece;
    int maxPos = -1;

    for (var piece in player.pieces) {
      if (piece.state == PieceState.track && piece.position > maxPos) {
        maxPos = piece.position;
        farthestPiece = piece;
      }
    }

    if (farthestPiece != null) {
      farthestPiece.state = PieceState.hangar;
      farthestPiece.position = -1;
    }
  }

  /// AI 选择要移动的棋子
  Piece? aiSelectPiece(Player player, int diceValue, List<Player> allPlayers) {
    List<Piece> movable = getMovablePieces(player, diceValue);
    if (movable.isEmpty) return null;

    // 策略1: 有机库中的飞机且掷到6，优先起飞
    if (diceValue == GameConfig.takeOffRoll) {
      Piece? hangarPiece = movable.firstWhere(
        (p) => p.state == PieceState.hangar,
        orElse: () => movable.first,
      );
      if (hangarPiece.state == PieceState.hangar) return hangarPiece;
    }

    // 策略2: 有撞机机会时优先选择撞机
    for (var piece in movable) {
      if (piece.state == PieceState.track) {
        int targetPos = (piece.position + diceValue) % GameConfig.trackLength;
        for (var player in allPlayers) {
          if (player.color == piece.color) continue;
          for (var other in player.pieces) {
            if (other.state == PieceState.track && other.position == targetPos) {
              return piece; // 有撞机机会
            }
          }
        }
      }
    }

    // 策略3: 冲刺道中的飞机优先移动
    Piece? homeStretchPiece = movable.firstWhere(
      (p) => p.state == PieceState.homeStretch,
      orElse: () => movable.first,
    );
    if (homeStretchPiece.state == PieceState.homeStretch) return homeStretchPiece;

    // 策略4: 优先移动最前面的飞机
    movable.sort((a, b) {
      if (a.state == PieceState.track && b.state == PieceState.track) {
        return b.position.compareTo(a.position);
      }
      return 0;
    });

    return movable.first;
  }
}
