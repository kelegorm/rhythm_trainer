import 'package:flutter/material.dart';
import 'package:rhythm_trainer/src/logic/drum_pattern.dart';
import 'package:rhythm_trainer/src/widgets/rhythm_view/scrolling_rhythm_view/paint_config.dart';

/// Draws the portion of the rhythm pattern that is visible within the viewport.
///
/// Coordinates are in logical pixels.
/// The rhythm scrolls from right to left, and [currentBeat] determines
/// what part of the pattern is currently visible.
///
/// The playhead (the vertical line indicating where beats are triggered)
/// is placed at a relative horizontal offset within the viewport.
///
/// Parameters:
/// - [canvas]: Target for drawing.
/// - [size]: Size of the viewport in logical pixels.
/// - [currentBeat]: Current position in the rhythm timeline, in beats.
/// - [viewportBeatsWidth]: Number of beats that fit within the viewport's width.
/// - [headPositionOffset]: Relative (0..1) horizontal position of the playhead,
///                         where 0.0 = left edge, 1.0 = right edge. Default is 0.3.
/// - [pattern]: Rhythm pattern to render.
/// - [beatsPerBar]: Number of beats in one bar (time signature numerator).
void paintScene({
  required Canvas canvas,
  required Size size,
  required double currentBeat,
  required double viewportBeatsWidth,
  double headPositionOffset = 0.3,
  required DrumPattern pattern,
  required int beatsPerBar,
}) {
  final layout = LayoutConfig(
    beatsInBar: beatsPerBar,
    viewportBeatsWidth: viewportBeatsWidth,
    headOffset: headPositionOffset,
    size: size,
    noteSize: .2
  );

  final viewport = ViewportConfig(currentBeat: currentBeat, layout: layout);

  _drawHorizontalLines(canvas, layout);

  _drawBarLines(canvas, pattern, layout, viewport);

  _drawRefNotes(canvas, pattern, layout, viewport);

  _drawPlayhead(canvas, layout);
}

void _drawHorizontalLines(Canvas canvas, LayoutConfig config) {
  canvas.drawLine(
      Offset(0, config.firstLineY),
      Offset(config.size.width, config.firstLineY),
      _horizontalLinePaint);

  canvas.drawLine(
      Offset(0, config.secondLineY),
      Offset(config.size.width, config.secondLineY),
      _horizontalLinePaint);
}

void _drawBarLines(Canvas canvas, DrumPattern pattern, LayoutConfig layout, ViewportConfig viewport) {
  for (var i = 0; i <= pattern.barsCount; i++) {
    final beatPos = i * layout.beatsInBar;

    if (beatPos >= viewport.viewportLeft && beatPos <= viewport.viewportRight) {
      final x = viewport.beatsToPx(beatPos.toDouble());
      canvas.drawLine(Offset(x, layout.barLineTopY), Offset(x, layout.barLineBottomY), _barLinePaint);
    }
  }
}

void _drawRefNotes(Canvas canvas, DrumPattern pattern, LayoutConfig layout, ViewportConfig viewport) {
  for (var note in pattern.notes) {

    if (viewport.isWithinViewport(note.startTime, radius: layout.noteSizeBeats/2)) {
      final x = viewport.beatsToPx(note.startTime);
      final y = note.pad == DrumPad.left ? layout.secondLineY : layout.firstLineY;

      _drawRefNote(canvas, layout, x, y);
    }
  }
}

void _drawRefNote(Canvas canvas, LayoutConfig layout, double x, double y) {
  canvas.drawCircle(Offset(x, y), layout.refNoteSizePx/2, _notePaint);
}

void _drawPlayhead(Canvas canvas, LayoutConfig layout) {
  canvas.drawLine(
      Offset(layout.headOffsetPx, 0),
      Offset(layout.headOffsetPx, layout.size.height),
      _playheadPaint);
}


final Paint _horizontalLinePaint = Paint()
  ..color = Colors.grey.shade700
  ..strokeWidth = 1
  ..style = PaintingStyle.stroke;

final Paint _barLinePaint = Paint()
  ..color = Colors.white70
  ..strokeWidth = 2
  ..style = PaintingStyle.stroke;

final Paint _notePaint = Paint()
  ..color = Colors.lightBlueAccent
  ..style = PaintingStyle.fill;

final Paint _playheadPaint = Paint()
  ..color = Colors.redAccent
  ..strokeWidth = 2
  ..style = PaintingStyle.stroke;