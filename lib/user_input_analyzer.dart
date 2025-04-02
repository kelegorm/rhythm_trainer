import 'dart:math' show min;

import 'package:meta/meta.dart';
import 'package:rhythm_trainer/drum_pattern.dart';

/// Matches user hits to reference rhythm notes and classifies each hit as
/// matched or extra hits.
///
/// Does not handle missed notes or time progression. Call [clear] to reuse.
class UserInputAnalyzer {
  final DrumPattern _pattern;
  final double _tempo;
  final int _repeats;

  final _referenceHits = List<_HitReference>.empty(growable: true);
  final _userHits = List<_UserHit>.empty(growable: true);

  /// Used to calculate position within repeating pattern.
  ///
  /// Assumes 4/4 (4 beats per bar).
  late final double _patternLengthBeats;

  /// Accuracity in beats.
  late final accuracityRadius;

  /// Accuracity in beats. Since beat is 1/4 musical size, 0.5 means 1/8.
  static const double defaultAccuracity = 0.5;


  UserInputAnalyzer({
    required DrumPattern pattern,
    required double tempo,
    required int repeats,
  }) : _repeats = repeats, _tempo = tempo, _pattern = pattern {
    _generateTrainingData();

    _patternLengthBeats = _pattern.barsCount * 4;

    accuracityRadius = computeGridTolerance(pattern.notes, pattern.barsCount);
  }

  /// Prepares the analyzer for a new training run by resetting internal state.
  void clear() {
    _prepareTrainingData();
  }

  /// Analyzes a single user hit and determines if it matches the reference
  /// pattern.
  ///
  /// Returns [NoteHitResult] if hit is within 1/8 beat of a reference note,
  /// otherwise [ExtraHitResult].
  ///
  /// [hitTimeSeconds] is absolute time since training start.
  ///
  /// See also [NoteHitResult] and [ExtraHitResult] for more details.
  InputAnalysisResult analyzeUserInput({required double hitTimeSeconds, required DrumPad pad}) {
    final secondsPerBeat = 60.0 / _tempo;
    final absHitBeats = hitTimeSeconds / secondsPerBeat;

    double minDeviation = double.infinity;
    int bestMatchIndex = -1;

    for (int i = 0; i < _referenceHits.length; i++) {
      final ref = _referenceHits[i];

      if (!ref.matched && ref.pad == pad) {
        final deviation = absHitBeats - ref.beat;

        if (deviation.abs() < minDeviation.abs()) {
          minDeviation = deviation;
          bestMatchIndex = i;
        }
      }
    }

    if (bestMatchIndex != -1 && minDeviation < accuracityRadius) {
      _referenceHits[bestMatchIndex].matched = true;
    } else {
      bestMatchIndex = -1;
    }

    _userHits.add((beat: absHitBeats, pad: pad, deviation: minDeviation, refIndex: bestMatchIndex));

    if (bestMatchIndex >= 0) {
      final refNote = _referenceHits[bestMatchIndex];
      final relHitBeats = absHitBeats - (refNote.repeatIndex * _patternLengthBeats);

      return NoteHitResult(
        noteIndex: refNote.noteIndex,
        repeatIndex: refNote.repeatIndex,
        beat: relHitBeats,
        absoluteBeat: absHitBeats,
        pad: pad,
        deviation: minDeviation,
      );
    } else {
      final repeatIndex = absHitBeats ~/ _patternLengthBeats;
      final relHitBeats = absHitBeats - (repeatIndex * _patternLengthBeats);

      return ExtraHitResult(
        repeatIndex: repeatIndex,
        beat: relHitBeats,
        absoluteBeat: absHitBeats,
        pad: pad,
      );
    }
  }

  @visibleForTesting
  static double computeGridTolerance(Iterable<DrumNote> notes, int barsCount) {
    if (notes.length < 2) return defaultAccuracity; // значение по умолчанию

    final totalBeats = barsCount * 4.0; // длина паттерна в долях

    final sortedTimes = notes
        .map((n) => n.startTime)
        .takeWhile((n) => n < totalBeats)
        .toList();

    double minDelta = double.infinity;

    // Check all notes in pattern.
    for (int i = 1; i < sortedTimes.length; i++) {
      final delta = sortedTimes[i] - sortedTimes[i - 1];
      if (delta > 0.0 && delta < minDelta) minDelta = delta;
    }

    // Check last and first notes.
    final loopDelta = (sortedTimes.first + totalBeats) - sortedTimes.last;
    if (loopDelta > 0.0 && loopDelta < minDelta) minDelta = loopDelta;

    return min(minDelta / 2, defaultAccuracity);
  }


  /// Expands the reference pattern across [repeats], storing each note's
  /// absolute beat position.
  void _generateTrainingData() {
    _referenceHits.clear();

    // Предполагаем 4 удара в такте: длина рисунка в ударах.
    final patternLength = _pattern.barsCount * 4.0;

    // Для каждого повтора вычисляем сдвиг и для каждой ноты эталона – её абсолютное время.
    for (var i = 0; i < _repeats; i++) {
      final patternOffset = i * patternLength;

      for (var j = 0; j < _pattern.notes.length; ++j) {
        final note = _pattern.notes.skip(j).first;
        final expectedBeat = note.startTime + patternOffset;
        final ref = _HitReference(noteIndex: j, beat: expectedBeat, pad: note.pad, repeatIndex: i, matched: false);
        _referenceHits.add(ref);
      }
    }

    _userHits.clear();
  }

  /// Clears user hit list and unmarks matched references.
  void _prepareTrainingData() {
    _referenceHits.forEach((e) {
      e.matched = false;
    });

    _userHits.clear();
  }
}

/// Reference note with absolute beat position.
/// [matched] prevents reusing this note in future comparisons.
class _HitReference {
  final int noteIndex;
  final double beat;
  final DrumPad pad;
  final int repeatIndex;
  bool matched;

  _HitReference({
    required this.noteIndex,
    required this.beat,
    required this.pad,
    required this.repeatIndex,
    this.matched = false,
  });
}

/// Stores beat time and match deviation for a user hit.
/// [refIndex] is -1 if not matched.
typedef _UserHit = ({
  double beat,
  DrumPad pad,
  double deviation, // пока храним абсолютное значение, без знака рано или поздно. Потом исправим.
  int refIndex, // index of referenced note, -1 means no match
});

sealed class InputAnalysisResult {}

/// Indicates that the user's hit matched a reference note within the allowed timing window.
///
/// A single reference note can only be matched once. If multiple user hits fall near the same reference,
/// only the first one is considered a valid match; others will be treated as [ExtraHitResult].
///
/// Notes may belong to the current repeat or logically to the next one (see [repeatAhead]).
class NoteHitResult extends InputAnalysisResult {
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

  NoteHitResult({
    required this.noteIndex,
    required this.repeatIndex,
    required this.beat,
    required this.absoluteBeat,
    required this.pad,
    required this.deviation,
    this.repeatAhead = false,
  });
}

/// Indicates that the user's hit did not match any reference note within the allowed timing window.
///
/// Extra hits may result from inaccurate timing or unintended pad presses.
class ExtraHitResult extends InputAnalysisResult {
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

  ExtraHitResult({
    required this.repeatIndex,
    required this.beat,
    required this.absoluteBeat,
    required this.pad,
  });
}
