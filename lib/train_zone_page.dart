import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';


class TrainZonePage extends StatefulWidget {
  const TrainZonePage({super.key, required this.title});

  final String title;

  @override
  State<TrainZonePage> createState() => _TrainZonePageState();
}

class _TrainZonePageState extends State<TrainZonePage> {
  final soloud = SoLoud.instance;
  final s = Stopwatch();
  late final AudioSource leftSound;
  late final AudioSource rightSound;

  @override
  void initState() {
    super.initState();

    _initSounds();
  }

  Future<void> _initSounds() async {
    await soloud.init(bufferSize: 64);
    leftSound = await soloud.loadAsset('assets/sounds/Clave Ekko Smash V6.wav');
    rightSound = await soloud.loadAsset('assets/sounds/Block 1 Ekko Smash V6.wav');

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
    s.start();

    switch (padId) {
      case DrumPadEnum.left:
        await soloud.play(leftSound);

      case DrumPadEnum.right:
        await soloud.play(rightSound);
    }


    s.stop();
    s.reset();
  }
}

String _getPadLabel(DrumPadEnum padId) {
  return switch (padId) {
    DrumPadEnum.left => 'Left Hand',
    DrumPadEnum.right => 'Right Hand'
  };
}

enum DrumPadEnum { left, right }
