import 'dart:async';

import 'package:rhythm_trainer/drum_pattern.dart';
import 'package:rhythm_trainer/native_wrapper.dart' as aud;
import 'package:rhythm_trainer/samples_library.dart';

enum DrumPadEnum { left, right }

class TrainingPageBL {
  final DrumPattern pattern;

  TrainingState get state => _state;
  Stream<TrainingState> get states => _stateCtrl.stream;
  TrainingState _state = InitialTrainingState();
  final StreamController<TrainingState> _stateCtrl = StreamController<TrainingState>();

  TrainingPageBL({required this.pattern});

  void prepareScene() async {
    await _initEngine();
    //todo mark audio is loaded and update state
    await _setDrumSamples();

    _setSequence();

    await _setSceneSettings();

    _setState(ReadyTrainingState());
  }

  void startTraining() {
    _setState(PlayingTrainingState());
    // aud.
  }

  Future<void> _setSceneSettings() async {
    //TODO set metronome preroll
  }

  void startDemo() {
    _setState(PlayingDemoState());
  }

  void stop() {
    _setState(ReadyTrainingState());
  }

  void trigLeftPad() {
    aud.playLeft();
  }

  void trigRightPad() {
    aud.playRight();
  }

  Future<void> _initEngine() async {
    final completer = Completer<void>();

    aud.initializeAudio((result) async {
      if (result == 0) {
        print('Flutter: Audio Inited');
      } else {
        print("Failed to init audio. Error code: $result");
      }
      completer.complete();
    });

    return completer.future;
  }

  Future<void> _setDrumSamples() async {
    final leftWavContent = await loadWave(DrumSound.block48);
    final rightWavContent = await loadWave(DrumSound.clave48);

    aud.setDrumSamplesAsync(leftWavContent, rightWavContent, (int result) {
      print('Drum samples set with result: $result');
    });
  }

  void _setSequence() {
    final simpleNotes = <aud.NoteData>[
      aud.NoteData(0, 0.0),
      aud.NoteData(1, 1.0),
      aud.NoteData(0, 2.0),
      aud.NoteData(0, 2.5),
      aud.NoteData(1, 3.0),
    ];

    aud.setDrumSequence(simpleNotes, 4.0);
  }

  void _setState(TrainingState newState) {
    _state = newState;
    _stateCtrl.add(newState);
  }
}

sealed class TrainingState {}

/// Initial state means scene is not ready.
class InitialTrainingState extends TrainingState {}

/// Means everything is ready to start.
class ReadyTrainingState extends TrainingState {}

/// PLaying means metronome is run, training is going.
class PlayingTrainingState extends TrainingState {}

class PlayingDemoState extends TrainingState {}