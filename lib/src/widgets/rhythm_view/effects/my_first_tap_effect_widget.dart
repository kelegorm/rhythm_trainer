import 'package:flutter/material.dart';
import 'package:rhythm_trainer/src/widgets/rhythm_view/effects/tap_effect.dart';
import 'package:rhythm_trainer/src/widgets/rhythm_view/tap_data.dart';

class MyFirstTapEffectWidget extends StatefulWidget implements TapEffect {
  @override
  final TapData effect;

  @override
  final EffectFinished onFinished;

  const MyFirstTapEffectWidget({
    required this.effect,
    required this.onFinished,
    super.key,
  });

  @override
  State<MyFirstTapEffectWidget> createState() => _MyFirstTapEffectWidgetState();
}


class _MyFirstTapEffectWidgetState extends State<MyFirstTapEffectWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _animation = _controller.drive<double>(Tween(begin: 0.0, end: 1.0));

    _controller.forward().whenComplete(() {
      widget.onFinished(widget.effect);
    });
  }


  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;

        final circleScale = 1.0 + value * 0.6;         // от 1.0 до 1.6
        final circleOpacity = 1.0 - value;             // от 1.0 до 0.0

        final beamProgress = (value - 0.2).clamp(0.0, 1.0).toDouble();
        final beamOpacity = (1.0 - beamProgress).clamp(0.0, 1.0).toDouble();
        final beamWidth = 20.0 - beamProgress * 14.0; // от 20 до 6

        return Stack(
          clipBehavior: Clip.none,
          children: [
            _buildBeam(beamOpacity, beamWidth),
            _buildCircleSplash(circleOpacity, circleScale),
          ],
        );
      },
    );
  }

  Widget _buildCircleSplash(double opacity, double scale) {
    return Transform.translate(
      // top: -15.0,
      // left: -15.0,
        offset: Offset(-15.0, -15.0),
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow,
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildBeam(double beamOpacity, double beamWidth) {
    return Transform.translate(
      offset: Offset(-beamWidth/2, -60.0),
      child: Opacity(
        opacity: beamOpacity,
        child: Container(
          width: beamWidth,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.yellow.withAlpha((255.0 * 0.0).round()),
                Colors.yellow.withAlpha((255.0 * 0.4).round()),
                Colors.yellow.withAlpha((255.0 * 0.0).round()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}