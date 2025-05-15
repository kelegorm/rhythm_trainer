import 'dart:async';

import 'package:rhythm_trainer/midi_listener.dart';
import 'package:rhythm_trainer/native_wrapper.dart' as aud;
import 'package:rhythm_trainer/samples_library.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/logic/exercise.dart';
import 'package:rhythm_trainer/src/logic/simple_training_engine.dart';
import 'package:rhythm_trainer/src/logic/training_engine.dart';
import 'package:rhythm_trainer/src/logic/training_engine_events.dart';

enum DrumPadEnum { left, right }

class TrainingPageBL {
  TrainingState get state => _state;

  Stream<TrainingState> get states => _stateCtrl.stream;

  Stream<String> get log => _logCtrl.stream;

  Stream<TrainingEngineEvent> get rhythmEvents => _rhythmEvents;
  TrainingEngineEvent get  lastRhythmEvent => _engine.event;


  TrainingPageBL({required Exercise exercise}) : _exercise = exercise {
    _engine = SimpleTrainingEngine(
      exercise: _exercise,
    );

    _rhythmEvents = _engine.events.asBroadcastStream();
    _rhythmEvents.listen(_testListening);
  }


  void prepareScene() async {
    await _initEngine();
    //todo mark audio is loaded and update state
    await _setDrumSamples();

    _setSequence();

    await _setSceneSettings();

    _midiInputHandler = MidiInputHandler(logger: _logCtrl.sink);
    await _midiInputHandler.init();

    _midiInputHandler.stream.listen(_onMidi);

    _setState(ReadyTrainingState());
  }

  void startTraining() {
    _engine.start();
    aud.runScene(metronomeEnabled: true, sequenceEnabled: false, tempo: _exercise.timing.tempo);
    _setState(PlayingTrainingState());
  }

  void startDemo() {
    aud.runScene(metronomeEnabled: true, sequenceEnabled: true, tempo: _exercise.timing.tempo);
    _setState(PlayingDemoState());
  }

  void stop() {
    _engine.stop();
    aud.stopScene();
    _setState(ReadyTrainingState());
  }

  void trigLeftPad() {
    aud.playLeft();
    _engine.userHit(DrumPad.left);
  }

  void trigRightPad() {
    aud.playRight();
    _engine.userHit(DrumPad.right);
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

  Future<void> _setSceneSettings() async {
    //TODO set metronome preroll
  }

  void _setState(TrainingState newState) {
    _state = newState;
    _stateCtrl.add(newState);
  }

  void _onMidi(DrumPad event) {
    switch (event) {
      case DrumPad.left:
        trigLeftPad();
      case DrumPad.right:
        trigRightPad();
    }
  }

  final Exercise _exercise;

  void _testListening(TrainingEngineEvent event) {
    switch (event) {
      case NoteHit hit:
        _logCtrl.add("Note: ${hit.noteIndex}, deviation: ${hit.deviation}");

      default:
    }
  }

  late final TrainingEngine _engine;

  late final MidiInputHandler _midiInputHandler;
  TrainingState _state = InitialTrainingState();
  final StreamController<TrainingState> _stateCtrl = StreamController<TrainingState>();

  late final Stream<TrainingEngineEvent> _rhythmEvents;

  final StreamController<String> _logCtrl = StreamController<String>();
}

sealed class TrainingState {}

/// Initial state means scene is not ready.
class InitialTrainingState extends TrainingState {}

/// Means everything is ready to start.
class ReadyTrainingState extends TrainingState {}

/// PLaying means metronome is run, training is going.
class PlayingTrainingState extends TrainingState {}

class PlayingDemoState extends TrainingState {}