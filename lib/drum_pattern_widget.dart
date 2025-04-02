import 'package:flutter/material.dart';
import 'package:rhythm_trainer/drum_pattern.dart';
import 'dart:math';

import 'package:rhythm_trainer/training_engine_events.dart';

class DrumPatternWidget extends StatefulWidget {
  final DrumPattern pattern;
  final Stream<TrainingEngineEvent> events;
  final TrainingEngineEvent lastEvent;

  DrumPatternWidget({
    required this.pattern,
    required this.events,
    required this.lastEvent,
    super.key,
  });

  @override
  State<DrumPatternWidget> createState() => _DrumPatternWidgetState();
}


class _DrumPatternWidgetState extends State<DrumPatternWidget> {
  final List<UserTap> userTaps = <UserTap>[];

  @override
  void initState() {
    super.initState();

    widget.events.listen(_onEvent);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DrumPatternPainter(
        pattern: widget.pattern,
        userTaps: userTaps.toList(),
      ),
    );
  }

  void _onEvent(TrainingEngineEvent event) {
    switch (event) {
      case TrainingStarted():
        setState(() {
          userTaps.clear();
        });

      case TrainingEnded():
      case RepeatStarted():
      case RepeatEnded():
      case NoteMissed():
        return;

      case NoteHit hit:
        setState(() {
          userTaps.add(UserTap(beat: hit.beat, pad: hit.pad));
          print('Note Hit!!');
        });

      case ExtraHit hit:
        setState(() {
          userTaps.add(UserTap(beat: hit.beat, pad: hit.pad));
          print('Extra Note Hit!!');
        });
    }
  }
}

class DrumPatternPainter extends CustomPainter {
  final DrumPattern pattern;
  final List<UserTap> userTaps;

  DrumPatternPainter({super.repaint, required this.pattern, required this.userTaps});

  @override
  void paint(Canvas canvas, Size size) {
    print('paint');

    final horlinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final barlinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final notePaint = Paint()
      ..color = Colors.red.shade900
      ..strokeWidth = 1.4;

    final tapPaint = Paint()
      ..color = Colors.green.shade800
      ..style = PaintingStyle.fill;

    final upperLaneY = size.height * 0.33;
    final lowerLaneY = size.height * 0.66;
    const double noteSize = 10.0;

    // 1. Рисуем горизонтальные линии (линейки)
    _drawHorizontalLanes(canvas, size, horlinePaint, upperLaneY, lowerLaneY);

    final _bars = _splitNotesByBars(pattern);

    num start = 0;
    for (var bar in _bars) {
      start += _drawBarLine(start, canvas, size.height, barlinePaint);
      start += _drawBarContent(start, canvas, bar, notePaint, upperLaneY, lowerLaneY, noteSize, tapPaint);
    }

    _drawBarLine(start, canvas, size.height, barlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    print('shouldRepaint1: ${oldDelegate is! DrumPatternPainter}'); // false
    print('shouldRepaint2: ${(oldDelegate as DrumPatternPainter).pattern != pattern}'); // false
    print('shouldRepaint3: ${(oldDelegate as DrumPatternPainter).userTaps.length != userTaps.length}');

    return oldDelegate is! DrumPatternPainter
        || oldDelegate.pattern != pattern
        || oldDelegate.userTaps.length != userTaps.length;
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

  num _drawBarContent(
    num contentStart,
    Canvas canvas,
    List<DrumNote> bar,
    Paint paint,
    double upperLaneY,
    double lowerLaneY,
    double noteSize,
    Paint tapPaint,
  ) {
    final barWidth = max(bar.length * 25.0, 50.0);
    var start = contentStart;

    for (final note in bar) {
      final x = start + (note.startTime / 4) * barWidth + noteSize*0.5;
      final y = note.pad == DrumPad.right ? upperLaneY : lowerLaneY;

      _drawCross(canvas, Offset(x, y), noteSize, paint);
    }

    for (final tap in userTaps) {
      final x = start + (tap.beat / 4) * barWidth + 10; // +10 = отступ начала
      final y = (tap.pad == DrumPad.right ? upperLaneY : lowerLaneY) + 3;

      _drawTriangle(canvas, Offset(x, y), 6.0, tapPaint);
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

class UserTap {
  final double beat; // или absoluteBeat, если есть повторения
  final DrumPad pad;

  UserTap({required this.beat, required this.pad});
}