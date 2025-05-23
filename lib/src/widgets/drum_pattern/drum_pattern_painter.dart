import 'package:flutter/material.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/user_accuracy.dart';
import 'package:rhythm_trainer/src/widgets/drum_pattern/user_tap.dart';

class DrumPatternPainter extends CustomPainter {
  final DrumPattern pattern;
  final List<UserTap> userTaps;

  DrumPatternPainter({super.repaint, required this.pattern, required this.userTaps});

  @override
  void paint(Canvas canvas, Size size) {
    print('paint');

    final horLinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.5;

    final barLinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    final strongBeatLinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    final weakBeatLinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.5;

    final notePaint = Paint()
      ..color = Colors.red.shade900
      ..strokeWidth = 1.4;

    final upperLaneY = size.height * 0.33;
    final lowerLaneY = size.height * 0.66;
    const double noteSize = 10.0;

    const padding = 10.0;
    final contentWidth = size.width - padding * 2;

    final barWidth = contentWidth / (pattern.barsCount);
    final beatWidth = barWidth / 4;
    final halfBeatWidth = barWidth / 8;


    // 1. Рисуем горизонтальные линии (линейки)
    _drawHorizontalLanes(canvas, padding, contentWidth, horLinePaint, upperLaneY, lowerLaneY);

    final bars = _splitNotesByBars(pattern);

    for (var i = 0; i< bars.length; ++i) {
      final bar = bars[i];
      final start = padding + barWidth * i;

      _drawBarLine(start, canvas, size.height, barLinePaint);

      for (var j = 0; j < 8; ++j) {
        final pos = start + halfBeatWidth * j;

        if (j % 8 == 0) {
          _drawBarLine(pos, canvas, size.height, barLinePaint);
        } else if (j % 4 == 0) {
          _drawBarLine(pos, canvas, size.height, strongBeatLinePaint);
        } else {
          _drawBarLine(pos, canvas, size.height, weakBeatLinePaint);
        }

      }

      _drawBarContent(start, barWidth, canvas, bar, notePaint, upperLaneY, lowerLaneY, noteSize);
    }

    _drawBarLine(padding + contentWidth, canvas, size.height, barLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! DrumPatternPainter
        || oldDelegate.pattern != pattern
        || oldDelegate.userTaps.length != userTaps.length;
  }

  void _drawHorizontalLanes(Canvas canvas, double start, double width, Paint linePaint, double upperLaneY, double lowerLaneY) {
    canvas.drawLine(Offset(start, upperLaneY), Offset(start + width, upperLaneY), linePaint);
    canvas.drawLine(Offset(start, lowerLaneY), Offset(start + width, lowerLaneY), linePaint);
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

  void _drawBarLine(double start, Canvas canvas, double height, Paint linePaint) {
    canvas.drawLine(Offset(start, 0), Offset(start, height), linePaint);
  }

  void _drawBarContent(
      double contentStart,
      double barWidth,
      Canvas canvas,
      List<DrumNote> bar,
      Paint paint,
      double upperLaneY,
      double lowerLaneY,
      double noteSize,
      ) {
    for (final note in bar) {
      final x = contentStart + (note.startTime / 4) * barWidth;
      final y = note.pad == DrumPad.right ? upperLaneY : lowerLaneY;

      _drawCross(canvas, Offset(x, y), noteSize, paint);
    }

    for (final tap in userTaps) {
      final x = contentStart + (tap.beat / 4) * barWidth;
      final y = (tap.pad == DrumPad.right ? upperLaneY : lowerLaneY) + 3;

      _drawUserNote(canvas, x, y, tap.accuracyLevel);
    }
  }

  void _drawUserNote(Canvas canvas, double x, double y, AccuracyLevel? accuracyLevel) {
    final tapPaint = Paint()
    // ..color = Colors.green.shade800
      ..style = PaintingStyle.fill;

    tapPaint.color = switch (accuracyLevel) {
      AccuracyLevel.perfect => Colors.green,
      AccuracyLevel.great => Colors.lightGreen,
      AccuracyLevel.ok => Colors.orange,
      AccuracyLevel.miss => Colors.red,
      null => Colors.grey, // для ExtraHit
    };

    _drawTriangle(canvas, Offset(x, y), 6.0, tapPaint);
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

  /// We note with them where user hit.
  void _drawTriangle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    path.moveTo(center.dx, center.dy - size / 2); // верхняя точка
    path.lineTo(center.dx - size / 2, center.dy + size / 2); // нижняя левая
    path.lineTo(center.dx + size / 2, center.dy + size / 2); // нижняя правая
    path.close();

    canvas.drawPath(path, paint);
  }
}