/// Holds time signature and tempo information for a rhythm exercise.
class Timing {
  /// Tempo in beats per minute (BPM).
  final double tempo;

  ///Number of beats in one bar (time signature numerator).
  final int beatsPerBar;

  const Timing({
    this.tempo = 80.0,
    this.beatsPerBar = 4,
  }) : assert(tempo > 0, beatsPerBar > 0);
}