import 'package:rhythm_trainer/src/logic/drum_pattern.dart';

sealed class TrainingEngineEvent {}

class TrainingStarted extends TrainingEngineEvent {}

class TrainingEnded extends TrainingEngineEvent {}

class RepeatStarted extends TrainingEngineEvent {
  final int repeatIndex;

  RepeatStarted(this.repeatIndex);
}

class RepeatEnded extends TrainingEngineEvent {
  final int repeatIndex;

  RepeatEnded(this.repeatIndex);
}

class NoteHit extends TrainingEngineEvent {
  /// Note index in Rhythm Pattern.
  final int noteIndex;

  /// Repeat index this hit belongs to (starting from 0).
  final int repeatIndex;

  /// Actual beat position within the pattern, without repeat offset.
  ///
  /// Can be negative if played slightly before the first beat.
  final double beat;

  /// Actual beat position with repeat offset applied.
  ///
  /// Calculated as (repeatIndex * patternLength + beat).
  final double absoluteBeat;

  /// Which drum player hits. Left or right.
  final DrumPad pad;

  /// Difference with reference note time.
  ///
  /// Negative value means early, positive — late.
  final double deviation;

  /// True value means if the note was played slightly earlier than the first
  /// beat of the next repeat, but logically belongs to it.
  final bool repeatAhead;

  NoteHit({
    required this.noteIndex,
    required this.repeatIndex,
    required this.beat,
    required this.absoluteBeat,
    required this.pad,
    required this.deviation,
    this.repeatAhead = false,
  });
}

class NoteMissed extends TrainingEngineEvent {
  final int noteIndex;
  final int repeatIndex;

  NoteMissed({
    required this.noteIndex,
    required this.repeatIndex,
  });
}

class ExtraHit extends TrainingEngineEvent {
  final int repeatIndex;
  final double beat;
  final DrumPad pad;

  ExtraHit({
    required this.repeatIndex,
    required this.beat,
    required this.pad,
  });
}