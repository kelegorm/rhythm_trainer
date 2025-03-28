import 'package:flutter/material.dart';
import 'package:rhythm_trainer/drum_pattern.dart';
import 'package:rhythm_trainer/drum_pattern_widget.dart';
import 'package:rhythm_trainer/native_wrapper.dart';
import 'package:rhythm_trainer/samples_library.dart';
import 'package:rhythm_trainer/train_zone_bl.dart';


class TrainZonePage extends StatefulWidget {
  const TrainZonePage({required this.title, required this.pattern, super.key, });

  final String title;

  final DrumPattern pattern;

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
    final leftWavContent = await loadWave(DrumSound.block48);
    final rightWavContent = await loadWave(DrumSound.clave48);

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

  @override
  Widget build(BuildContext context) {
    var body = _buildMainScreen();
    return _buildScaffold(body);
  }

  Widget _buildMainScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildPattern(widget.pattern),
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

  Widget _buildPattern(DrumPattern pattern) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 70,
        width: double.infinity,
        child: DrumPatternWidget(pattern: pattern),
      ),
    );
  }
}

String _getPadLabel(DrumPadEnum padId) {
  return switch (padId) {
    DrumPadEnum.left => 'Left Hand',
    DrumPadEnum.right => 'Right Hand'
  };
}

enum DrumPadEnum { left, right }
