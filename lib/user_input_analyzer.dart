import 'package:rhythm_trainer/drum_pattern.dart';

class UserInputAnalyzer {
  final DrumPattern _pattern;
  final double _tempo;
  final int _repeats;

  final _referenceHits = List<_HitReference>.empty(growable: true);
  final _userHits = List<_UserHit>.empty(growable: true);

  late final double _patternLengthBeats;

  UserInputAnalyzer({
    required DrumPattern pattern,
    required double tempo,
    required int repeats,
  }) : _repeats = repeats, _tempo = tempo, _pattern = pattern {
    _generateTrainingData();

    _patternLengthBeats = _pattern.barsCount * 4;
  }

  /// Clears all user input, makes analyzer ready for new run.
  void clear() {
    _prepareTrainingData();
  }

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

    if (bestMatchIndex != -1 && minDeviation < 1/8) {
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
        pad: pad,
      );
    }
  }

  /// Generates reference hits data.
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

  void _prepareTrainingData() {
    _referenceHits.forEach((e) {
      e.matched = false;
    });

    _userHits.clear();
  }
}


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


typedef _UserHit = ({
  double beat,
  DrumPad pad,
  double deviation, // пока храним абсолютное значение, без знака рано или поздно. Потом исправим.
  int refIndex, // index of referenced note, -1 means no match
});

sealed class InputAnalysisResult {}

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

class ExtraHitResult extends InputAnalysisResult {
  final int repeatIndex;
  final double beat;
  final DrumPad pad;

  ExtraHitResult({
    required this.repeatIndex,
    required this.beat,
    required this.pad,
  });
}
