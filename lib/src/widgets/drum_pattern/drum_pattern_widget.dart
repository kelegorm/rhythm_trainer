import 'package:flutter/material.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/training_engine_events.dart';
import 'package:rhythm_trainer/src/widgets/drum_pattern/drum_pattern_painter.dart';
import 'package:rhythm_trainer/src/widgets/drum_pattern/tap_effect.dart';
import 'package:rhythm_trainer/src/widgets/drum_pattern/tap_effect_widget.dart';
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
  final List<TapEffect> activeEffects = [];
  Size _canvasSize = Size.zero;

  @override
  void initState() {
    super.initState();

    widget.events.listen(_onEvent);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        // TODO recalc effects position when size was changed sine last build.

        return SizedBox.expand(
          child: Stack(children: [
            SizedBox.expand(
              child: CustomPaint(
                painter: DrumPatternPainter(
                  pattern: widget.pattern,
                  userTaps: userTaps.toList(),
                ),
              ),
            ),
            ...activeEffects.map((effect) =>
                Positioned(
                  left: effect.position.dx,
                  top: effect.position.dy,
                  child: TapEffectWidget(
                    effect: effect,
                    onFinished: _removeEffect,
                    key: GlobalObjectKey(effect),
                  ),
                )),
          ]),
        );
      });
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
          final tap = UserTap(
            beat: hit.beat,
            pad: hit.pad,
            accuracyLevel: hit.accuracy.level,
          );

          _processUserTap(tap);
        });

      case ExtraHit hit:
        setState(() {
          final tap = UserTap(
            beat: hit.beat,
            pad: hit.pad,
            accuracyLevel: null,
          );

          _processUserTap(tap);
        });
    }
  }

  void _processUserTap(UserTap tap) {
    userTaps.add(tap);

    activeEffects.add(TapEffect(
      position: _calculateEffectPosition(tap, _canvasSize, widget.pattern.barsCount),
      level: tap.accuracyLevel,
      startTime: DateTime.now(),
    ));
  }

  void _removeEffect(TapEffect effect) {
    setState(() {
      activeEffects.remove(effect);
    });
  }
}

Offset _calculateEffectPosition(UserTap tap, Size size, int barsCount) {
  const padding = 10.0;
  final contentWidth = size.width - padding * 2;
  final barWidth = contentWidth / barsCount;

  final x = padding + (tap.beat / 4) * barWidth;

  final upperLaneY = size.height * 0.33;
  final lowerLaneY = size.height * 0.66;
  final y = tap.pad == DrumPad.right ? upperLaneY : lowerLaneY;

  return Offset(x, y);
}
