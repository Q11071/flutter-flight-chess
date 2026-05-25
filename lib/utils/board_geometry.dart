import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../models/piece.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';

/// 棋盘坐标几何计算工具类
///
/// 坐标系: (x, y)，原点左上角，x向右，y向下，15x15网格
/// 跑道: 52格顺时针，红P0 蓝P13 黄P26 绿P39
///
/// 跑道路径 (顺时针):
///   底边(6,14)→(14,14) → 右下角(14,13),(14,12) →
///   右边(14,11)→(14,4) → 右上角(13,4),(12,4) →
///   顶边(11,0)→(3,0) → 左上角(3,1),(3,2) →
///   左边(3,3)→(3,10) → 左下角(4,10),(5,10) → 回到(6,14)
class BoardGeometry {
  BoardGeometry._();

  // ===========================================================================
  // 公共跑道 52 格坐标 (顺时针)
  // ===========================================================================

  static const List<(int x, int y)> track = [
    // ---- 底边 (x=6→14, y=14) ----
    (6, 14),  // P0  红方起点
    (7, 14),  // P1
    (8, 14),  // P2
    (9, 14),  // P3
    (10, 14), // P4
    (11, 14), // P5
    (12, 14), // P6
    (13, 14), // P7
    (14, 14), // P8
    // ---- 右下转角 ----
    (14, 13), // P9
    (14, 12), // P10
    // ---- 右边 (y=11→4, x=14) ----
    (14, 11), // P11
    (14, 10), // P12 蓝方冲刺入口
    (14, 9),  // P13 蓝方起点
    (14, 8),  // P14
    (14, 7),  // P15
    (14, 6),  // P16
    (14, 5),  // P17
    (14, 4),  // P18
    // ---- 右上转角 ----
    (13, 4),  // P19
    (12, 4),  // P20
    // ---- 顶边 (x=11→3, y=0) ----
    (11, 0),  // P21
    (10, 0),  // P22
    (9, 0),   // P23
    (8, 0),   // P24
    (7, 0),   // P25 黄方冲刺入口
    (6, 0),   // P26 黄方起点
    (5, 0),   // P27
    (4, 0),   // P28
    (3, 0),   // P29
    // ---- 左上转角 ----
    (3, 1),   // P30
    (3, 2),   // P31
    // ---- 左边 (y=3→10, x=3) ----
    (3, 3),   // P32
    (3, 4),   // P33
    (3, 5),   // P34
    (3, 6),   // P35
    (3, 7),   // P36
    (3, 8),   // P37 绿方冲刺入口
    (3, 9),   // P38 绿方起点
    (3, 10),  // P39
    // ---- 左下转角 ----
    (4, 10),  // P40
    (5, 10),  // P41
    // ---- 底边 (x=6→14, y=14) 回到起点 ----
    (6, 14),  // P42 (=P0)
    (7, 14),  // P43 (=P1)
    (8, 14),  // P44 (=P2)
    (9, 14),  // P45 (=P3)
    (10, 14), // P46 (=P4)
    (11, 14), // P47 (=P5)
    (12, 14), // P48 (=P6)
    (13, 14), // P49 (=P7) 红方冲刺入口
    (14, 14), // P50 (=P8)
    (14, 13), // P51 (=P9)
  ];

  // ===========================================================================
  // 冲刺入口 (进入冲刺道前的跑道位置)
  // ===========================================================================
  // 红: P51 (14,13) → 冲刺道向左 (x=13→8, y=7)
  // 蓝: P12 (14,10) → 冲刺道向上 (x=7, y=13→8)
  // 黄: P25 (7,0) → 冲刺道向右 (x=1→6, y=7)
  // 绿: P38 (3,8) → 冲刺道向下 (x=7, y=1→6)

  static const Map<PlayerColor, int> homeEntryTrackIndex = {
    PlayerColor.red: 51,
    PlayerColor.blue: 12,
    PlayerColor.yellow: 25,
    PlayerColor.green: 38,
  };

  // ===========================================================================
  // 机库位置 (2x2 排列)
  // ===========================================================================
  // 黄=左上(0-4,0-4)  绿=右上(10-14,0-4)
  // 蓝=左下(0-4,10-14) 红=右下(10-14,10-14)

  static const Map<PlayerColor, List<(int, int)>> _hangarPositions = {
    PlayerColor.yellow: [(1, 1), (2, 1), (1, 2), (2, 2)],
    PlayerColor.green:  [(11, 1), (12, 1), (11, 2), (12, 2)],
    PlayerColor.blue:   [(1, 11), (2, 11), (1, 12), (2, 12)],
    PlayerColor.red:    [(11, 11), (12, 11), (11, 12), (12, 12)],
  };

  static List<(int, int)> getHangarPositions(PlayerColor color) {
    return _hangarPositions[color]!;
  }

  // ===========================================================================
  // 冲刺道位置 (6 格，从外围向中心)
  // ===========================================================================
  // 红: (13,7)→(8,7) 向左   蓝: (7,13)→(7,8) 向上
  // 黄: (1,7)→(6,7) 向右    绿: (7,1)→(7,6) 向下

  static const Map<PlayerColor, List<(int, int)>> _homeStretchPositions = {
    PlayerColor.red:    [(13, 7), (12, 7), (11, 7), (10, 7), (9, 7), (8, 7)],
    PlayerColor.blue:   [(7, 13), (7, 12), (7, 11), (7, 10), (7, 9), (7, 8)],
    PlayerColor.yellow: [(1, 7), (2, 7), (3, 7), (4, 7), (5, 7), (6, 7)],
    PlayerColor.green:  [(7, 1), (7, 2), (7, 3), (7, 4), (7, 5), (7, 6)],
  };

  static List<(int, int)> getHomeStretchPositions(PlayerColor color) {
    return _homeStretchPositions[color]!;
  }

  // ===========================================================================
  // 坐标转换
  // ===========================================================================

  /// 逻辑网格坐标 (x,y) → 像素坐标
  static (double, double) gridToPixel(int x, int y) {
    final px = x * AppDimensions.cellSize + AppDimensions.cellSize / 2;
    final py = y * AppDimensions.cellSize + AppDimensions.cellSize / 2;
    return (px, py);
  }

  /// 棋子状态 → 像素坐标
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
        return gridToPixel(7, 7);
    }
  }

  /// 玩家颜色 → Flutter Color
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

  static (int, int) getTrackPosition(int index) {
    return track[index % track.length];
  }

  static bool isStartPosition(int trackIndex) {
    for (final entry in GameConfig.startPositions.entries) {
      if (entry.value == trackIndex) return true;
    }
    return false;
  }

  static bool isHomeEntryPosition(int trackIndex) {
    for (final entry in homeEntryTrackIndex.entries) {
      if (entry.value == trackIndex) return true;
    }
    return false;
  }

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
