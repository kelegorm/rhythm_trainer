import 'package:flutter/material.dart';
import 'package:rhythm_trainer/drum_pattern.dart';
import 'dart:math';

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
    final horlinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final barlinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final notePaint = Paint()
      ..color = Colors.red.shade900
      ..strokeWidth = 1.4;

    final upperLaneY = size.height * 0.33;
    final lowerLaneY = size.height * 0.66;
    const double noteSize = 10.0;

    // 1. Рисуем горизонтальные линии (линейки)
    _drawHorizontalLanes(canvas, size, horlinePaint, upperLaneY, lowerLaneY);

    final _bars = _splitNotesByBars(pattern);

    num start = 0;
    for (var bar in _bars) {
      start += _drawBarLine(start, canvas, size.height, barlinePaint);
      start += _drawBarContent(start, canvas, bar, notePaint, upperLaneY, lowerLaneY, noteSize);
    }

    _drawBarLine(start, canvas, size.height, barlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! DrumPatternPainter || oldDelegate.pattern != pattern;
  }

  void _drawHorizontalLanes(Canvas canvas, Size size, Paint linePaint, double upperLaneY, double lowerLaneY) {
    canvas.drawLine(Offset(0, upperLaneY), Offset(size.width, upperLaneY), linePaint);
    canvas.drawLine(Offset(0, lowerLaneY), Offset(size.width, lowerLaneY), linePaint);
  }

  static List<List<DrumNote>> _splitNotesByBars(DrumPattern pattern) {
    List<List<DrumNote>> result = List.generate(pattern.barsCount, (_) => []);

    for (final note in pattern.notes) {
      int barIndex = note.startTime ~/ 4; // 4 бита на такт (4/4)

      if (barIndex < pattern.barsCount) {
        double localTime = note.startTime - barIndex * 4;
        result[barIndex].add(DrumNote(note.pad, localTime));
      }
    }

    return result;
  }

  num _drawBarLine(num start, Canvas canvas, double height, Paint linePaint) {
    canvas.drawLine(Offset(start + 10.0, 0), Offset(start + 10.0, height), linePaint);

    return 20.0;
  }

  num _drawBarContent(num start, Canvas canvas, List<DrumNote> bar, Paint paint, double upperLaneY, double lowerLaneY, double noteSize) {
    final barWidth = max(bar.length * 25.0, 50.0);

    for (final note in bar) {
      final x = start + (note.startTime / 4) * barWidth + noteSize*0.5;
      final y = note.pad == DrumPad.right ? upperLaneY : lowerLaneY;
      _drawCross(canvas, Offset(x, y), noteSize, paint);
    }

    return barWidth;
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
}

