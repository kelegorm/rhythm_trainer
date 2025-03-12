import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rhythm_trainer/native_wrapper.dart';
import 'package:wav_io/wav_io.dart';


class TrainZonePage extends StatefulWidget {
  const TrainZonePage({super.key, required this.title});

  final String title;

  @override
  State<TrainZonePage> createState() => _TrainZonePageState();
}

class _TrainZonePageState extends State<TrainZonePage> {

  @override
  void initState() {
    super.initState();

    _initSounds();
  }

  Future<void> _initSounds() async {
    initializeAudio((result) async {
      if (result == 0) {
        print('Flutter: Audio Inited');
      } else {
        print("Failed to init audio. Error code: $result");
      }

      //todo mark audio is loaded and update state
      await _setDrumSamples();

      _setSequence();
    });
  }

  Future<void> _setDrumSamples() async {
    final leftWavContent = await _loadWave('assets/sounds/Block 1 Ekko Smash V6 48.wav');
    final rightWavContent = await _loadWave('assets/sounds/Clave Ekko Smash V6 48.wav');

    setDrumSamplesAsync(leftWavContent, rightWavContent, (int result) {
      print('Drum samples set with result: $result');
    });
  }

  void _setSequence() {
    final simpleNotes = <NoteData>[
      NoteData(0, 0.0),
      NoteData(1, 1.0),
      NoteData(0, 2.0),
      NoteData(0, 2.5),
      NoteData(1, 3.0),
    ];

    setDrumSequence(simpleNotes, 4.0);
  }

  Future<Float32List> _loadWave(String assetName) async {
    ByteData data = await rootBundle.load(assetName);
    var result = loadWav(data);
    if (result.isError) {
      throw Exception("Can't load file");
    }

    IWavContent wav = result.unwrap();

    if (wav.isMono) {
      wav = wav.monoToStereo();
    }
    if (!wav.isStereo) throw Exception('Wav should be mono or stereo');

    if (wav.sampleRate != 48000) throw Exception("Unsupported wav sampleRate: ${wav.sampleRate}. Should be 48kHz");

    final leftChannel = wav.toFloat32().samplesStorage.samplesData[0];
    final rightChannel = wav.toFloat32().samplesStorage.samplesData[1];

    final interleaved = Float32List(leftChannel.length + rightChannel.length);
    for (int i = 0; i < leftChannel.length; i++) {
      interleaved[i * 2] = leftChannel[i];
      interleaved[i * 2 + 1] = rightChannel[i];
    }

    // return Float32List.view(data.buffer);

    return interleaved;
  }

  @override
  Widget build(BuildContext context) {
    var body = _buildMainScreen();
    return _buildScaffold(body);
  }

  Widget _buildMainScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildButtons(),
      ],
    );
  }

  Widget _buildScaffold(Widget body) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: body,
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        spacing: 5.0,
        children: [
          Expanded(child: _buildDrumPad(DrumPadEnum.left)),
          Expanded(child: _buildDrumPad(DrumPadEnum.right)),
        ],
      ),
    );
  }

  Widget _buildDrumPad(DrumPadEnum padId) {
    return Listener(
      onPointerDown: (_) => _soundDrumPad(padId),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.red,
          ),
          child: Center(
            child: Text(_getPadLabel(padId)),
          ),
        ),
      ),
    );
  }

  void _soundDrumPad(DrumPadEnum padId) async {
    switch (padId) {
      case DrumPadEnum.left:
        playLeft();

      case DrumPadEnum.right:
        playRight();
    }
  }
}

String _getPadLabel(DrumPadEnum padId) {
  return switch (padId) {
    DrumPadEnum.left => 'Left Hand',
    DrumPadEnum.right => 'Right Hand'
  };
}

enum DrumPadEnum { left, right }
