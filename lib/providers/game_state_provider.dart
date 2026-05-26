import 'package:flutter/foundation.dart';
import '../models/game_config.dart';
import '../models/piece.dart';
import '../models/player.dart';
import '../models/dice.dart';
import '../services/game_engine.dart';

class GameStateProvider extends ChangeNotifier {
  final GameEngine _engine = GameEngine();

  List<Player> players = [];
  int currentPlayerIndex = 0;
  GamePhase phase = GamePhase.waitingForRoll;
  GameMode gameMode = GameMode.pvp;
  Dice dice = Dice();
  int consecutiveSixes = 0;
  Piece? lastMovedPiece;
  List<Piece> movablePieces = [];
  Player? winner;
  int turnCount = 0;
  String statusMessage = '';
  List<Piece> collidedPieces = [];

  Player get currentPlayer => players[currentPlayerIndex];
  GameEngine get engine => _engine;

  /// 初始化游戏
  void startGame(GameMode mode, int playerCount) {
    gameMode = mode;
    players = [];
    for (int i = 0; i < playerCount; i++) {
      PlayerColor color = PlayerColor.values[i];
      String name = GameConfig.colorNames[color]!;
      bool isAI = mode == GameMode.pvai && i > 0;
      players.add(Player(color: color, name: name, isAI: isAI));
    }
    currentPlayerIndex = 0;
    phase = GamePhase.waitingForRoll;
    consecutiveSixes = 0;
    lastMovedPiece = null;
    movablePieces = [];
    winner = null;
    turnCount = 0;
    statusMessage = '${currentPlayer.name} 的回合，请掷骰子';
    collidedPieces = [];
    notifyListeners();
  }

  /// 掷骰子
  void rollDice() async {
    if (phase != GamePhase.waitingForRoll) return;

    phase = GamePhase.rolling;
    notifyListeners();

    // 开始骰子滚动动画
    dice.startRolling();
    notifyListeners();

    // 等待滚动动画完成 (1200ms)
    await Future.delayed(const Duration(milliseconds: 1200));

    // 完成滚动，获取最终值
    final value = dice.finishRoll();

    // 处理连续掷6
    if (value == 6) {
      consecutiveSixes++;
      if (consecutiveSixes >= 3) {
        // 三次连续掷6，惩罚
        _engine.handleTripleSixPenalty(currentPlayer);
        statusMessage = '${currentPlayer.name} 连续掷了3个6！最远的飞机回机库';
        consecutiveSixes = 0;
        _nextTurn();
        notifyListeners();
        return;
      }
    } else {
      consecutiveSixes = 0;
    }

    notifyListeners();

    // 等待一下让玩家看到结果
    await Future.delayed(const Duration(milliseconds: 500));

    // 计算可移动棋子
    movablePieces = _engine.getMovablePieces(currentPlayer, value);

    if (movablePieces.isEmpty) {
      statusMessage = '${currentPlayer.name} 掷了 $value，无棋子可动';
      await Future.delayed(const Duration(milliseconds: 800));
      _nextTurn();
    } else if (movablePieces.length == 1) {
      // 只有一个可移动，自动移动
      phase = GamePhase.waitingForAction;
      statusMessage = '${currentPlayer.name} 掷了 $value';
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
      selectPiece(movablePieces.first);
      return;
    } else {
      phase = GamePhase.waitingForAction;
      if (currentPlayer.isAI) {
        // AI有多个选择，让AI自动选择
        statusMessage = '${currentPlayer.name} (AI) 掷了 $value，正在思考...';
        notifyListeners();
        // AI选择将在延迟后处理
        await Future.delayed(const Duration(milliseconds: 1500));
        _aiSelectAndMove();
      } else {
        statusMessage = '${currentPlayer.name} 掷了 $value，请选择要移动的飞机';
      }
    }

    notifyListeners();
  }

  /// 选择棋子移动
  void selectPiece(Piece piece) {
    if (phase != GamePhase.waitingForAction) return;

    phase = GamePhase.moving;
    lastMovedPiece = piece;
    notifyListeners();

    _executeMove(piece);
  }

  Future<void> _executeMove(Piece piece) async {
    List<Piece> collided = await _engine.movePiece(
      piece,
      dice.value,
      players,
      () => notifyListeners(),
    );

    collidedPieces = collided;
    if (collided.isNotEmpty) {
      statusMessage = '撞机！${collided.length} 架飞机被撞回机库';
    }

    // 检查胜利
    winner = _engine.checkWinner(players);
    if (winner != null) {
      phase = GamePhase.gameOver;
      statusMessage = '${winner!.name} 获胜！';
      notifyListeners();
      return;
    }

    // 决定是否额外掷骰
    if (dice.isSix) {
      phase = GamePhase.waitingForRoll;
      statusMessage = '${currentPlayer.name} 掷了6，可以再掷一次！';

      // 如果是AI，自动再掷
      if (currentPlayer.isAI) {
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 1500));
        rollDice();
      }
    } else {
      _nextTurn();
    }

    notifyListeners();
  }

  void _nextTurn() {
    consecutiveSixes = 0;
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    turnCount++;
    phase = GamePhase.waitingForRoll;
    movablePieces = [];
    lastMovedPiece = null;
    collidedPieces = [];
    statusMessage = '${currentPlayer.name} 的回合，请掷骰子';

    // 如果下一个是 AI，自动执行
    if (currentPlayer.isAI && gameMode == GameMode.pvai) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        _aiTurn();
      });
    }
  }

  void _aiTurn() {
    if (!currentPlayer.isAI) return;
    if (phase != GamePhase.waitingForRoll) return;

    rollDice();
  }

  void _aiSelectAndMove() {
    if (!currentPlayer.isAI) return;
    if (phase != GamePhase.waitingForAction) return;
    if (movablePieces.isEmpty) return;

    Piece? selected = _engine.aiSelectPiece(currentPlayer, dice.value, players);
    if (selected != null) {
      selectPiece(selected);
    }
  }

  /// 重新开始游戏
  void restartGame() {
    startGame(gameMode, players.length);
  }
}
