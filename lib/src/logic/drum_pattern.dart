import 'package:meta/meta.dart';

@immutable
class DrumPattern {
  final int barsCount;
  final Iterable<DrumNote> notes;

  const DrumPattern(this.notes, this.barsCount) : assert(barsCount > 0);
}


@immutable
class DrumNote {
  final DrumPad pad;
  /// note start time in beats.
  final double startTime;

  const DrumNote(this.pad, this.startTime);
}


enum DrumPad {
  left(id: 0),
  right(id: 1);

  const DrumPad({required this.id});

  final int id;
}