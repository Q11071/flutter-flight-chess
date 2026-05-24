import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';

class DiceWidget extends StatelessWidget {
  final int value;
  final bool isRolling;
  final VoidCallback? onRoll;

  const DiceWidget({
    super.key,
    required this.value,
    this.isRolling = false,
    this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRoll,
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
          child: isRolling
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : Text(
                  _getDiceFace(value),
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
