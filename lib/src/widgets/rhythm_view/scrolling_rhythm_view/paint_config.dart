import 'dart:ui';

class LayoutConfig {
  final Size size;
  final int beatsInBar;
  final double viewportBeatsWidth;

  /// Beat length in pixels.
  late final double pxPerBeat;
  late final double headOffsetPx;

  late final double firstLineY;
  late final double secondLineY;
  late final double barLineTopY;
  late final double barLineBottomY;

  late final double refNoteSizePx;
  late final double noteSizeBeats;

  late final double headOffsetBeats;

  LayoutConfig({
    required this.size,
    required this.viewportBeatsWidth,
    required this.beatsInBar,
    required double headOffset, // 0..1,  play-head position on the screen
    double noteSize = 0.1,  // relative size on reference note
    double linesGap = 0.33,   // 0..1, gap between rhythm lines relativily to the height
    double barLineInset = 0.1, // 0..0.5, cut for bar lines
  })  : assert(beatsInBar > 0),
        assert(headOffset >=0 && headOffset < 1),
        assert(linesGap >= 0 && linesGap < 1),
        assert(barLineInset >= 0 && barLineInset < 0.5)
  {
    pxPerBeat = size.width / viewportBeatsWidth;
    headOffsetPx = size.width * headOffset;

    firstLineY = size.height * (1 - linesGap) * 0.5;
    secondLineY = size.height - firstLineY;

    barLineTopY = size.height * barLineInset;
    barLineBottomY = size.height * (1 - barLineInset);

    refNoteSizePx = noteSize * size.height;
    noteSizeBeats = refNoteSizePx / pxPerBeat;

    headOffsetBeats = headOffset * viewportBeatsWidth;
  }
}

class ViewportConfig {
  final double currentBeat;
  final LayoutConfig layout;

  late final double viewportLeft;
  late final double viewportRight;

  ViewportConfig({
    required this.currentBeat,
    required this.layout,
  }) {
    viewportLeft = currentBeat - layout.headOffsetBeats;
    viewportRight = viewportLeft + layout.viewportBeatsWidth;
  }

  double beatsToPx(double beatPos) {
    return (beatPos - viewportLeft) * layout.pxPerBeat;
  }

  bool isWithinViewport(double beats, {required double radius}) {
    return (beats + radius) >= viewportLeft
        && (beats - radius) <= viewportRight;
  }
}