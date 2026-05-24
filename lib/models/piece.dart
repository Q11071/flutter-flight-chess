import 'game_config.dart';

class Piece {
  final String id;
  final PlayerColor color;
  final int index;

  PieceState state;
  int position;
  bool isSelected;

  Piece({
    required this.id,
    required this.color,
    required this.index,
    this.state = PieceState.hangar,
    this.position = -1,
    this.isSelected = false,
  });

  bool get canMove => state != PieceState.finished;
  bool get isInHangar => state == PieceState.hangar;
  bool get isOnTrack => state == PieceState.track;
  bool get isOnHomeStretch => state == PieceState.homeStretch;
  bool get isFinished => state == PieceState.finished;

  Piece copy() => Piece(
    id: id,
    color: color,
    index: index,
    state: state,
    position: position,
    isSelected: isSelected,
  );

  @override
  String toString() => 'Piece($id, state: $state, pos: $position)';
}
