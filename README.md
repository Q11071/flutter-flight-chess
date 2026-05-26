# 飞行棋 / Flutter Flight Chess

[![Flutter](https://img.shields.io/badge/Flutter-3.12+-02569B?logo=flutter)]()
[![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)]()

一款基于 Flutter 开发的经典飞行棋游戏，支持人机对战和本地多人模式。

## 游戏截图

![棋盘截图](./board_screenshot.png)

## 游戏规则

### 基本规则

- **起飞：** 掷出 6 点时，可以将机库中的飞机放置到起点
- **移动：** 掷出几点，飞机就向前移动几格
- **跳格：** 落在己方颜色格上时，额外跳跃 4 格
- **撞机：** 飞机落在对方飞机位置时，将对方飞机撞回机库
- **冲刺：** 飞机绕跑道一圈后进入冲刺道，到达终点即完成
- **再掷：** 掷出 6 点可以再掷一次，连续掷出 3 个 6 则最远的飞机回机库

### 游戏模式

| 模式 | 说明 |
|------|------|
| PVP | 双人对战，轮流掷骰 |
| PVE | 人机对战，与 AI 对战 |
| 本地多人 | 本地多人轮流游戏 |

### 棋盘布局

```
        ┌─────────────────────────────────────┐
        │ 蓝机库    │  上臂跑道  │  绿机库   │
        │───────────┼────────────┼───────────│
        │ 左臂跑道  │   中心     │ 右臂跑道  │
        │───────────┼────────────┼───────────│
        │ 红机库    │  下臂跑道  │  黄机库   │
        └─────────────────────────────────────┘
```

- 公共跑道共 52 格，顺时针分布
- 每方冲刺道 6 格，向中心延伸
- 颜色格：起点、起点+4、起点+8

## 快速开始

### 环境要求

- Flutter SDK >= 3.12.0
- Dart SDK >= 3.12.0

### 安装运行

```bash
# 克隆项目
git clone https://github.com/Q11071/flutter-flight-chess.git

# 进入项目目录
cd flutter-flight-chess

# 安装依赖
flutter pub get

# 运行应用（Windows）
flutter run -d windows

# 运行应用（Web）
flutter run -d chrome
```

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── constants/                # 常量定义
│   ├── colors.dart           # 颜色常量
│   └── dimensions.dart       # 尺寸常量
├── models/                   # 数据模型
│   ├── dice.dart             # 骰子模型
│   ├── game_config.dart      # 游戏配置
│   ├── piece.dart            # 棋子模型
│   └── player.dart           # 玩家模型
├── providers/                # 状态管理
│   └── game_state_provider.dart
├── screens/                  # 页面
│   ├── game_screen.dart      # 游戏主页面
│   └── home_screen.dart      # 主菜单页面
├── services/                 # 业务服务
│   ├── game_engine.dart      # 游戏引擎
│   ├── path_service.dart     # 路径计算
│   └── collision_service.dart # 碰撞检测
├── utils/                    # 工具类
│   └── board_geometry.dart   # 棋盘几何计算
└── widgets/                  # UI 组件
    ├── board/                # 棋盘组件
    ├── controls/             # 控制组件
    └── dice/                 # 骰子组件
```

## 技术栈

- **框架：** Flutter 3.12+
- **状态管理：** Provider
- **音效：** audioplayers
- **数据持久化：** shared_preferences

## 开发

```bash
# 运行测试
flutter test

# 代码分析
flutter analyze

# 构建 Windows 应用
flutter build windows

# 构建 Web 应用
flutter build web
```

## 许可证

[MIT](./LICENSE)
