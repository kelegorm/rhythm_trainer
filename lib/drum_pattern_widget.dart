import 'package:flutter/material.dart';
import 'package:rhythm_trainer/drum_pattern.dart';

class DrumPatternWidget extends StatelessWidget {
  final DrumPattern pattern;

  const DrumPatternWidget({super.key, required this.pattern});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: DrumPatternPainter(pattern: pattern));
  }
}

class DrumPatternPainter extends CustomPainter {
  final DrumPattern pattern;

  DrumPatternPainter({super.repaint, required this.pattern});

  @override
  void paint(Canvas canvas, Size size) {
    // Общее количество бит в паттерне (4/4)
    final totalBeats = pattern.barsCount * 4;

    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final notePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    final upperLaneY = size.height * 0.33;
    final lowerLaneY = size.height * 0.66;

    const double noteSize = 10.0;

    // 1. Рисуем горизонтальные линии (линейки)
    _drawHorizontalLanes(canvas, size, linePaint, upperLaneY, lowerLaneY);


    // 2. Рисуем вертикальные линии для тактов (при условии 4/4)
    final barWidth = size.width / pattern.barsCount;
    for (int i = 0; i <= pattern.barsCount; i++) {
      final x = i * barWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // 3. Рисуем каждую ноту как крестик, используя вспомогательный метод.
    for (final note in pattern.notes) {
      final x = (note.startTime / totalBeats) * size.width;
      final y = note.pad == DrumPad.right ? upperLaneY : lowerLaneY;
      _drawCross(canvas, Offset(x, y), noteSize, notePaint);
    }
  }

  void _drawCross(Canvas canvas, Offset center, double size, Paint paint) {
    final halfSize = size / 2;
    canvas.drawLine(
      Offset(center.dx - halfSize, center.dy - halfSize),
      Offset(center.dx + halfSize, center.dy + halfSize),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx - halfSize, center.dy + halfSize),
      Offset(center.dx + halfSize, center.dy - halfSize),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy - halfSize),
      Offset(center.dx, center.dy - halfSize - size),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! DrumPatternPainter || oldDelegate.pattern != pattern;
  }

  void _drawHorizontalLanes(Canvas canvas, Size size, Paint linePaint, double upperLaneY, double lowerLaneY) {
    canvas.drawLine(Offset(0, upperLaneY), Offset(size.width, upperLaneY), linePaint);
    canvas.drawLine(Offset(0, lowerLaneY), Offset(size.width, lowerLaneY), linePaint);
  }
}

