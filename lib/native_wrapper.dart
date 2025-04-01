import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

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

//--------------------------------------
// Set Drums Samples Function
//--------------------------------------

/// Sets wav data for drum sounds.
///
/// Uint8List should contain only pure wave data, no headers or anything.
void setDrumSamplesAsync(
    Float32List leftFloats,
    Float32List rightFloats,
    void Function(int) callback
  ) {
  Future.microtask(() {
    final leftPtr = calloc<Float>(leftFloats.length);
    for (int i = 0; i < leftFloats.length; i++) {
      (leftPtr + i).value = leftFloats[i];
    }

    final rightPtr = calloc<Float>(rightFloats.length);
    for (int i = 0; i < rightFloats.length; i++) {
      (rightPtr + i).value = rightFloats[i];
    }

    final leftLength = (leftFloats.length / 2).toInt();
    final rightLength = (rightFloats.length / 2).toInt();

    final result = _setDrumSamples(leftPtr, leftLength, rightPtr, rightLength);

    calloc.free(leftPtr);
    calloc.free(rightPtr);

    return result;
  }).then((int result) {
    callback(result);
  }).catchError((error) {
    // Обработка ошибок, если необходимо.
    print("Error in setDrumSamplesAsync: $error");
  });
}

typedef _SetDrumSamplesNative = Int32 Function(
    Pointer<Float> leftData,
    Int32 leftLength,
    Pointer<Float> rightData,
    Int32 rightLength,
);

typedef _SetDrumSamplesDart = int Function(
    Pointer<Float> leftData,
    int leftLength,
    Pointer<Float> rightData,
    int rightLength,
);

final _SetDrumSamplesDart _setDrumSamples = _soundPlayerLib
    .lookup<NativeFunction<_SetDrumSamplesNative>>("setDrumSamples")
    .asFunction();


//--------------------------------------
// Set Drum Sequence Function
//--------------------------------------

/// Sets sequence. Note
void setDrumSequence(List<NoteData> notes, double length) {
  final Pointer<NoteFFI> notesPtr = calloc<NoteFFI>(notes.length);
  for (int i = 0; i < notes.length; i++) {
    (notesPtr + i).ref
      ..noteId = notes[i].noteId
      ..startBeat = notes[i].startBeat;
  }

  final Pointer<SequenceFFI> sequencePtr = calloc<SequenceFFI>();
  sequencePtr.ref
    ..notes = notesPtr
    ..noteCount = notes.length
    ..lengthInBeats = length;

  final result = _setDrumSequence(sequencePtr);

  calloc.free(notesPtr);
  calloc.free(sequencePtr);

  if (result != 0) {
    print("Failed to set drum sequence");
  } else {
    print("Drum sequence was set successfully");
  }
}

/// note info to pass to ffi function.
final class NoteData {
  final int noteId;
  final double startBeat;

  NoteData(this.noteId, this.startBeat)
      : assert(noteId >= 0),
        assert(startBeat >= 0.0
  );
}

final class NoteFFI extends Struct {
  @Int32()
  external int noteId;

  @Double()
  external double startBeat;
}

final class SequenceFFI extends Struct {
  external Pointer<NoteFFI> notes;

  @Int32()
  external int noteCount;

  @Double()
  external double lengthInBeats;
}

typedef _SetDrumSequenceNative = Int32 Function(
    Pointer<SequenceFFI> leftData
);

typedef _SetDrumSequenceDart = int Function(
    Pointer<SequenceFFI> leftData
);

final _SetDrumSequenceDart _setDrumSequence = _soundPlayerLib
    .lookup<NativeFunction<_SetDrumSequenceNative>>("setDrumSequence")
    .asFunction();


//--------------------------------------
// Run Scene Function
//--------------------------------------

/// Calls the native runScene function.
void runScene({
  required bool metronomeEnabled,
  required bool sequenceEnabled,
  required double tempo,
}) {
  _runScene(metronomeEnabled ? 1 : 0, sequenceEnabled ? 1 : 0, tempo);
}

/// FFI: Calls native runScene function.
///
/// Parameters:
/// - [metronomeEnabled]: enables/disables metronome sound.
/// - [sequenceEnabled]: enables/disables sequence.
/// - [tempo]: tempo as a float value.
typedef _RunSceneNative = Void Function(
    Int8 metronomeEnabled,
    Int8 sequenceEnabled,
    Double tempo
  );

typedef _RunSceneDart = void Function(
    int metronomeEnabled,
    int sequenceEnabled,
    double tempo
  );

final _RunSceneDart _runScene = _soundPlayerLib
    .lookup<NativeFunction<_RunSceneNative>>("runScene")
    .asFunction();

//--------------------------------------
// Stop Scene Function
//--------------------------------------

/// Calls the native stopScene function.
void stopScene() {
  _stopScene();
}

/// FFI: Calls native stopScene function.
typedef _StopSceneNative = Void Function();

typedef _StopSceneDart = void Function();

final _StopSceneDart _stopScene = _soundPlayerLib
    .lookup<NativeFunction<_StopSceneNative>>("stopScene")
    .asFunction();
