import 'package:flutter/material.dart';
import 'package:rhythm_trainer/native_wrapper.dart';

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
    initializeAudio();
    //todo mark audio is loaded and update state
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
