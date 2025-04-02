import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_trainer/drum_pattern.dart';
import 'package:rhythm_trainer/user_input_analyzer.dart';

void main() {
  test('Default value', () {
    expect(UserInputAnalyzer.defaultAccuracity, 1/2);
  });
  
  group('Short data', () {
    test('Zero notes (default tolerance)', () {
      final pattern = const DrumPattern([], 1);
      expect(getRes(pattern), 1/2);
    });

    test('Single note (default tolerance)', () {
      final pattern = const DrumPattern([DrumNote(DrumPad.left, 0.0)], 1);
      expect(getRes(pattern), 1/2);
    });
  });

  group('computeGridTolerance tests', () {
    test('Two notes in one beat', () {
      final pattern = DrumPattern([
        DrumNote(DrumPad.left, 0.0),
        DrumNote(DrumPad.right, 1.0)
      ], 1);

      expect(getRes(pattern), 1/2);
    });

    test('Minimal interval between two notes', () {
      final pattern = DrumPattern([
        DrumNote(DrumPad.left, 0.0),
        DrumNote(DrumPad.right, 1/8), // 1/8 of beat
        DrumNote(DrumPad.left, 1.0)   // 1/4 size
      ], 1);

      expect(getRes(pattern), 1/16);
    });

    test('Interval across pattern loop boundary', () {
      final pattern = DrumPattern([
        DrumNote(DrumPad.left, 0.0),
        DrumNote(DrumPad.right, 3.0 + 7/8), // 1/32 musical size before end
      ], 1);

      expect(getRes(pattern), 1/16);
    });

    test('Many notes, smallest interval in the middle', () {
      final pattern = DrumPattern([
        DrumNote(DrumPad.left, 0.0),
        DrumNote(DrumPad.right, 1.0),
        DrumNote(DrumPad.left, 1.0 + 1/4),
        DrumNote(DrumPad.right, 3.0)
      ], 1);

      expect(getRes(pattern), 1/8);
    });

    test('Long spare pattern (multiple bars)', () {
      final pattern = DrumPattern([
        DrumNote(DrumPad.left, 0.0),
        DrumNote(DrumPad.right, 4.0),
        DrumNote(DrumPad.left, 8.5),
      ], 3);

      expect(getRes(pattern), 1/2);
    });

    test('Notes more than bars', () {
      final pattern = DrumPattern([
        DrumNote(DrumPad.left, 0.0),
        DrumNote(DrumPad.right, 4.0),
        DrumNote(DrumPad.left, 4.0 + 1/4),
      ], 1);

      expect(getRes(pattern), 1/2);
    });
  });
}

double getRes(DrumPattern pattern) => UserInputAnalyzer.computeGridTolerance(pattern.notes, pattern.barsCount);
