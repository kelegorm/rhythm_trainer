import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        child: ElevatedButton(
          onPressed: () {},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_getPadLabel(padId)),
          ),
        ),
      ),
    );
  }

  void _soundDrumPad(DrumPadEnum padId) async {
    // user have to turn haptic feedback in settings (its npt about permissions)
    // maybe other vibro functions or libs can do it without feedback settings
    // or maybe we can check that settings and suggest user to turn it on for additional experience
    HapticFeedback.lightImpact();

    switch (padId) {
      case DrumPadEnum.left:
        AudioPlayer()
            ..setPlayerMode(PlayerMode.lowLatency)
            ..play(AssetSource('sounds/Clave Ekko Smash V6.wav'));

      case DrumPadEnum.right:
        AudioPlayer()
          ..setPlayerMode(PlayerMode.lowLatency)
          ..play(AssetSource('sounds/Block 1 Ekko Smash V6.wav'));

    }
  }
}

String _getPadLabel(DrumPadEnum padId) {
  return switch (padId) {
    DrumPadEnum.left => 'Left Hand',
    DrumPadEnum.right => 'Right Hand'
  };
}

enum DrumPadEnum {
  left, right
}