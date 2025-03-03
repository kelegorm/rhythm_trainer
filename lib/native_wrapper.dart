import 'dart:ffi';

final DynamicLibrary _soundPlayerLib = DynamicLibrary.open("libsound_player.so");

//--------------------------------------
// Play Left Function
//--------------------------------------

final playLeft = _soundPlayerLib.lookupFunction<Void Function(), void Function()>("playLeft");

//--------------------------------------
// Play Right Function
//--------------------------------------

final playRight = _soundPlayerLib.lookupFunction<Void Function(), void Function()>("playRight");

//--------------------------------------
// Initialize Audio Function
//--------------------------------------

typedef _CppInitCallback = Void Function(Int32);
typedef InitializeAudioCallback = void Function(int);

/// Starts audio initialisation on native side. Calls callback after it's
/// finished.
void initializeAudio(InitializeAudioCallback callback) {
  if (_audioInitCallback != null) {
    throw Exception('Audio is already initializating!');
  }

  _audioInitCallback = callback;

  final nativeCallbackPointer = Pointer.fromFunction<Void Function(Int32)>(initializeAudioNativeCallback);
  _initializeAudioRemote(nativeCallbackPointer);
}

InitializeAudioCallback? _audioInitCallback;
void initializeAudioNativeCallback(int result) {
  final callback = _audioInitCallback;
  _audioInitCallback = null;

  if (callback != null) {
    callback(result);
  } else {
    throw Exception('_audioInitCallback is null, but should not.');
  }
}

final _initializeAudioRemote = _soundPlayerLib.lookupFunction<
    Void Function(Pointer<NativeFunction<_CppInitCallback>>),
    void Function(Pointer<NativeFunction<_CppInitCallback>>)
>("initializeAudio");