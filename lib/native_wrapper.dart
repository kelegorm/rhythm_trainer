import 'dart:ffi' as ffi;
// import 'dart:io' show Platform, Directory;
// import 'package:path/path.dart' as path;

final ffi.DynamicLibrary _soundPlayerLib = ffi.DynamicLibrary.open("libsound_player.so");

final playLeft = _soundPlayerLib.lookupFunction<ffi.Void Function(), void Function()>("playLeft");