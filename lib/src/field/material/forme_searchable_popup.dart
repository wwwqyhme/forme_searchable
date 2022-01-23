import 'package:flutter/material.dart';

import 'dialog_configuration.dart';

abstract class FormeSearchablePopup {
  /// close popup
  void close(BuildContext context);

  /// build popup
  void open(
      BuildContext context, LayerLink layerLink, WidgetBuilder contentBuilder);

  /// whether popup is opened now
  bool get isOpened;
}

class FormeSearchableBottomSheetPopup extends FormeSearchablePopup {
  final FormeBottomSheetConfiguration? configuration;

  FormeSearchableBottomSheetPopup({
    this.configuration,
  });

  Future? _future;

  @override
  void close(BuildContext context) {
    if (_future != null) {
      Navigator.pop(context);
      _future = null;
    }
  }

  @override
  bool get isOpened => _future != null;

  @override
  void open(
      BuildContext context, LayerLink layerLink, WidgetBuilder contentBuilder) {
    _future = showModalBottomSheet<void>(
        backgroundColor: configuration?.backgroundColor,
        elevation: configuration?.elevation,
        shape: configuration?.shape,
        clipBehavior: configuration?.clipBehavior,
        constraints: configuration?.constraints,
        barrierColor: configuration?.barrierColor,
        isScrollControlled: configuration?.isScrollControlled ?? true,
        isDismissible: configuration?.isDismissible ?? true,
        transitionAnimationController:
            configuration?.transitionAnimationController,
        context: context,
        builder: (context) {
          return contentBuilder(context);
        }).whenComplete(() {
      _future = null;
    });
  }
}

class FormeSearchableOverlayPopup extends FormeSearchablePopup {
  OverlayEntry? _entry;

  @override
  void close(BuildContext context) {
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
    }
  }

  @override
  bool get isOpened => _entry != null;

  @override
  void open(
      BuildContext context, LayerLink layerLink, WidgetBuilder contentBuilder) {
    _entry = OverlayEntry(builder: (context) {
      return CompositedTransformFollower(
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        link: layerLink,
        child: LayoutBuilder(
          builder: (context, c) {
            return Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: layerLink.leaderSize?.width ?? double.infinity,
                ),
                child: contentBuilder(context),
              ),
            );
          },
        ),
      );
    });
    Overlay.of(context)!.insert(_entry!);
  }
}

class FormeSearchableDialogPopup extends FormeSearchablePopup {
  final FormeDialogConfiguration? configuration;
  Future? _future;

  FormeSearchableDialogPopup({this.configuration});
  @override
  void close(BuildContext context) {
    if (_future != null) {
      Navigator.pop(context);
      _future = null;
    }
  }

  @override
  bool get isOpened => _future != null;

  @override
  void open(
      BuildContext context, LayerLink layerLink, WidgetBuilder contentBuilder) {
    _future = showDialog<void>(
      barrierDismissible: configuration?.barrierDismissible ?? true,
      barrierColor: configuration?.barrierColor ?? Colors.black54,
      barrierLabel: configuration?.barrierLabel,
      useSafeArea: configuration?.useSafeArea ?? true,
      context: context,
      builder: (context) {
        return contentBuilder(context);
      },
    ).whenComplete(() {
      _future = null;
    });
  }
}
