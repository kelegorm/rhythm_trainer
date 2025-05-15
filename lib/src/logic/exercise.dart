import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/timing.dart';
import 'package:rhythm_trainer/src/logic/user_accuracy.dart';

class Exercise {
  final Timing timing;
  final DrumPattern pattern;
  final int repetitions;
  final UserAccuracy accuracy;

  Exercise({
    required this.pattern,
    required this.repetitions,
    required this.accuracy,
    required this.timing,
  }) : assert(repetitions > 0);
}