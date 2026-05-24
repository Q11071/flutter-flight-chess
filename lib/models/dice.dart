import 'dart:math';

class Dice {
  int _value = 1;
  bool _isRolling = false;
  final Random _random = Random();

  int get value => _value;
  bool get isRolling => _isRolling;
  bool get isSix => _value == 6;

  int roll() {
    _isRolling = true;
    _value = _random.nextInt(6) + 1;
    _isRolling = false;
    return _value;
  }

  String get displayFace {
    const faces = ['⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];
    return faces[_value - 1];
  }
}
