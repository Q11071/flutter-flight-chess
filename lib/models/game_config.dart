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

  // 各颜色起点 (跑道索引)
  // 红P0(6,14) 蓝P13(14,9) 黄P26(6,0) 绿P39(3,10)
  static const Map<PlayerColor, int> startPositions = {
    PlayerColor.red: 0,
    PlayerColor.blue: 13,
    PlayerColor.yellow: 26,
    PlayerColor.green: 39,
  };

  // 各颜色冲刺入口 (跑道索引，到达后下一步进入冲刺道)
  // 红P51(14,13) 蓝P12(14,10) 黄P25(7,0) 绿P38(3,8)
  static const Map<PlayerColor, int> homeStretchEntries = {
    PlayerColor.red: 51,
    PlayerColor.blue: 12,
    PlayerColor.yellow: 25,
    PlayerColor.green: 38,
  };

  // 玩家颜色对应的 Flutter Color
  static const Map<PlayerColor, String> colorNames = {
    PlayerColor.red: '红方',
    PlayerColor.yellow: '黄方',
    PlayerColor.blue: '蓝方',
    PlayerColor.green: '绿方',
  };
}
