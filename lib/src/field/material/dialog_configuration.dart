import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

class FormeBottomSheetConfiguration {
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final Color? barrierColor;
  final bool isScrollControlled;
  final bool isDismissible;
  final AnimationController? transitionAnimationController;

  FormeBottomSheetConfiguration({
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.barrierColor,
    this.transitionAnimationController,
    this.isDismissible = true,
    this.isScrollControlled = false,
  });
}

class FormeDialogConfiguration {
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final bool useSafeArea;

  FormeDialogConfiguration({
    this.barrierDismissible = true,
    this.barrierColor,
    this.barrierLabel,
    this.useSafeArea = true,
  });
}
