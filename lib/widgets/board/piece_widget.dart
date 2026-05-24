import 'package:flutter/material.dart';
import '../../models/piece.dart';
import '../../utils/board_geometry.dart';
import '../../constants/dimensions.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final Size boardSize;
  final bool isMovable;
  final VoidCallback? onTap;

  const PieceWidget({
    super.key,
    required this.piece,
    required this.boardSize,
    this.isMovable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (px, py) = BoardGeometry.modelToPixel(piece);
    // 将逻辑像素坐标按 boardSize 缩放到实际渲染尺寸
    final scale = boardSize.width / (15 * AppDimensions.cellSize);
    final position = Offset(px * scale, py * scale);
    final color = BoardGeometry.getPlayerColor(piece.color);
    final radius = AppDimensions.pieceRadius;

    return Positioned(
      left: position.dx - radius,
      top: position.dy - radius,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isMovable ? Colors.white : Colors.black54,
              width: isMovable ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: isMovable ? 8 : 4,
                offset: const Offset(0, 2),
              ),
              if (isMovable)
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.airplanemode_active,
              color: Colors.white,
              size: radius * 0.9,
            ),
          ),
        ),
      ),
    );
  }
}
