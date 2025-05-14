import 'package:flutter/widgets.dart';
import 'package:rhythm_trainer/src/widgets/rhythm_view/tap_data.dart';

typedef EffectFinished = void Function(TapData effect);

abstract class TapEffect extends Widget {
  final TapData effect;
  final EffectFinished onFinished;

  const TapEffect({
    required this.effect,
    required this.onFinished,
    super.key,
  });
}