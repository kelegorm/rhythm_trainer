import 'package:flutter/widgets.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/training_engine_events.dart';

abstract class RhythmView extends StatefulWidget {
  final DrumPattern pattern;
  final Stream<TrainingEngineEvent> events;

  const RhythmView({
    required this.pattern,
    required this.events,
    super.key,
  });
}