import '../models/game_config.dart';
import '../models/piece.dart';
import '../models/player.dart';

class CollisionService {
  /// 检查移动后的棋子是否与其他玩家的棋子发生碰撞
  /// 返回被撞回机库的棋子列表
  List<Piece> checkCollision(Piece movedPiece, List<Player> allPlayers) {
    if (movedPiece.state != PieceState.track) return [];

    List<Piece> collidedPieces = [];

    for (var player in allPlayers) {
      if (player.color == movedPiece.color) continue;
      for (var other in player.pieces) {
        if (other.state != PieceState.track) continue;
        if (other.position == movedPiece.position) {
          // 撞机！被撞的飞机回机库
          other.state = PieceState.hangar;
          other.position = -1;
          collidedPieces.add(other);
        }
      }
    }

    return collidedPieces;
  }

  /// 检查同色棋子是否在同一位置（叠飞）
  List<Piece> getStackedPieces(Piece piece, List<Player> allPlayers) {
    if (piece.state != PieceState.track) return [];

    Player? owner;
    for (var player in allPlayers) {
      if (player.color == piece.color) {
        owner = player;
        break;
      }
    }
    if (owner == null) return [];

    return owner.pieces.where((p) =>
      p != piece &&
      p.state == PieceState.track &&
      p.position == piece.position
    ).toList();
  }

  /// 检查某个位置是否安全（起飞格、冲刺入口）
  bool isSafePosition(int trackIndex) {
    // 起飞格
    for (var entry in GameConfig.startPositions.entries) {
      if (entry.value == trackIndex) return true;
    }
    // 冲刺入口
    for (var entry in GameConfig.homeStretchEntries.entries) {
      if (entry.value == trackIndex) return true;
    }
    return false;
  }
}
