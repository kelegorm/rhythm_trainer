class DrumPattern {
  final int barsCount;
  final Iterable<DrumNote> notes;

  DrumPattern(this.notes, this.barsCount) : assert(barsCount > 0);
}

class DrumNote {
  final DrumPad pad;
  /// note start time in beats.
  final double startTime;

  DrumNote(this.pad, this.startTime);
}

enum DrumPad {
  left,
  right
}