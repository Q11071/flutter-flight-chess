/// 四种颜色对应四个玩家
enum PlayerColor { red, yellow, blue, green }

/// 棋子状态
enum PieceState {
  hangar,       // 待在机库 (未起飞)
  track,        // 在公共跑道上
  homeStretch,  // 在自家冲刺跑道上
  finished,     // 已到达终点
}

/// 游戏阶段
enum GamePhase {
  waitingForRoll,    // 等待掷骰
  rolling,           // 掷骰动画中
  waitingForAction,  // 等待玩家选择操作
  moving,            // 棋子移动动画中
  resolving,         // 解析碰撞/特殊事件
  gameOver,          // 游戏结束
}

/// 游戏模式
enum GameMode { pvp, pvai, localMulti }

class GameConfig {
  static const int maxPlayers = 4;
  static const int piecesPerPlayer = 4;
  static const int trackLength = 52;
  static const int homeStretchLength = 6;
  static const int takeOffRoll = 6;

  // 红方起点 (公共跑道索引)
  static const Map<PlayerColor, int> startPositions = {
    PlayerColor.red: 0,
    PlayerColor.yellow: 13,
    PlayerColor.blue: 26,
    PlayerColor.green: 39,
  };

  // 各家冲刺跑道入口 (公共跑道索引)
  static const Map<PlayerColor, int> homeStretchEntries = {
    PlayerColor.red: 50,
    PlayerColor.yellow: 11,
    PlayerColor.blue: 24,
    PlayerColor.green: 37,
  };

  // 玩家颜色对应的 Flutter Color
  static const Map<PlayerColor, String> colorNames = {
    PlayerColor.red: '红方',
    PlayerColor.yellow: '黄方',
    PlayerColor.blue: '蓝方',
    PlayerColor.green: '绿方',
  };
}
