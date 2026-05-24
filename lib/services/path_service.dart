import '../models/game_config.dart';
import '../models/piece.dart';

class PathService {
  /// 获取棋子下一步位置
  /// 返回 (新位置, 新状态)
  (int, PieceState?) getNextPosition(Piece piece) {
    if (piece.state == PieceState.track) {
      int next = (piece.position + 1) % GameConfig.trackLength;

      // 检查是否到达冲刺入口
      int homeEntry = getHomeEntryIndex(piece.color);
      if (next == homeEntry) {
        return (0, PieceState.homeStretch);
      }
      return (next, null);
    }

    if (piece.state == PieceState.homeStretch) {
      int next = piece.position + 1;
      if (next >= GameConfig.homeStretchLength) {
        return (GameConfig.homeStretchLength - 1, PieceState.finished);
      }
      return (next, null);
    }

    return (piece.position, null);
  }

  /// 判断棋子是否可以移动指定步数
  bool canMove(Piece piece, int steps, PlayerColor color) {
    if (piece.state == PieceState.hangar) {
      return steps == GameConfig.takeOffRoll;
    }
    if (piece.state == PieceState.homeStretch) {
      return piece.position + steps < GameConfig.homeStretchLength;
    }
    if (piece.state == PieceState.track) {
      // 检查移动过程中是否会经过冲刺入口
      int homeEntry = getHomeEntryIndex(color);
      int current = piece.position;
      for (int i = 0; i < steps; i++) {
        current = (current + 1) % GameConfig.trackLength;
        if (current == homeEntry) {
          // 进入冲刺道，剩余步数走冲刺道
          int remainingSteps = steps - i - 1;
          return remainingSteps < GameConfig.homeStretchLength;
        }
      }
      return true;
    }
    return false;
  }

  /// 获取某颜色玩家的冲刺入口在公共跑道上的索引
  int getHomeEntryIndex(PlayerColor color) {
    return GameConfig.homeStretchEntries[color]!;
  }

  /// 计算移动N步后的位置（不执行动画，纯计算）
  (PieceState, int) getPositionAfterSteps(Piece piece, int steps) {
    if (piece.state == PieceState.hangar) {
      return (PieceState.track, GameConfig.startPositions[piece.color]!);
    }

    int current = piece.position;
    PieceState state = piece.state;

    for (int i = 0; i < steps; i++) {
      if (state == PieceState.track) {
        int next = (current + 1) % GameConfig.trackLength;
        int homeEntry = getHomeEntryIndex(piece.color);
        if (next == homeEntry) {
          state = PieceState.homeStretch;
          current = 0;
        } else {
          current = next;
        }
      } else if (state == PieceState.homeStretch) {
        int next = current + 1;
        if (next >= GameConfig.homeStretchLength) {
          return (PieceState.finished, GameConfig.homeStretchLength - 1);
        }
        current = next;
      }
    }

    return (state, current);
  }

  /// 获取从当前位置到冲刺入口还有多少步（在公共跑道上时）
  int stepsToHomeEntry(Piece piece) {
    if (piece.state != PieceState.track) return -1;
    int homeEntry = getHomeEntryIndex(piece.color);
    int current = piece.position;
    int steps = 0;
    while (current != homeEntry) {
      current = (current + 1) % GameConfig.trackLength;
      steps++;
    }
    return steps;
  }
}
