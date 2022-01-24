import 'dart:async';

import 'package:flutter/material.dart';

abstract class FormeSearchablePopupController {
  /// close popup
  void close();

  /// whether popup is opened now
  bool get isOpened;
}

class FormeSearchableCompleterPopupController
    extends FormeSearchablePopupController {
  final Completer completer;
  final VoidCallback _close;

  FormeSearchableCompleterPopupController(this.completer, this._close);

  @override
  void close() {
    if (completer.isCompleted) {
      return;
    }
    _close();
  }

  @override
  bool get isOpened => !completer.isCompleted;
}

class FormeSearchableOverlayPopupController
    extends FormeSearchablePopupController {
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
