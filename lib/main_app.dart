import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:rhythm_trainer/exercise_screen/exercise_screen.dart';

import 'package:rhythm_trainer/exercises_list_screen/exercises_list_screen.dart';
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
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

/// GoRouter configuration.
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const ExercisesListScreen(),
    ),
    GoRoute(
      name: 'exercises list',
      path: '/exercises_list_screen',
      builder: (context, state) => const ExercisesListScreen(),
    ),
    GoRoute(
      name: 'exercise',
      path: '/exercise_screen/:index',
      // Здесь происходит передача параметров.
      // Удали комментарий, как разберёшься с этим.
      builder: (context, state) {
        final indexString = state.pathParameters['index'];
        final index = indexString != null ? int.tryParse(indexString) ?? 0 : 0;
        return ExerciseScreen(index: index);
      },
    ),
    GoRoute(
      name: 'train_zone_page',
      path: '/train_zone_page/:title/:repetitions/:accuracy/:tempo',
      // Здесь происходит передача параметров.
      // Удали комментарий, как разберёшься с этим.
      builder: (context, state) {
        final String title = state.pathParameters['title']!;
        final String? repetitionsString = state.pathParameters['repetitions'];
        final int repetitions = repetitionsString != null
            ? int.tryParse(repetitionsString) ?? 0
            : 0;
        final String? accuracyString = state.pathParameters['accuracy'];
        final double accuracy = accuracyString != null
            ? double.tryParse(accuracyString) ?? 0
            : 0;
        final String? tempoString = state.pathParameters['tempo'];
        final double tempo = tempoString != null
            ? double.tryParse(tempoString) ?? 0
            : 0;
        final Exercise exercise = Exercise(
          pattern: makePattern(),
          repetitions: repetitions,
          accuracy: AverageQuarterAccuracy(accuracy),
          tempo: tempo,
        );
        return TrainZonePage(
          title: title,
          exercise: exercise,
        );
      },
    ),
  ],
);

DrumPattern makePattern() {
  return const DrumPattern(<DrumNote>[
    DrumNote(DrumPad.left, 0.0),
    DrumNote(DrumPad.right, 1.0),
    DrumNote(DrumPad.left, 2.0),
    DrumNote(DrumPad.left, 2.5),
    DrumNote(DrumPad.right, 3.0),
  ], 1);
}
