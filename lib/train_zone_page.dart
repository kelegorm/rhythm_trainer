import 'package:flutter/material.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/drum_pattern_widget.dart';
import 'package:rhythm_trainer/log_widget.dart';
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
    return StreamBuilder<TrainingState>(
      stream: bl.states,
      initialData: bl.state,
      builder: (BuildContext context, AsyncSnapshot<TrainingState> snapshot) {
        return switch (snapshot.data) {
          InitialTrainingState initial => _buildInitScreen(initial),
          ReadyTrainingState ready => _buildReadyScreen(ready),
          PlayingTrainingState playing => _buildPlayingScreen(playing),
          PlayingDemoState demo => _buildDemoScreen(demo),
          null => throw UnimplementedError(),
        };
      },
    );
  }

  Widget _buildInitScreen(InitialTrainingState state) {
    return _buildScaffold(const Center(
      child: Text('Initializing'),
    ));
  }

  Widget _buildReadyScreen(ReadyTrainingState ready) {
    final buttons = <Widget>[
      FilledButton(
        child: Text('Start'),
        onPressed: () => _onBtnStart(),
      ),
      FilledButton(
        child: Text('Demo'),
        onPressed: () => _onBtnDemo(),
      ),
    ];
    return _buildScaffold(_buildMainScreen(buttons));
  }

  Widget _buildPlayingScreen(PlayingTrainingState playing) {
    final buttons = <Widget>[
      FilledButton(
        child: Text('Stop'),
        onPressed: () => _onBtnTrainingStop(),
      ),
    ];
    return _buildScaffold(_buildMainScreen(buttons));
  }

  Widget _buildDemoScreen(PlayingDemoState demoState) {
    final buttons = <Widget>[
      FilledButton(
        child: Text('Stop'),
        onPressed: () => _onBtnDemoStop(),
      ),
    ];
    return _buildScaffold(_buildMainScreen(buttons));
  }

  Widget _buildScaffold(Widget body) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(children: [
        body,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 120,
            child: LogWidget(
              stream: bl.log,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildMainScreen(List<Widget> buttons) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildPattern(widget.pattern),
        Row(
          children: buttons,
        ),
        _buildDrumPads(),
      ],
    );
  }

  Widget _buildDrumPads() {
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
        bl.trigLeftPad();

      case DrumPadEnum.right:
        bl.trigRightPad();
    }
  }

  Widget _buildPattern(DrumPattern pattern) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 70,
        width: double.infinity,
        child: DrumPatternWidget(pattern: pattern, events: bl.rhythmEvents, lastEvent: bl.lastRhythmEvent),
      ),
    );
  }

  void _onBtnStart() {
    bl.startTraining();
  }

  void _onBtnDemo() {
    bl.startDemo();
  }

  void _onBtnDemoStop() {
    bl.stop();
  }

  void _onBtnTrainingStop() {
    bl.stop();
  }
}

String _getPadLabel(DrumPadEnum padId) {
  return switch (padId) {
    DrumPadEnum.left => 'Left Hand',
    DrumPadEnum.right => 'Right Hand'
  };
}

