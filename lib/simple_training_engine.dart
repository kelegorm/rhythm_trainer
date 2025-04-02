import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rhythm_trainer/drum_pattern.dart';
import 'package:rhythm_trainer/training_engine.dart';
import 'package:rhythm_trainer/training_engine_events.dart';
import 'package:rhythm_trainer/user_input_analyzer.dart';

class SimpleTrainingEngine implements TrainingEngine {
  final DrumPattern pattern;
  final double tempo;
  final int repeats;

  @override
  Stream<TrainingEngineEvent> get events => _ctrl.stream;
  final StreamController<TrainingEngineEvent> _ctrl = StreamController<TrainingEngineEvent>();

  TrainingEngineEvent get event => _event;
  TrainingEngineEvent _event = TrainingEnded();

  late final UserInputAnalyzer _inputAnalyzer;
  DateTime? _trainingStartTime;


  SimpleTrainingEngine({
    required this.pattern,
    required this.tempo,
    required this.repeats,
  }) {
    _inputAnalyzer = UserInputAnalyzer(
      pattern: pattern,
      tempo: tempo,
      repeats: repeats,
    );
  }

  @override
  void start() {
    _trainingStartTime = DateTime.now().add(Duration(milliseconds: 0));
    pushEvent(TrainingStarted());
  }

  @override
  void userHit(DrumPad pad) {
    if (_trainingStartTime == null) return;

    final startTime = _trainingStartTime!;
    final hitTimeSeconds = DateTime.now().difference(startTime).inMicroseconds / 1000000.0;

    final result = _inputAnalyzer.analyzeUserInput(hitTimeSeconds: hitTimeSeconds, pad: pad);

    final event = switch (result) {
      NoteHitResult noteHit => NoteHit(
          noteIndex: noteHit.noteIndex,
          repeatIndex: noteHit.repeatIndex,
          beat: noteHit.beat,
          absoluteBeat: noteHit.absoluteBeat,
          pad: noteHit.pad,
          deviation: noteHit.deviation,
        ),

      ExtraHitResult extra => ExtraHit(
          repeatIndex: extra.repeatIndex,
          beat: extra.beat,
          pad: extra.pad,
        ),
    };

    pushEvent(event);
  }

  @override
  void stop() {
    pushEvent(TrainingEnded());
  }

  @visibleForTesting
  void pushEvent(TrainingEngineEvent newEvent) {
    // TODO validate event
    _event = newEvent;
    _ctrl.add(newEvent);
  }
}
