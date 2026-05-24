import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../models/piece.dart';
import '../constants/dimensions.dart';
import '../constants/colors.dart';

/// 棋盘坐标几何计算工具类
///
/// 飞行棋棋盘是十字形，划分为 15x15 的逻辑网格（行列索引 0~14）。
/// 公共跑道 52 格从红方起始格逆时针排列。
class BoardGeometry {
  BoardGeometry._();

  // ===========================================================================
  // 公共跑道 52 格坐标 (逆时针)
  // ===========================================================================

  /// 52 格跑道坐标列表，索引 0~51。
  ///
  /// 布局说明：
  /// - 红方区域 0~12：从 (6,13) 向上到 (0,13)，再向左到 (0,7)
  /// - 黄方区域 13~25：从 (13,8) 向左到 (13,2)，再向上到 (7,2)
  /// - 蓝方区域 26~38：从 (8,1) 向下到 (14,1)，再向右到 (14,7)
  /// - 绿方区域 39~51：从 (1,6) 向右到 (1,12)，再向下到 (7,12)
  static const List<(int row, int col)> track = [
    // ---- 红方 0~12：右侧 arm 向上，顶部向左 ----
    (6, 13), // 0  红方起始格
    (5, 13), // 1
    (4, 13), // 2
    (3, 13), // 3
    (2, 13), // 4
    (1, 13), // 5
    (0, 13), // 6
    (0, 12), // 7
    (0, 11), // 8
    (0, 10), // 9
    (0, 9),  // 10
    (0, 8),  // 11
    (0, 7),  // 12

    // ---- 黄方 13~25：底部向左，左侧 arm 向上 ----
    (13, 8), // 13 黄方起始格
    (13, 7), // 14
    (13, 6), // 15
    (13, 5), // 16
    (13, 4), // 17
    (13, 3), // 18
    (13, 2), // 19
    (12, 2), // 20
    (11, 2), // 21
    (10, 2), // 22
    (9, 2),  // 23
    (8, 2),  // 24
    (7, 2),  // 25

    // ---- 蓝方 26~38：左侧 arm 向下，底部向右 ----
    (8, 1),  // 26 蓝方起始格
    (9, 1),  // 27
    (10, 1), // 28
    (11, 1), // 29
    (12, 1), // 30
    (13, 1), // 31
    (14, 1), // 32
    (14, 2), // 33
    (14, 3), // 34
    (14, 4), // 35
    (14, 5), // 36
    (14, 6), // 37
    (14, 7), // 38

    // ---- 绿方 39~51：顶部向右，右侧 arm 向下 ----
    (1, 6),  // 39 绿方起始格
    (1, 7),  // 40
    (1, 8),  // 41
    (1, 9),  // 42
    (1, 10), // 43
    (1, 11), // 44
    (1, 12), // 45
    (2, 12), // 46
    (3, 12), // 47
    (4, 12), // 48
    (5, 12), // 49
    (6, 12), // 50 红方冲刺入口邻接
    (7, 12), // 51
  ];

  // ===========================================================================
  // 机库位置 (2x2 排列，共 4 个位置)
  // ===========================================================================

  static const Map<PlayerColor, List<(int, int)>> _hangarPositions = {
    PlayerColor.red:    [(11, 1), (11, 2), (12, 1), (12, 2)],
    PlayerColor.yellow: [(11, 12), (11, 13), (12, 12), (12, 13)],
    PlayerColor.blue:   [(1, 12), (1, 13), (2, 12), (2, 13)],
    PlayerColor.green:  [(1, 1), (1, 2), (2, 1), (2, 2)],
  };

  /// 返回某颜色玩家的 4 个机库位置。
  static List<(int, int)> getHangarPositions(PlayerColor color) {
    return _hangarPositions[color]!;
  }

  // ===========================================================================
  // 冲刺道位置 (6 格，从入口向中心)
  // ===========================================================================

  static const Map<PlayerColor, List<(int, int)>> _homeStretchPositions = {
    PlayerColor.red:    [(6, 12), (6, 11), (6, 10), (6, 9), (6, 8), (6, 7)],
    PlayerColor.yellow: [(12, 8), (11, 8), (10, 8), (9, 8), (8, 8), (7, 8)],
    PlayerColor.blue:   [(8, 2), (8, 3), (8, 4), (8, 5), (8, 6), (8, 7)],
    PlayerColor.green:  [(2, 6), (3, 6), (4, 6), (5, 6), (6, 6), (7, 6)],
  };

  /// 返回某颜色玩家的 6 个冲刺道位置。
  static List<(int, int)> getHomeStretchPositions(PlayerColor color) {
    return _homeStretchPositions[color]!;
  }

  // ===========================================================================
  // 冲刺入口对应的公共跑道索引
  // ===========================================================================

  /// 各颜色冲刺入口在公共跑道上的索引。
  /// 当棋子到达该索引时，下一步可转入冲刺道。
  static const Map<PlayerColor, int> homeEntryTrackIndex = {
    PlayerColor.red: 50,
    PlayerColor.yellow: 11,
    PlayerColor.blue: 24,
    PlayerColor.green: 37,
  };

  // ===========================================================================
  // 逻辑坐标 → 像素坐标
  // ===========================================================================

  /// 将逻辑网格坐标 (row, col) 转换为像素坐标。
  ///
  /// 返回 (x, y) 像素位置，原点为棋盘左上角（不含 padding）。
  static (double, double) gridToPixel(int row, int col) {
    final double x = col * AppDimensions.cellSize + AppDimensions.cellSize / 2;
    final double y = row * AppDimensions.cellSize + AppDimensions.cellSize / 2;
    return (x, y);
  }

  /// 根据棋子状态和位置，计算其在棋盘上的像素坐标。
  ///
  /// - [hangarSlot]：棋子在机库中的序号（0~3），仅 hangar 状态时使用。
  static (double, double) modelToPixel(Piece piece, {int hangarSlot = 0}) {
    switch (piece.state) {
      case PieceState.hangar:
        final positions = getHangarPositions(piece.color);
        final (row, col) = positions[hangarSlot % positions.length];
        return gridToPixel(row, col);

      case PieceState.track:
        final (row, col) = track[piece.position % track.length];
        return gridToPixel(row, col);

      case PieceState.homeStretch:
        final positions = getHomeStretchPositions(piece.color);
        final idx = piece.position.clamp(0, positions.length - 1);
        final (row, col) = positions[idx];
        return gridToPixel(row, col);

      case PieceState.finished:
        final positions = getHomeStretchPositions(piece.color);
        final (row, col) = positions.last;
        return gridToPixel(row, col);
    }
  }

  // ===========================================================================
  // 颜色映射
  // ===========================================================================

  /// 获取玩家颜色对应的 Flutter [Color]。
  static Color getPlayerColor(PlayerColor playerColor) {
    switch (playerColor) {
      case PlayerColor.red:
        return AppColors.red;
      case PlayerColor.yellow:
        return AppColors.yellow;
      case PlayerColor.blue:
        return AppColors.blue;
      case PlayerColor.green:
        return AppColors.green;
    }
  }

  // ===========================================================================
  // 辅助方法
  // ===========================================================================

  /// 获取公共跑道上指定索引的网格坐标。
  static (int, int) getTrackPosition(int index) {
    return track[index % track.length];
  }

  /// 判断指定跑道索引是否为某颜色的起始格。
  static bool isStartPosition(int trackIndex) {
    for (final entry in GameConfig.startPositions.entries) {
      if (entry.value == trackIndex) return true;
    }
    return false;
  }

  /// 判断指定跑道索引是否为某颜色的冲刺入口邻接格。
  static bool isHomeEntryPosition(int trackIndex) {
    for (final entry in homeEntryTrackIndex.entries) {
      if (entry.value == trackIndex) return true;
    }
    return false;
  }

  /// 获取指定跑道索引对应的颜色（如果是起始格或冲刺入口）。
  static PlayerColor? getPositionColor(int trackIndex) {
    for (final entry in GameConfig.startPositions.entries) {
      if (entry.value == trackIndex) return entry.key;
    }
    for (final entry in homeEntryTrackIndex.entries) {
      if (entry.value == trackIndex) return entry.key;
    }
    return null;
  }
}
