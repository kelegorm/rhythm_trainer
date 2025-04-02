import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rhythm_trainer/drum_pattern.dart';
import 'package:rhythm_trainer/training_engine_events.dart';

abstract class TrainingEngine {
  /// Поток событий анализа (ноты, попадания, пропуски, повторы)
  Stream<TrainingEngineEvent> get events;

  TrainingEngine();

  /// Начинает отсчёт времени внутри анализатора
  void start();

  /// Анализирует очередной пользовательский удар
  /// [elapsedSeconds] - время (в секундах) с момента вызова start()
  void userHit({
    required double elapsedSeconds,
    required DrumPad pad,
  });

  /// Finish training before it's finished. User canceled.
  void stop();

  //TODO pause and resume methods
}