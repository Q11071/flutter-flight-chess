import 'dart:math';

class Dice {
  int _value = 1;
  int _targetValue = 1;
  bool _isRolling = false;
  final Random _random = Random();

  int get value => _value;
  int get targetValue => _targetValue;
  bool get isRolling => _isRolling;
  bool get isSix => _value == 6;

  /// 开始滚动动画，预计算最终值
  void startRolling() {
    _isRolling = true;
    _targetValue = _random.nextInt(6) + 1;
  }

  /// 完成滚动，返回最终值
  int finishRoll() {
    _value = _targetValue;
    _isRolling = false;
    return _value;
  }

  String get displayFace {
    const faces = ['⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];
    return faces[_value - 1];
  }
}