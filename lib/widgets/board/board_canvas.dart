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

    // 1. 背景
    final bgPaint = Paint()..color = AppColors.boardBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. 四角机库背景色块
    _drawHangarBackground(canvas, cellW, cellH);

    // 3. 公共跑道格子
    _drawTrack(canvas, cellW, cellH);

    // 4. 冲刺道格子
    _drawHomeStretch(canvas, cellW, cellH);

    // 5. 机库格子
    _drawHangars(canvas, cellW, cellH);

    // 6. 起点标记
    _drawStartPositions(canvas, cellW, cellH);

    // 7. 终点区域
    _drawFinishArea(canvas, cellW, cellH);
  }

  /// 四角 4x4 彩色背景
  void _drawHangarBackground(Canvas canvas, double cellW, double cellH) {
    // 右下=红  左下=蓝  左上=黄  右上=绿
    final zones = {
      PlayerColor.red:    Rect.fromLTWH(11 * cellW, 11 * cellH, 4 * cellW, 4 * cellH),
      PlayerColor.blue:   Rect.fromLTWH(0, 11 * cellH, 4 * cellW, 4 * cellH),
      PlayerColor.yellow: Rect.fromLTWH(0, 0, 4 * cellW, 4 * cellH),
      PlayerColor.green:  Rect.fromLTWH(11 * cellW, 0, 4 * cellW, 4 * cellH),
    };

    for (var entry in zones.entries) {
      final paint = Paint()
        ..color = BoardGeometry.getPlayerColor(entry.key).withOpacity(0.15);
      canvas.drawRRect(
        RRect.fromRectAndRadius(entry.value, const Radius.circular(8)),
        paint,
      );
    }
  }

  /// 绘制52格公共跑道
  void _drawTrack(Canvas canvas, double cellW, double cellH) {
    final cellPaint = Paint()
      ..color = AppColors.trackCell
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.cellBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < BoardGeometry.track.length; i++) {
      final (x, y) = BoardGeometry.track[i];
      final rect = Rect.fromLTWH(
        x * cellW + 1,
        y * cellH + 1,
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

  /// 绘制冲刺道
  void _drawHomeStretch(Canvas canvas, double cellW, double cellH) {
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var color in PlayerColor.values) {
      final stretchColor = BoardGeometry.getPlayerColor(color).withOpacity(0.3);
      borderPaint.color = BoardGeometry.getPlayerColor(color);

      for (var (x, y) in BoardGeometry.getHomeStretchPositions(color)) {
        final rect = Rect.fromLTWH(
          x * cellW + 1,
          y * cellH + 1,
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

  /// 绘制机库格子
  void _drawHangars(Canvas canvas, double cellW, double cellH) {
    final cellPaint = Paint()
      ..color = AppColors.hangarCell
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.cellBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var color in PlayerColor.values) {
      for (var (x, y) in BoardGeometry.getHangarPositions(color)) {
        final rect = Rect.fromLTWH(
          x * cellW + 2,
          y * cellH + 2,
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

  /// 绘制起点标记（彩色圆圈）
  void _drawStartPositions(Canvas canvas, double cellW, double cellH) {
    for (var entry in GameConfig.startPositions.entries) {
      final (x, y) = BoardGeometry.track[entry.value];
      final center = Offset(x * cellW + cellW / 2, y * cellH + cellH / 2);
      final paint = Paint()
        ..color = BoardGeometry.getPlayerColor(entry.key).withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, cellW / 2 - 2, paint);
    }
  }

  /// 绘制中心终点区域
  void _drawFinishArea(Canvas canvas, double cellW, double cellH) {
    final center = Offset(7 * cellW + cellW / 2, 7 * cellH + cellH / 2);

    // 终点背景圆
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, cellW * 1.2, paint);

    // 终点文字
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '终点',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
