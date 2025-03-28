import 'package:flutter/material.dart';
import 'package:rhythm_trainer/drum_pattern.dart';
import 'package:rhythm_trainer/drum_pattern_widget.dart';
import 'package:rhythm_trainer/train_zone_bl.dart';


class TrainZonePage extends StatefulWidget {
  const TrainZonePage({required this.title, required this.pattern, super.key, });

  final String title;
  final DrumPattern pattern;

  @override
  State<TrainZonePage> createState() => _TrainZonePageState();
}

class _TrainZonePageState extends State<TrainZonePage> {
  late TrainingPageBL bl;

  @override
  void initState() {
    super.initState();

    bl = TrainingPageBL(pattern: widget.pattern);
    bl.prepareScene();
  }

  @override
  void didUpdateWidget(TrainZonePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pattern != widget.pattern) {
      // todo something
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (bl.state) {
      InitialTrainingState initial => _buildInitScreen(initial),
      ReadyTrainingState ready => _buildReadyScreen(ready),
      PlayingTrainingState playing => _buildPlayingScreen(playing),
    };
  }

  Widget _buildInitScreen(InitialTrainingState state) {
    return _buildScaffold(_buildMainScreen());
  }

  Widget _buildReadyScreen(ReadyTrainingState ready) {
    return _buildScaffold(_buildMainScreen());
  }

  Widget _buildPlayingScreen(PlayingTrainingState playing) {
    return _buildScaffold(_buildMainScreen());
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
        bl.playLeft();

      case DrumPadEnum.right:
        bl.playRight();
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

