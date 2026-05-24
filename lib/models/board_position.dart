import 'game_config.dart';

enum CellType {
  normal,
  start,
  homeEntry,
  homeStretch,
  finish,
  hangar,
}

class BoardCell {
  final int trackIndex;
  final PlayerColor? color;
  final CellType type;
  final int row;
  final int col;

  const BoardCell({
    required this.trackIndex,
    this.color,
    this.type = CellType.normal,
    required this.row,
    required this.col,
  });

  bool get isSafe => type == CellType.start || type == CellType.homeEntry;
}
