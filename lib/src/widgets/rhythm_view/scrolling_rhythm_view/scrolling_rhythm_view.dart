import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/timing.dart';
import 'package:rhythm_trainer/src/logic/training_engine_events.dart';
import 'package:rhythm_trainer/src/widgets/rhythm_view/rhythm_view.dart';
import 'package:rhythm_trainer/src/widgets/rhythm_view/scrolling_rhythm_view/paint_scene.dart';

class ScrollingRhythmView extends StatefulWidget implements RhythmView {
  @override
  final DrumPattern pattern;
  @override
  final Stream<TrainingEngineEvent> events;

  @override
  final Timing timing;

  const ScrollingRhythmView({
    required this.pattern,
    required this.events,
    required this.timing,
    super.key,
  }) ;

  @override
  State<ScrollingRhythmView> createState() => _ScrollingRhythmViewState();
}

class _ScrollingRhythmViewState extends State<ScrollingRhythmView> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  /// Current playhead time in beats.
  final ValueNotifier<double> _currentTime = ValueNotifier(0);

  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    _ticker = createTicker(_onTick);

    widget.events.listen(_onEvent);
  }

  void _onEvent(TrainingEngineEvent event) {
    switch (event) {
      case TrainingStarted():
        _startTime = DateTime.now();
        _ticker.start();

      case TrainingEnded():
        _ticker.stop();

      case RepeatStarted():
      case RepeatEnded():
      case NoteHit():
      case NoteMissed():
      case ExtraHit():
        1;
    }
  }

  void _onTick(_) {
    final now = DateTime.now();
    final elapsedMs = now.difference(_startTime).inMicroseconds * 0.001;
    final elapsedBeats = elapsedMs * widget.timing.tempo / 60000;

    _currentTime.value = elapsedBeats;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScrollingRhythmPainter(
        currentBeats: _currentTime,
        pattern: widget.pattern,
        beatsPerBar: widget.timing.beatsPerBar,
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _currentTime.dispose();
    super.dispose();
  }
}

class _ScrollingRhythmPainter extends CustomPainter {
  final DrumPattern pattern;
  final int beatsPerBar;
  final ValueNotifier<double> currentBeats;

  _ScrollingRhythmPainter({
    required this.currentBeats,
    required this.pattern,
    required this.beatsPerBar,
  }) : super(repaint: currentBeats);

  @override
  void paint(Canvas canvas, Size size) {
    paintScene(
      canvas: canvas,
      size: size,
      currentBeat: currentBeats.value,
      viewportBeatsWidth: 5.0,
      headPositionOffset: 0.2,
      pattern: pattern,
      beatsPerBar: beatsPerBar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _ScrollingRhythmPainter;
        // || oldDelegate.pattern != pattern
        // || oldDelegate.userTaps.length != userTaps.length;
  }
}