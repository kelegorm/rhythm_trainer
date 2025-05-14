import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/user_accuracy.dart';

/// User notes we collected from Training Engine.
class UserTap {
  final double beat; // или absoluteBeat, если есть повторения
  final DrumPad pad;
  /// Null means it's extra hit.
  final AccuracyLevel? accuracyLevel;

  UserTap({
    required this.beat,
    required this.pad,
    required this.accuracyLevel,
  });
}