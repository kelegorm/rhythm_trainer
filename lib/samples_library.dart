import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:wav_io/wav_io.dart';

enum DrumSound {
  block48(file: 'assets/sounds/Block 1 Ekko Smash V6 48.wav'),
  clave48(file: 'assets/sounds/Clave Ekko Smash V6 48.wav');

  const DrumSound({required this.file});

  final String file;
}

Future<Float32List> loadWave(DrumSound sound) async {
  ByteData data = await rootBundle.load(sound.file);
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

  return interleaved;
}