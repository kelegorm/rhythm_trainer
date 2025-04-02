import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_trainer/drum_pattern.dart';
import 'package:rhythm_trainer/user_input_analyzer.dart';

void main() {
  group('One hit tests', () {
    test('1. Early hit within threshold', () {
      final analyzer = makeA(basic);
      final result = analyzer.analyzeUserInput(pad: DrumPad.right, hitTimeSeconds: 0.98);

      expect(result, isA<NoteHitResult>());
      final hit = result as NoteHitResult;

      expect(hit.noteIndex, 1);
      expect(hit.pad, DrumPad.right);
      expect(hit.repeatIndex, 0);
      expect(hit.repeatAhead, false);
      expect(hit.deviation, closeTo(-0.02, 0.001));
      expect(hit.beat, closeTo(0.98, 0.001));
      expect(hit.absoluteBeat, closeTo(0.98, 0.001));
    });

    test('2. Late hit within threshold', () {
      final analyzer = makeA(basic);
      final result = analyzer.analyzeUserInput(pad: DrumPad.right, hitTimeSeconds: 1.12);

      expect(result, isA<NoteHitResult>());
      final hit = result as NoteHitResult;

      expect(hit.noteIndex, 1);
      expect(hit.pad, DrumPad.right);
      expect(hit.repeatIndex, 0);
      expect(hit.repeatAhead, false);
      expect(hit.deviation, closeTo(0.12, 0.001));
      expect(hit.beat, closeTo(1.12, 0.001));
      expect(hit.absoluteBeat, closeTo(1.12, 0.001));
    });

    test('3. Hit too far from any note (extra)', () {
      final analyzer = makeA(spaced);
      final result = analyzer.analyzeUserInput(pad: DrumPad.left, hitTimeSeconds: 0.7);

      expect(result, isA<ExtraHitResult>());
      final extra = result as ExtraHitResult;

      expect(extra.beat, closeTo(0.7, 0.001));
      expect(extra.absoluteBeat, closeTo(0.7, 0.001));
    });

    test('4. Hit exactly between two notes', () {
      final analyzer = makeA(basic);
      final result = analyzer.analyzeUserInput(pad: DrumPad.left, hitTimeSeconds: 0.5);

      expect(result, isA<NoteHitResult>());
      final hit = result as NoteHitResult;

      expect(hit.noteIndex, 0); // ближе к 0.0
      expect(hit.repeatIndex, 0);
      expect(hit.deviation, closeTo(0.5, 0.001));
    });

    test('5. Correct time but wrong pad', () {
      final analyzer = makeA(basic);
      final result = analyzer.analyzeUserInput(pad: DrumPad.right, hitTimeSeconds: 0.0);

      expect(result, isA<ExtraHitResult>());
    });

    test('6. Hit before first note of next repeat (repeatAhead)', () {
      final analyzer = makeA(basic, 2);
      final result = analyzer.analyzeUserInput(pad: DrumPad.left, hitTimeSeconds: 3.75);

      expect(result, isA<NoteHitResult>());
      final hit = result as NoteHitResult;

      expect(hit.noteIndex, 0);
      expect(hit.repeatIndex, 1);
      expect(hit.repeatAhead, true);
      expect(hit.deviation, closeTo(-0.25, 0.001));
      expect(hit.beat, closeTo(-0.25, 0.001));
      expect(hit.absoluteBeat, closeTo(3.75, 0.001));
    });
  });
}

/// We keep tempo 60 to make seconds and beat size equal, for easier test developing
UserInputAnalyzer makeA(DrumPattern p, [int repeats = 1, double tempo = 60.0]) {
  return UserInputAnalyzer(pattern: p, tempo: tempo, repeats: repeats);
}

const basic = DrumPattern([
  DrumNote(DrumPad.left, 0.0),
  DrumNote(DrumPad.right, 1.0),
], 1);

const spaced = DrumPattern([
  DrumNote(DrumPad.left, 0.0),
  DrumNote(DrumPad.right, 2.0),
], 1);

// const dense = DrumPattern([
//   DrumNote(DrumPad.left, 0.0),
//   DrumNote(DrumPad.right, 0.5),
//   DrumNote(DrumPad.left, 1.0),
//   DrumNote(DrumPad.right, 1.5),
// ], 1);
//
// const edgeQuarter = DrumPattern([
//   DrumNote(DrumPad.left, 0.0),
//   DrumNote(DrumPad.right, 3.75),
// ], 1);