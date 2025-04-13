sealed class UserAccuracy {
  /// [userNoteDeviation] is difference between reference and user notes.
  AccuracyResult inspect(double userNoteDeviation);
}

class AccuracyResult {
  /// Number from 0 to 1. 1 means 100% accuracy.
  final double accuracy;
  final AccuracyLevel level;

  AccuracyResult(this.accuracy, this.level);
}

enum AccuracyLevel {
  perfect,
  great,
  ok,
  miss,
}

class AverageQuarterAccuracy extends UserAccuracy {
  /// Target accuracy, from 0 to 1.
  ///
  /// 1 means 100% accuracy.
  final double target;

  AverageQuarterAccuracy(this.target) : assert(target > 0 && target < 1);

  @override
  AccuracyResult inspect(double userNoteDeviation) {
    const maxDeviation = 0.5;

    final deviation = userNoteDeviation.abs();
    final accuracy = (1 - (deviation / maxDeviation)).clamp(0.0, 1.0).toDouble();

    return AccuracyResult(
      accuracy,
      _getLevel(accuracy),
    );
  }

  AccuracyLevel _getLevel(double accuracy) {
    final offset = (1.0 - target);

    if (accuracy >= target + offset * 0.66) {
      return AccuracyLevel.perfect;
    } else if (accuracy >= target + offset * 0.33) {
      return AccuracyLevel.great;
    } else if (accuracy >= target) {
      return AccuracyLevel.ok;
    } else {
      return AccuracyLevel.miss;
    }
  }
}