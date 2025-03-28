import 'package:flutter/material.dart';
import 'package:rhythm_trainer/drum_pattern.dart';
import 'package:rhythm_trainer/train_zone_page.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final pattern = makePattern();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TrainZonePage(
        title: 'Flutter Demo Home Page',
        pattern: pattern,
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