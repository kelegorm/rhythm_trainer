import 'package:flutter/material.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/training_engine_events.dart';
import 'package:rhythm_trainer/src/widgets/drum_pattern/drum_pattern_painter.dart';
import 'package:rhythm_trainer/src/widgets/drum_pattern/user_tap.dart';

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
          userTaps.add(UserTap(
            beat: hit.beat,
            pad: hit.pad,
            accuracyLevel: hit.accuracy.level,
          ));
        });

      case ExtraHit hit:
        setState(() {
          userTaps.add(UserTap(
            beat: hit.beat,
            pad: hit.pad,
            accuracyLevel: null,
          ));
        });
    }
  }
}