import 'dart:async';

import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/training_engine_events.dart';

abstract class TrainingEngine {
  /// Поток событий анализа (ноты, попадания, пропуски, повторы)
  Stream<TrainingEngineEvent> get events;
  TrainingEngineEvent get event;


  TrainingEngine();


  /// Начинает отсчёт времени внутри анализатора
  void start();

  /// Анализирует очередной пользовательский удар.
  void userHit(DrumPad pad);

  /// Finish training before it's finished. User canceled.
  void stop();

  //TODO pause and resume methods
}