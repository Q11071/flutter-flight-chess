import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../models/piece.dart';
import '../constants/colors.dart';

class BoardGeometry {
  /// 公共跑道52个格子的 (row, col) 坐标
  /// 红方起始(0)在(6,13)，逆时针排列
  static const List<List<int>> trackGrid = [
    // 红方: 0~12 (从右下方向上走)
    [6, 13], [5, 13], [4, 13], [3, 13], [2, 13], [1, 13], [0, 13], // 0~6
    [0, 12], [0, 11], // 7~8
    // 黄方起始区域: 9~13
    [1, 11], [2, 11], [3, 11], [4, 11], [5, 11], // 9~13 (黄方起始=13)
    // 黄方: 14~25 (从右向左下走)
    [6, 11], [7, 11], [8, 11], [9, 11], [10, 11], [11, 11], // 14~19
    [12, 11], [12, 12], [12, 13], // 20~22
    [12, 14], [11, 14], [10, 14], // 23~25
    // 蓝方起始区域: 26~38
    [9, 14], [8, 14], [7, 14], [6, 14], [5, 14], [4, 14], [3, 14], [2, 14], [1, 14], [0, 14], // 26~35
    [0, 13], [0, 12], [0, 11], // 36~38
    // 绿方起始区域: 39~51
    [1, 10], [2, 10], [3, 10], [4, 10], [5, 10], [6, 10], // 39~44
    [7, 10], [8, 10], [9, 10], [10, 10], [11, 10], [12, 10], // 45~50
    [12, 9], // 51
  ];

  /// 机库位置 (2x2排列)
  static const Map<PlayerColor, List<List<int>>> hangarGrid = {
    PlayerColor.red: [[10, 1], [10, 2], [11, 1], [11, 2]],
    PlayerColor.yellow: [[10, 12], [10, 13], [11, 12], [11, 13]],
    PlayerColor.blue: [[1, 12], [1, 13], [2, 12], [2, 13]],
    PlayerColor.green: [[1, 1], [1, 2], [2, 1], [2, 2]],
  };

  /// 冲刺道位置 (6格，从外向中心)
  static const Map<PlayerColor, List<List<int>>> homeStretchGrid = {
    PlayerColor.red: [[6, 12], [6, 11], [6, 10], [6, 9], [6, 8], [6, 7]],
    PlayerColor.yellow: [[12, 8], [11, 8], [10, 8], [9, 8], [8, 8], [7, 8]],
    PlayerColor.blue: [[8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7]],
    PlayerColor.green: [[2, 6], [3, 6], [4, 6], [5, 6], [6, 6], [7, 6]],
  };

  /// 终点位置 (中心)
  static const List<int> finishGrid = [7, 7];

  /// 逻辑坐标转像素坐标
  static Offset gridToPixel(int row, int col, Size boardSize) {
    double cellW = boardSize.width / 15;
    double cellH = boardSize.height / 15;
    return Offset(col * cellW + cellW / 2, row * cellH + cellH / 2);
  }

  /// 获取公共跑道上某格的像素坐标
  static Offset getTrackPosition(int trackIndex, Size boardSize) {
    final grid = trackGrid[trackIndex];
    return gridToPixel(grid[0], grid[1], boardSize);
  }

  /// 获取机库位置的像素坐标
  static Offset getHangarPosition(PlayerColor color, int pieceIndex, Size boardSize) {
    final grid = hangarGrid[color]![pieceIndex];
    return gridToPixel(grid[0], grid[1], boardSize);
  }

  /// 获取冲刺道位置的像素坐标
  static Offset getHomeStretchPosition(PlayerColor color, int position, Size boardSize) {
    final grid = homeStretchGrid[color]![position];
    return gridToPixel(grid[0], grid[1], boardSize);
  }

  /// 获取终点像素坐标
  static Offset getFinishPosition(Size boardSize) {
    return gridToPixel(finishGrid[0], finishGrid[1], boardSize);
  }

  /// 根据棋子状态计算像素坐标
  static Offset modelToPixel(Piece piece, Size boardSize) {
    switch (piece.state) {
      case PieceState.hangar:
        return getHangarPosition(piece.color, piece.index, boardSize);
      case PieceState.track:
        return getTrackPosition(piece.position, boardSize);
      case PieceState.homeStretch:
        return getHomeStretchPosition(piece.color, piece.position, boardSize);
      case PieceState.finished:
        return getFinishPosition(boardSize);
    }
  }

  /// 获取玩家对应的 Flutter Color
  static Color getPlayerColor(PlayerColor color) {
    switch (color) {
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
}
