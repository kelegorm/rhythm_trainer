import 'dart:ffi' as ffi;

final ffi.DynamicLibrary _soundPlayerLib = ffi.DynamicLibrary.open("libsound_player.so");

final playLeft = _soundPlayerLib.lookupFunction<ffi.Void Function(), void Function()>("playLeft");
final playRight = _soundPlayerLib.lookupFunction<ffi.Void Function(), void Function()>("playRight");

final initializeAudio = _soundPlayerLib.lookupFunction<ffi.Void Function(), void Function()>("initializeAudio");