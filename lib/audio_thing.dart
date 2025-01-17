import 'package:flutter/services.dart';

const platform = MethodChannel("rhythm_trainer.kelegorm.com/sound");

Future<void> playSound() async {
  try {
    await platform.invokeMethod('playSound');
  } on PlatformException catch (e) {
    print("Failed to invoke native method: ${e.message}");
  }
}