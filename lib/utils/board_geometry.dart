import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../models/piece.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';

/// 棋盘坐标几何计算工具类
///
/// 坐标系：(x, y)，原点左上角，x向右，y向下，15x15网格
/// 跑道：52格顺时针，红P0 蓝P13 黄P26 绿P39
class BoardGeometry {
  BoardGeometry._();

  // ===========================================================================
  // 公共跑道 52 格坐标 (顺时针)
  // ===========================================================================
  //
  // 上边(左→右) → 右上折角 → 右边(上→下) → 右下折角 →
  // 下边(右→左) → 左下折角 → 左边(下→上) → 左上折角

  static const List<(int x, int y)> track = [
    // ---- 上边 (左→右) ----
    (6, 0),  // P0  红方起点
    (7, 0),  // P1
    (8, 0),  // P2
    (9, 0),  // P3
    (10, 0), // P4
    (11, 0), // P5
    (12, 0), // P6
    // ---- 右上折角 ----
    (13, 1), // P7
    (14, 2), // P8
    // ---- 右边 (上→下) ----
    (14, 3), // P9
    (14, 4), // P10
    (14, 5), // P11
    (14, 6), // P12
    (14, 7), // P13 蓝方起点
    (14, 8), // P14
    // ---- 右下折角 ----
    (13, 9), // P15
    (12, 10),// P16
    // ---- 下边 (右→左) ----
    (11, 10),// P17
    (10, 10),// P18
    (9, 10), // P19
    (8, 10), // P20
    (7, 10), // P21
    (6, 10), // P22
    // ---- 左下折角 ----
    (5, 13), // P23
    (4, 12), // P24
    // ---- 左边 (下→上) ----
    (0, 11), // P25
    (0, 10), // P26 黄方起点
    (0, 9),  // P27
    (0, 8),  // P28
    (0, 7),  // P29
    (0, 6),  // P30
    (0, 5),  // P31
    // ---- 左上折角 ----
    (1, 4),  // P32
    (2, 3),  // P33
    // ---- 上边回到起点 ----
    (3, 0),  // P34
    (4, 0),  // P35
    (5, 0),  // P36
    (6, 0),  // P37 (同P0)
    (7, 0),  // P38 (同P1) - 绿方起点区域
    (8, 0),  // P39 绿方起点
    // ---- 继续上边 ----
    (9, 0),  // P40
    (10, 0), // P41
    (11, 0), // P42
    (12, 0), // P43
    (13, 1), // P44
    (14, 2), // P45
    (14, 3), // P46
    (14, 4), // P47
    (14, 5), // P48
    (14, 6), // P49
    (14, 7), // P50
    (14, 8), // P51
  ];

  // ===========================================================================
  // 冲刺入口对应的公共跑道索引
  // ===========================================================================
  //
  // 每个颜色在进入起点前一格转入冲刺道
  // 红: P51 (14,8) → 冲刺道沿 y=7 向左
  // 蓝: P12 (14,6) → 冲刺道沿 x=7 向上
  // 黄: P25 (0,11) → 冲刺道沿 y=7 向右
  // 绿: P38 (8,0) → 冲刺道沿 x=7 向下

  static const Map<PlayerColor, int> homeEntryTrackIndex = {
    PlayerColor.red: 51,
    PlayerColor.blue: 12,
    PlayerColor.yellow: 25,
    PlayerColor.green: 38,
  };

  // ===========================================================================
  // 机库位置 (2x2 排列)
  // ===========================================================================
  //
  // 右下(11-14,11-14)=红  左下(0-3,11-14)=蓝
  // 右上(11-14,0-3)=绿    左上(0-3,0-3)=黄

  // 机库位置避免与跑道重叠
  static const Map<PlayerColor, List<(int, int)>> _hangarPositions = {
    PlayerColor.red:    [(12, 12), (13, 12), (12, 13), (13, 13)],
    PlayerColor.blue:   [(1, 12), (2, 12), (1, 13), (2, 13)],
    PlayerColor.yellow: [(1, 1), (2, 1), (1, 2), (2, 2)],
    PlayerColor.green:  [(11, 1), (12, 1), (11, 2), (12, 2)],
  };

  /// 返回某颜色玩家的 4 个机库位置。
  static List<(int, int)> getHangarPositions(PlayerColor color) {
    return _hangarPositions[color]!;
  }

  // ===========================================================================
  // 冲刺道位置 (6 格，从外围向中心)
  // ===========================================================================
  //
  // 红: (8,7)→(1,7) 向左
  // 蓝: (7,8)→(7,1) 向上
  // 黄: (6,7)→(13,7) 向右
  // 绿: (7,6)→(7,13) 向下

  static const Map<PlayerColor, List<(int, int)>> _homeStretchPositions = {
    PlayerColor.red:    [(8, 7), (7, 7), (6, 7), (5, 7), (4, 7), (3, 7)],
    PlayerColor.blue:   [(7, 8), (7, 7), (7, 6), (7, 5), (7, 4), (7, 3)],
    PlayerColor.yellow: [(6, 7), (7, 7), (8, 7), (9, 7), (10, 7), (11, 7)],
    PlayerColor.green:  [(7, 6), (7, 7), (7, 8), (7, 9), (7, 10), (7, 11)],
  };

  /// 返回某颜色玩家的 6 个冲刺道位置。
  static List<(int, int)> getHomeStretchPositions(PlayerColor color) {
    return _homeStretchPositions[color]!;
  }

  // ===========================================================================
  // 逻辑坐标 → 像素坐标
  // ===========================================================================

  /// 将逻辑网格坐标 (x, y) 转换为像素坐标。
  static (double, double) gridToPixel(int x, int y) {
    final double px = x * AppDimensions.cellSize + AppDimensions.cellSize / 2;
    final double py = y * AppDimensions.cellSize + AppDimensions.cellSize / 2;
    return (px, py);
  }

  /// 根据棋子状态和位置，计算其在棋盘上的像素坐标。
  static (double, double) modelToPixel(Piece piece) {
    switch (piece.state) {
      case PieceState.hangar:
        final positions = getHangarPositions(piece.color);
        final (x, y) = positions[piece.index % positions.length];
        return gridToPixel(x, y);

      case PieceState.track:
        final (x, y) = track[piece.position % track.length];
        return gridToPixel(x, y);

      case PieceState.homeStretch:
        final positions = getHomeStretchPositions(piece.color);
        final idx = piece.position.clamp(0, positions.length - 1);
        final (x, y) = positions[idx];
        return gridToPixel(x, y);

      case PieceState.finished:
        // 终点是中心 (7,7)
        return gridToPixel(7, 7);
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

  /// 判断指定跑道索引是否为某颜色的冲刺入口。
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
