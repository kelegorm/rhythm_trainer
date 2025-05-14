import 'package:flutter/material.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/training_engine_events.dart';
import 'package:rhythm_trainer/src/widgets/rhythm_view/static_view/static_rhythm_painter.dart';
import 'package:rhythm_trainer/src/widgets/rhythm_view/tap_data.dart';
import 'package:rhythm_trainer/src/widgets/rhythm_view/effects/my_first_tap_effect_widget.dart';
import 'package:rhythm_trainer/src/widgets/rhythm_view/user_tap.dart';

class StaticRhythmView extends StatefulWidget {
  final DrumPattern pattern;
  final Stream<TrainingEngineEvent> events;
  final TrainingEngineEvent lastEvent;

  StaticRhythmView({
    required this.pattern,
    required this.events,
    required this.lastEvent,
    super.key,
  });

  @override
  State<StaticRhythmView> createState() => _StaticRhythmViewState();
}


class _StaticRhythmViewState extends State<StaticRhythmView> {
  final List<UserTap> userTaps = <UserTap>[];
  final List<TapData> activeEffects = [];
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
                painter: StaticDrumPatternPainter(
                  pattern: widget.pattern,
                  userTaps: userTaps.toList(),
                ),
              ),
            ),
            ...activeEffects.map((effect) =>
                Positioned(
                  left: effect.position.dx,
                  top: effect.position.dy,
                  child: MyFirstTapEffectWidget(
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

    activeEffects.add(TapData(
      position: _calculateEffectPosition(tap, _canvasSize, widget.pattern.barsCount),
      level: tap.accuracyLevel,
      startTime: DateTime.now(),
    ));
  }

  void _removeEffect(TapData effect) {
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
