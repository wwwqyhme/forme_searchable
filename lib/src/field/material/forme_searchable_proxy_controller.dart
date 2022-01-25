import 'package:flutter/material.dart';

abstract class FormeSearchableProxyController {
  /// close popup
  void close();

  /// whether popup is opened now
  bool get isOpened;
}

class FormeSearchableRouteProxyController
    extends FormeSearchableProxyController {
  final Route route;
  final NavigatorState navigator;

  FormeSearchableRouteProxyController(
    this.route,
    this.navigator,
  );

  @override
  void close() {
    if (!isOpened) {
      return;
    }
    navigator.popUntil((route) {
      if (route == this.route) {
        navigator.pop();
        return true;
      }
      return false;
    });
  }

  @override
  bool get isOpened => route.isActive;
}

class FormeSearchableOverlayPopupController
    extends FormeSearchableProxyController {
  OverlayEntry? _entry;

  FormeSearchableOverlayPopupController(OverlayEntry entry) : _entry = entry;

  @override
  void close() {
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
    }
  }

  @override
  bool get isOpened => _entry != null;
}
