import 'dart:async';

import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';

class MidiInputHandler {
  final _controller = StreamController<DrumPad>.broadcast();

  Stream<DrumPad> get stream => _controller.stream;

  final StreamSink<String> logger;

  MidiInputHandler({required this.logger});

  Future<void> init() async {
    final midi = MidiCommand();

    midi.onMidiDataReceived?.listen(_handleMidiMessage);
    // await _midi.startScanningForBluetoothDevices(); // можно опустить, если USB

    final devices = await midi.devices;

    logger.add("Loaded midi devices. Count: ${devices?.length}");

    final knownDevices = <MidiDevice>[];
    var i = 0;
    devices?.forEach((device) {
      final isKnown = whitelist.any((vendor) => device.name.toLowerCase().contains(vendor));

      if (isKnown) {
        knownDevices.add(device);
        logger.add("${i++}. Known device ${device.name}");
      } else {
        logger.add("${i++}. Unknown device ${device.name}");
      }
    });

    if (knownDevices.isNotEmpty) {
      await midi.connectToDevice(knownDevices.first);
      logger.add('Connected to ${knownDevices.first.name}');
    } else {
      logger.add("There is no real MIDI devices");
    }
  }

  void _handleMidiMessage(MidiPacket packet) {
    logger.add("Got some midi event!");
    // _controller.add(DrumPad.left);
    // return;

    final data = packet.data;

    if (data.length >= 3) {
      final status = data[0] & 0xF0;
      final note = data[1];
      final velocity = data[2];

      if (status == 0x90 && velocity > 0) {
        // Note On
        if (note == 60) {
          _controller.add(DrumPad.left);
        } else if (note == 62) {
          _controller.add(DrumPad.right);
        }
      }
    }
  }

  void dispose() {
    _controller.close();
    MidiCommand().teardown();
  }
}

final Set<String> whitelist = {
  'akai',
  'lpk', // akai lpk
  'mpk', // akai mpk
  'alesis',
  'arturia',
  'behringer',
  'cme',
  'impact',
  'keystation',
  'komplete kontrol',
  'korg',
  'launchkey',
  'launchpad',
  'm-audio',
  'midiplus',
  'microkey',
  'native instruments',
  'nektar',
  'novation',
  'oxygen',
  'roland',
  'yamaha',
};

