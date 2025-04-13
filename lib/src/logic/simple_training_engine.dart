import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/exercise.dart';
import 'package:rhythm_trainer/src/logic/training_engine.dart';
import 'package:rhythm_trainer/src/logic/training_engine_events.dart';
import 'package:rhythm_trainer/src/logic/user_input_analyzer.dart';

class SimpleTrainingEngine implements TrainingEngine {
  final Exercise exercise;

  @override
  Stream<TrainingEngineEvent> get events => _ctrl.stream;
  final StreamController<TrainingEngineEvent> _ctrl = StreamController<TrainingEngineEvent>();

  @override
  TrainingEngineEvent get event => _event;
  TrainingEngineEvent _event = TrainingEnded();

  late final UserInputAnalyzer _inputAnalyzer;
  DateTime? _trainingStartTime;


  SimpleTrainingEngine({
    required this.exercise,
  }) {
    _inputAnalyzer = UserInputAnalyzer(
      pattern: exercise.pattern,
      tempo: exercise.tempo,
      repeats: exercise.repetitions,
    );
  }

  @override
  void start() {
    _trainingStartTime = DateTime.now();
    pushEvent(TrainingStarted());
  }

  @override
  void userHit(DrumPad pad) {
    if (_trainingStartTime == null) return;

    final startTime = _trainingStartTime!;
    final hitTimeSeconds = DateTime.now().difference(startTime).inMicroseconds / 1000000.0;

    final noteInfo = _inputAnalyzer.analyzeUserInput(hitTimeSeconds: hitTimeSeconds, pad: pad);

    final event = switch (noteInfo) {
      NoteHitResult noteHit => _prepareNoteHitEvent(noteHit),

      ExtraHitResult extra => ExtraHit(
          repeatIndex: extra.repeatIndex,
          beat: extra.beat,
          pad: extra.pad,
        ),
    };

    pushEvent(event);
  }

  NoteHit _prepareNoteHitEvent(NoteHitResult noteInfo) {
    final noteAccuracy = exercise.accuracy.inspect(noteInfo.deviation);

    return NoteHit(
        noteIndex: noteInfo.noteIndex,
        repeatIndex: noteInfo.repeatIndex,
        beat: noteInfo.beat,
        absoluteBeat: noteInfo.absoluteBeat,
        pad: noteInfo.pad,
        deviation: noteInfo.deviation,
        accuracy: noteAccuracy,
      );
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
