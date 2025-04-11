import 'package:flutter/material.dart';
import 'package:rhythm_trainer/drum_pattern.dart';
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
      ..strokeWidth = 0.5;

    final barlinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.5;

    final notePaint = Paint()
      ..color = Colors.red.shade900
      ..strokeWidth = 1.4;

    final tapPaint = Paint()
      ..color = Colors.green.shade800
      ..style = PaintingStyle.fill;

    final upperLaneY = size.height * 0.33;
    final lowerLaneY = size.height * 0.66;
    const double noteSize = 10.0;

    const padding = 10.0;
    final contentWidth = size.width - padding * 2;

    final barWidth = contentWidth / (pattern.barsCount);

    // 1. Рисуем горизонтальные линии (линейки)
    _drawHorizontalLanes(canvas, padding, contentWidth, horlinePaint, upperLaneY, lowerLaneY);

    final _bars = _splitNotesByBars(pattern);

    for (var i = 0; i< _bars.length; ++i) {
      final bar = _bars[i];
      final start = padding + barWidth * i;

      _drawBarLine(start, canvas, size.height, barlinePaint);
      _drawBarContent(start, barWidth, canvas, bar, notePaint, upperLaneY, lowerLaneY, noteSize, tapPaint);
    }

    _drawBarLine(padding + contentWidth, canvas, size.height, barlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    print('shouldRepaint1: ${oldDelegate is! DrumPatternPainter}'); // false
    print('shouldRepaint2: ${(oldDelegate as DrumPatternPainter).pattern != pattern}'); // false
    print('shouldRepaint3: ${(oldDelegate as DrumPatternPainter).userTaps.length != userTaps.length}');

    return oldDelegate is DrumPatternPainter
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
    Paint tapPaint,
  ) {
    for (final note in bar) {
      final x = contentStart + (note.startTime / 4) * barWidth;
      final y = note.pad == DrumPad.right ? upperLaneY : lowerLaneY;

      _drawCross(canvas, Offset(x, y), noteSize, paint);
    }

    for (final tap in userTaps) {
      final x = contentStart + (tap.beat / 4) * barWidth;
      final y = (tap.pad == DrumPad.right ? upperLaneY : lowerLaneY) + 3;

      _drawTriangle(canvas, Offset(x, y), 6.0, tapPaint);
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