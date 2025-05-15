import 'package:flutter/material.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/exercise.dart';
import 'package:rhythm_trainer/src/logic/timing.dart';
import 'package:rhythm_trainer/src/logic/user_accuracy.dart';
import 'package:rhythm_trainer/train_zone_page.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final exercise = Exercise(
      pattern: makePattern(),
      repetitions: 4,
      accuracy: AverageQuarterAccuracy(0.8),
      timing: const Timing(tempo: 80.0, beatsPerBar: 4),
    );

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TrainZonePage(
        title: 'Flutter Demo Home Page',
        exercise: exercise,
      ),
    );
  }
}

DrumPattern makePattern() {
  return const DrumPattern(
      <DrumNote>[
        DrumNote(DrumPad.left, 0.0),
        DrumNote(DrumPad.right, 1.0),
        DrumNote(DrumPad.left, 2.0),
        DrumNote(DrumPad.left, 2.5),
        DrumNote(DrumPad.right, 3.0),
      ],
      1
  );
}