import 'dart:ffi' as ffi;
// import 'dart:io' show Platform, Directory;
// import 'package:path/path.dart' as path;

final ffi.DynamicLibrary _dylib = ffi.DynamicLibrary.open("libfirst_try.so");

final myAdd = _dylib.lookupFunction<ffi.Int32 Function(ffi.Int32,ffi.Int32), int Function(int, int)>("myAdd");