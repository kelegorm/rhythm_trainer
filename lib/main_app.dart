import 'package:flutter/material.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/exercise.dart';
import 'package:rhythm_trainer/src/logic/user_accuracy.dart';
import 'package:rhythm_trainer/train_zone_page.dart';

const title = "Two Hand Hero";

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final exercise = Exercise(
      pattern: makePattern(),
      repetitions: 4,
      accuracy: AverageQuarterAccuracy(0.8),
      tempo: 80.0,
    );

    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TrainZonePage(
        title: title,
        exercise: exercise,
      ),
    );
  }
}

DrumPattern makePattern() {
  return DrumPattern(
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