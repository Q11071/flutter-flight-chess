import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';

class DiceWidget extends StatefulWidget {
  final int value;
  final int targetValue;
  final bool isRolling;
  final VoidCallback? onRoll;

  const DiceWidget({
    super.key,
    required this.value,
    this.targetValue = 1,
    this.isRolling = false,
    this.onRoll,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _displayValue = 1;
  int _lastStep = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _displayValue = widget.value;
  }

  @override
  void didUpdateWidget(DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _startRollingAnimation();
    } else if (!widget.isRolling && oldWidget.isRolling) {
      _displayValue = widget.value;
      _controller.stop();
    }
  }

  void _startRollingAnimation() {
    _controller.reset();
    _lastStep = -1;
    _controller.addListener(() {
      final progress = _controller.value;
      if (progress >= 0.75) {
        // 最后25%：显示目标值（减速着陆效果）
        _displayValue = widget.targetValue;
      } else {
        // 前75%：快速循环
        final elapsedMs = (progress * 1200).toInt();
        final currentStep = elapsedMs ~/ 100;
        if (currentStep != _lastStep) {
          _lastStep = currentStep;
          _displayValue = (_displayValue % 6) + 1;
        }
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onRoll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: AppDimensions.diceSize,
        height: AppDimensions.diceSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: widget.isRolling
              ? AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * 2 * 3.14159,
                      child: Text(
                        _getDiceFace(_displayValue),
                        style: const TextStyle(fontSize: 36),
                      ),
                    );
                  },
                )
              : Text(
                  _getDiceFace(widget.value),
                  style: const TextStyle(fontSize: 36),
                ),
        ),
      ),
    );
  }

  String _getDiceFace(int value) {
    const faces = ['⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];
    if (value >= 1 && value <= 6) return faces[value - 1];
    return '⚀';
  }
}