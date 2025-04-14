import 'package:flutter/animation.dart';
import 'package:rhythm_trainer/src/logic/user_accuracy.dart';

class TapEffect {
  final Offset position;
  final AccuracyLevel? level;
  final DateTime startTime;

  TapEffect({
    required this.position,
    required this.level,
    required this.startTime,
  });
}