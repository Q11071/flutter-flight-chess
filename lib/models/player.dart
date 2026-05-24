import 'game_config.dart';
import 'piece.dart';

class Player {
  final PlayerColor color;
  final String name;
  final bool isAI;
  final List<Piece> pieces;

  Player({
    required this.color,
    required this.name,
    this.isAI = false,
  }) : pieces = List.generate(
    GameConfig.piecesPerPlayer,
    (i) => Piece(id: '${color.name}_$i', color: color, index: i),
  );

  bool get allFinished => pieces.every((p) => p.state == PieceState.finished);
  int get finishedCount => pieces.where((p) => p.state == PieceState.finished).length;
  int get hangarCount => pieces.where((p) => p.state == PieceState.hangar).length;
  int get onTrackCount => pieces.where((p) => p.state == PieceState.track).length;
  int get onHomeStretchCount => pieces.where((p) => p.state == PieceState.homeStretch).length;

  @override
  String toString() => 'Player($name, finished: $finishedCount/${pieces.length})';
}
