import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/user_accuracy.dart';

class Exercise {
  /// Temp in BPM.
  final double tempo;
  final DrumPattern pattern;
  final int repetitions;
  final UserAccuracy accuracy;

  Exercise({
    required this.pattern,
    required this.repetitions,
    required this.accuracy,
    required this.tempo,
  }) : assert(repetitions > 0), assert(tempo > 0);
}