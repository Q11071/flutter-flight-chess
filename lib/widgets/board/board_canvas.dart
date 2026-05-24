import 'package:flutter/material.dart';
import '../../utils/board_geometry.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../models/game_config.dart';

class BoardCanvas extends StatelessWidget {
  final Size boardSize;

  const BoardCanvas({super.key, required this.boardSize});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: boardSize,
      painter: _BoardPainter(boardSize),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final Size boardSize;

  _BoardPainter(this.boardSize);

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / 15;
    final cellH = size.height / 15;

    // 绘制背景
    final bgPaint = Paint()..color = AppColors.boardBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 绘制四角彩色区域 (机库背景)
    _drawHangarBackground(canvas, size, cellW, cellH);

    // 绘制公共跑道52格
    _drawTrack(canvas, size, cellW, cellH);

    // 绘制冲刺道
    _drawHomeStretch(canvas, size, cellW, cellH);

    // 绘制机库格子
    _drawHangars(canvas, size, cellW, cellH);

    // 绘制起点标记
    _drawStartPositions(canvas, size, cellW, cellH);

    // 绘制终点区域
    _drawFinishArea(canvas, size, cellW, cellH);
  }

  void _drawHangarBackground(Canvas canvas, Size size, double cellW, double cellH) {
    final hangars = {
      PlayerColor.red: [10, 0, 4, 4],    // row, col, w, h
      PlayerColor.yellow: [10, 11, 4, 4],
      PlayerColor.blue: [0, 11, 4, 4],
      PlayerColor.green: [0, 0, 4, 4],
    };

    final colors = {
      PlayerColor.red: AppColors.red.withOpacity(0.15),
      PlayerColor.yellow: AppColors.yellow.withOpacity(0.15),
      PlayerColor.blue: AppColors.blue.withOpacity(0.15),
      PlayerColor.green: AppColors.green.withOpacity(0.15),
    };

    for (var entry in hangars.entries) {
      final rect = Rect.fromLTWH(
        entry.value[1] * cellW,
        entry.value[0] * cellH,
        entry.value[2] * cellW,
        entry.value[3] * cellH,
      );
      final paint = Paint()..color = colors[entry.key]!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
    }
  }

  void _drawTrack(Canvas canvas, Size size, double cellW, double cellH) {
    final cellPaint = Paint()
      ..color = AppColors.trackCell
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.cellBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < BoardGeometry.track.length; i++) {
      final (row, col) = BoardGeometry.track[i];
      final rect = Rect.fromLTWH(
        col * cellW + 1,
        row * cellH + 1,
        cellW - 2,
        cellH - 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        cellPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        borderPaint,
      );
    }
  }

  void _drawHomeStretch(Canvas canvas, Size size, double cellW, double cellH) {
    final colorMap = {
      PlayerColor.red: AppColors.red.withOpacity(0.3),
      PlayerColor.yellow: AppColors.yellow.withOpacity(0.3),
      PlayerColor.blue: AppColors.blue.withOpacity(0.3),
      PlayerColor.green: AppColors.green.withOpacity(0.3),
    };

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var color in PlayerColor.values) {
      final stretchColor = colorMap[color]!;
      borderPaint..color = BoardGeometry.getPlayerColor(color);

      for (var (row, col) in BoardGeometry.getHomeStretchPositions(color)) {
        final rect = Rect.fromLTWH(
          col * cellW + 1,
          row * cellH + 1,
          cellW - 2,
          cellH - 2,
        );
        final cellPaint = Paint()..color = stretchColor;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          cellPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          borderPaint,
        );
      }
    }
  }

  void _drawHangars(Canvas canvas, Size size, double cellW, double cellH) {
    final cellPaint = Paint()
      ..color = AppColors.hangarCell
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.cellBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var color in PlayerColor.values) {
      for (var (row, col) in BoardGeometry.getHangarPositions(color)) {
        final rect = Rect.fromLTWH(
          col * cellW + 2,
          row * cellH + 2,
          cellW - 4,
          cellH - 4,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          cellPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          borderPaint,
        );
      }
    }
  }

  void _drawStartPositions(Canvas canvas, Size size, double cellW, double cellH) {
    for (var entry in GameConfig.startPositions.entries) {
      final (row, col) = BoardGeometry.track[entry.value];
      final center = Offset(col * cellW + cellW / 2, row * cellH + cellH / 2);
      final paint = Paint()
        ..color = BoardGeometry.getPlayerColor(entry.key).withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, cellW / 2 - 2, paint);
    }
  }

  void _drawFinishArea(Canvas canvas, Size size, double cellW, double cellH) {
    final center = Offset(7 * cellW + cellW / 2, 7 * cellH + cellH / 2);
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, cellW * 1.5, paint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '终点',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
