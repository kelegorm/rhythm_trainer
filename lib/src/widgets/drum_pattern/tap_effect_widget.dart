import 'package:flutter/material.dart';
import 'package:rhythm_trainer/src/widgets/drum_pattern/tap_effect.dart';

typedef EffectFinished = void Function(TapEffect);

class TapEffectWidget extends StatefulWidget {
  final TapEffect effect;
  final EffectFinished onFinished;

  const TapEffectWidget({
    required this.effect,
    required this.onFinished,
    super.key,
  });

  @override
  State<TapEffectWidget> createState() => _TapEffectWidgetState();
}

class _TapEffectWidgetState extends State<TapEffectWidget> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      onEnd: () => widget.onFinished(widget.effect),
      builder: (context, value, child) {
        final scale = 1.0 + value * 0.6;         // от 1.0 до 1.6
        final opacity = 1.0 - value;             // от 1.0 до 0.0

        return Transform.translate(
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
      },
    );
  }
}