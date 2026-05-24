import '../models/game_config.dart';
import '../models/piece.dart';
import '../utils/board_geometry.dart';

/// 路径计算服务
///
/// 负责计算棋子在公共跑道和冲刺道上的移动逻辑。
/// 飞行棋规则：
/// - 公共跑道循环 0~51
/// - 到达自家冲刺入口索引时，下一步进入冲刺道
/// - 冲刺道不能超出，超出则不能移动
/// - 到达冲刺道第 6 格（index 5 的下一步）即为 finished
class PathService {
  // ===========================================================================
  // 公共 API
  // ===========================================================================

  /// 获取某颜色玩家冲刺入口的公共跑道索引。
  int getHomeEntryIndex(PlayerColor color) {
    return BoardGeometry.homeEntryTrackIndex[color]!;
  }

  /// 判断棋子是否可以移动 [steps] 步。
  ///
  /// 返回 `true` 表示移动合法，`false` 表示会超出冲刺道或状态不允许。
  bool canMove(Piece piece, int steps, PlayerColor color) {
    if (piece.state == PieceState.finished) return false;
    if (piece.state == PieceState.hangar) {
      return steps == GameConfig.takeOffRoll;
    }

    if (piece.state == PieceState.homeStretch) {
      // 在冲刺道上：position + steps 必须 <= homeStretchLength
      // position 0~5 有效，6 表示 finished
      return piece.position + steps <= GameConfig.homeStretchLength;
    }

    if (piece.state == PieceState.track) {
      // 在公共跑道上：模拟移动，检查进入冲刺道后是否超出
      int current = piece.position;
      PieceState state = PieceState.track;
      for (int i = 0; i < steps; i++) {
        if (state == PieceState.track) {
          int next = (current + 1) % GameConfig.trackLength;
          int homeEntry = getHomeEntryIndex(color);
          if (current == homeEntry) {
            // 当前在冲刺入口，下一步进入冲刺道
            state = PieceState.homeStretch;
            current = 0;
          } else {
            current = next;
          }
        } else if (state == PieceState.homeStretch) {
          int next = current + 1;
          if (next > GameConfig.homeStretchLength) {
            return false; // 超出冲刺道
          }
          current = next;
        }
      }
      return true;
    }

    return false;
  }

  /// 返回棋子的下一步位置和状态。
  ///
  /// 返回 `(newPosition, newState)` 元组。
  /// - `newPosition`：新的位置索引
  /// - `newState`：新的状态（如果发生变化，否则为 null）
  (int, PieceState?) getNextPosition(Piece piece) {
    switch (piece.state) {
      case PieceState.hangar:
        // 在机库中不能自动移动，需要掷6起飞
        return (piece.position, null);

      case PieceState.track:
        return _getNextTrackPosition(piece);

      case PieceState.homeStretch:
        return _getNextHomeStretchPosition(piece);

      case PieceState.finished:
        return (piece.position, null);
    }
  }

  /// 计算棋子移动 [steps] 步后的位置和状态。
  ///
  /// 如果移动不合法（超出冲刺道），返回 `null`。
  (int, PieceState)? getPositionAfterSteps(Piece piece, int steps) {
    if (!canMove(piece, steps, piece.color)) return null;

    if (piece.state == PieceState.hangar) {
      // 起飞到起始格
      return (GameConfig.startPositions[piece.color]!, PieceState.track);
    }

    int currentPos = piece.position;
    PieceState currentState = piece.state;

    for (int i = 0; i < steps; i++) {
      final tempPiece = Piece(
        id: piece.id,
        color: piece.color,
        index: piece.index,
        state: currentState,
        position: currentPos,
      );
      final (newPos, newState) = getNextPosition(tempPiece);
      currentPos = newPos;
      if (newState != null) currentState = newState;
    }

    return (currentPos, currentState);
  }

  /// 获取从当前位置到冲刺入口还有多少步（仅在公共跑道上有效）。
  /// 返回 -1 表示不在公共跑道上。
  int stepsToHomeEntry(Piece piece) {
    if (piece.state != PieceState.track) return -1;
    int homeEntry = getHomeEntryIndex(piece.color);
    int current = piece.position;
    int steps = 0;
    while (current != homeEntry) {
      current = (current + 1) % GameConfig.trackLength;
      steps++;
      if (steps > GameConfig.trackLength) return -1; // 防止死循环
    }
    return steps;
  }

  // ===========================================================================
  // 内部方法
  // ===========================================================================

  /// 计算公共跑道上的下一个位置。
  (int, PieceState?) _getNextTrackPosition(Piece piece) {
    final color = piece.color;
    final entryIndex = getHomeEntryIndex(color);

    // 当前在冲刺入口，下一步进入冲刺道第 0 格
    if (piece.position == entryIndex) {
      return (0, PieceState.homeStretch);
    }

    // 正常前进一格（循环）
    final nextPos = (piece.position + 1) % GameConfig.trackLength;
    return (nextPos, null);
  }

  /// 计算冲刺道上的下一个位置。
  (int, PieceState?) _getNextHomeStretchPosition(Piece piece) {
    final nextPos = piece.position + 1;

    if (nextPos >= GameConfig.homeStretchLength) {
      // 到达终点
      return (GameConfig.homeStretchLength, PieceState.finished);
    }

    return (nextPos, null);
  }
}
