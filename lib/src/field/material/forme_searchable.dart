import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import 'dialog_configuration.dart';
import 'forme_page_result.dart';
import 'forme_searchable_content.dart';
import 'popup_type.dart';

typedef FormeQuery<T extends Object> = Future<FormeSearchablePageResult<T>>
    Function(Map<String, dynamic> condition, int currentPage);
typedef FormeSearchableSelectedItemsBuilder<T extends Object> = Widget Function(
    BuildContext context, List<T> selected, ValueChanged<T> onDelete);

typedef FormeSearchableContentWidgetBuilder<T extends Object> = Widget Function(
  FormeKey formKey,
  ValueChanged<int> query,
  FormeSearchablePageResult<T>? result,
  FormeAsyncOperationState? state,
  int? currentPage,
);

class _PageResult<T extends Object> extends FormeSearchablePageResult<T> {
  final int currentPage;
  _PageResult(
    FormeSearchablePageResult<T> result,
    this.currentPage,
  ) : super(result.datas, result.totalPage);
}

class FormeSearchableDropdown<T extends Object> extends FormeField<List<T>> {
  final FormeQuery<T> query;
  final FormeSearchableContentWidgetBuilder<T> contentWidgetBuilder;
  final bool multiSelect;
  final FormeSearchableSelectedItemsBuilder<T>? searchableSelectedItemsBuilder;
  final FormeSearchablePopupType type;
  final Widget Function(BuildContext context, Widget content)? contentWrapper;
  final FormeBottomSheetConfiguration? bottomSheetConfiguration;
  final FormeDialogConfiguration? dialogConfiguration;
  final InputDecoration? decoration;
  FormeSearchableDropdown._({
    required this.type,
    Key? key,
    required String name,
    List<T>? initialValue,
    bool registrable = true,
    bool enabled = true,
    bool readOnly = false,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<List<T>>? onValueChanged,
    FormeFocusChanged<List<T>>? onFocusChanged,
    FormeFieldSetter<List<T>>? onSaved,
    FormeValidator<List<T>>? validator,
    FormeAsyncValidator<List<T>>? asyncValidator,
    FormeFieldValidationChanged<List<T>>? onValidationChanged,
    FormeFieldInitialed<List<T>>? onInitialed,
    required this.query,
    required this.contentWidgetBuilder,
    this.multiSelect = true,
    this.searchableSelectedItemsBuilder,
    this.contentWrapper,
    this.bottomSheetConfiguration,
    this.dialogConfiguration,
    this.decoration,
  }) : super(
            key: key,
            registrable: registrable,
            name: name,
            initialValue: initialValue ?? [],
            enabled: enabled,
            onInitialed: onInitialed,
            order: order,
            quietlyValidate: quietlyValidate,
            asyncValidatorDebounce: asyncValidatorDebounce,
            autovalidateMode: autovalidateMode,
            onValueChanged: onValueChanged,
            onFocusChanged: onFocusChanged,
            onValidationChanged: onValidationChanged,
            onSaved: onSaved,
            validator: validator,
            asyncValidator: asyncValidator,
            readOnly: readOnly,
            builder: (genericState) {
              final _FormeSearchableDropdownState<T> state =
                  genericState as _FormeSearchableDropdownState<T>;

              final Widget field = ValueListenableBuilder<bool>(
                  valueListenable: state.controller.focusListenable,
                  builder: (context, focus, child) {
                    return CompositedTransformTarget(
                      link: state._layerLink,
                      child: Focus(
                        focusNode: state.focusNode,
                        child: GestureDetector(
                          onTap: state._showDialog,
                          child: searchableSelectedItemsBuilder == null
                              ? InputDecorator(
                                  decoration: decoration ??
                                      const InputDecoration(
                                        suffixIcon: Icon(Icons.search),
                                      ),
                                  isFocused: focus,
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: state.value
                                        .map((e) => InputChip(
                                              label: Text('$e'),
                                              onDeleted: () {
                                                state._delete(e);
                                              },
                                            ))
                                        .toList(),
                                  ),
                                )
                              : searchableSelectedItemsBuilder(state.context,
                                  List.of(state.value), state._delete),
                        ),
                      ),
                    );
                  });

              if (type == FormeSearchablePopupType.overlay) {
                return LayoutBuilder(builder: (context, constraints) {
                  state._onSizeChange(context);
                  return field;
                });
              }

              return field;
            });
  @override
  FormeFieldState<List<T>> createState() => _FormeSearchableDropdownState<T>();

  factory FormeSearchableDropdown.overlay({
    required String name,
    required FormeQuery<T> query,
    FormeSearchableContentWidgetBuilder<T>? contentWidgetBuilder,
    double Function(BuildContext context)? maxHeightProvider,
    bool multiSelect = true,
    FormeSearchableSelectedItemsBuilder<T>? searchableSelectedItemsBuilder,
    Key? key,
    List<T>? initialValue,
    bool registrable = true,
    bool enabled = true,
    bool readOnly = false,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<List<T>>? onValueChanged,
    FormeFocusChanged<List<T>>? onFocusChanged,
    FormeFieldSetter<List<T>>? onSaved,
    FormeValidator<List<T>>? validator,
    FormeAsyncValidator<List<T>>? asyncValidator,
    FormeFieldValidationChanged<List<T>>? onValidationChanged,
    FormeFieldInitialed<List<T>>? onInitialed,
    InputDecoration? decoration,
  }) {
    return FormeSearchableDropdown._(
      decoration: decoration,
      enabled: enabled,
      onInitialed: onInitialed,
      registrable: registrable,
      order: order,
      quietlyValidate: quietlyValidate,
      asyncValidatorDebounce: asyncValidatorDebounce,
      autovalidateMode: autovalidateMode,
      onValueChanged: onValueChanged,
      onFocusChanged: onFocusChanged,
      onValidationChanged: onValidationChanged,
      onSaved: onSaved,
      validator: validator,
      asyncValidator: asyncValidator,
      key: key,
      readOnly: readOnly,
      name: name,
      initialValue: initialValue,
      searchableSelectedItemsBuilder: searchableSelectedItemsBuilder,
      multiSelect: multiSelect,
      type: FormeSearchablePopupType.overlay,
      query: query,
      contentWidgetBuilder: contentWidgetBuilder ??
          (formKey, query, result, state, currentPage) {
            return FormeSearchableContent(
              formKey: formKey,
              onPageChanged: query,
              result: result,
              state: state,
              currentPage: currentPage,
              processingBuilder: (context) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              },
            );
          },
      contentWrapper: (context, content) {
        if (maxHeightProvider == null) {
          return content;
        }
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeightProvider(context)),
          child: content,
        );
      },
    );
  }

  factory FormeSearchableDropdown.bottomSheet({
    required String name,
    required FormeQuery<T> query,
    FormeSearchableContentWidgetBuilder<T>? contentWidgetBuilder,
    double? Function(BuildContext context)? heightProvider,
    FormeBottomSheetConfiguration? bottomSheetConfiguration,
    bool multiSelect = true,
    FormeSearchableSelectedItemsBuilder<T>? searchableSelectedItemsBuilder,
    Key? key,
    List<T>? initialValue,
    bool registrable = true,
    bool enabled = true,
    bool readOnly = false,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<List<T>>? onValueChanged,
    FormeFocusChanged<List<T>>? onFocusChanged,
    FormeFieldSetter<List<T>>? onSaved,
    FormeValidator<List<T>>? validator,
    FormeAsyncValidator<List<T>>? asyncValidator,
    FormeFieldValidationChanged<List<T>>? onValidationChanged,
    FormeFieldInitialed<List<T>>? onInitialed,
    InputDecoration? decoration,
  }) {
    return FormeSearchableDropdown._(
      decoration: decoration,
      enabled: enabled,
      onInitialed: onInitialed,
      registrable: registrable,
      order: order,
      quietlyValidate: quietlyValidate,
      asyncValidatorDebounce: asyncValidatorDebounce,
      autovalidateMode: autovalidateMode,
      onValueChanged: onValueChanged,
      onFocusChanged: onFocusChanged,
      onValidationChanged: onValidationChanged,
      onSaved: onSaved,
      validator: validator,
      asyncValidator: asyncValidator,
      key: key,
      readOnly: readOnly,
      name: name,
      initialValue: initialValue,
      searchableSelectedItemsBuilder: searchableSelectedItemsBuilder,
      multiSelect: multiSelect,
      type: FormeSearchablePopupType.bottomSheet,
      query: query,
      contentWidgetBuilder: contentWidgetBuilder ??
          (formKey, query, result, state, currentPage) {
            return FormeSearchableContent(
              formKey: formKey,
              onPageChanged: query,
              result: result,
              state: state,
              currentPage: currentPage,
            );
          },
      bottomSheetConfiguration: bottomSheetConfiguration,
      contentWrapper: (context, content) {
        if (heightProvider == null) {
          return content;
        }
        return SizedBox(
          height: heightProvider(context),
          child: content,
        );
      },
    );
  }

  factory FormeSearchableDropdown.dialog({
    required String name,
    required FormeQuery<T> query,
    FormeSearchableContentWidgetBuilder<T>? contentWidgetBuilder,
    double? Function(BuildContext context)? heightFactorProvider,
    double? Function(BuildContext context)? widthFactorProvider,
    FormeDialogConfiguration? dialogConfiguration,
    bool multiSelect = true,
    FormeSearchableSelectedItemsBuilder<T>? searchableSelectedItemsBuilder,
    Key? key,
    List<T>? initialValue,
    bool registrable = true,
    bool enabled = true,
    bool readOnly = false,
    int? order,
    bool quietlyValidate = false,
    Duration? asyncValidatorDebounce,
    AutovalidateMode? autovalidateMode,
    FormeValueChanged<List<T>>? onValueChanged,
    FormeFocusChanged<List<T>>? onFocusChanged,
    FormeFieldSetter<List<T>>? onSaved,
    FormeValidator<List<T>>? validator,
    FormeAsyncValidator<List<T>>? asyncValidator,
    FormeFieldValidationChanged<List<T>>? onValidationChanged,
    FormeFieldInitialed<List<T>>? onInitialed,
    InputDecoration? decoration,
  }) {
    return FormeSearchableDropdown._(
      decoration: decoration,
      enabled: enabled,
      onInitialed: onInitialed,
      registrable: registrable,
      order: order,
      quietlyValidate: quietlyValidate,
      asyncValidatorDebounce: asyncValidatorDebounce,
      autovalidateMode: autovalidateMode,
      onValueChanged: onValueChanged,
      onFocusChanged: onFocusChanged,
      onValidationChanged: onValidationChanged,
      onSaved: onSaved,
      validator: validator,
      asyncValidator: asyncValidator,
      key: key,
      readOnly: readOnly,
      name: name,
      initialValue: initialValue,
      searchableSelectedItemsBuilder: searchableSelectedItemsBuilder,
      multiSelect: multiSelect,
      type: FormeSearchablePopupType.dialog,
      query: query,
      contentWidgetBuilder: contentWidgetBuilder ??
          (formKey, query, result, state, currentPage) {
            return FormeSearchableContent(
              formKey: formKey,
              onPageChanged: query,
              result: result,
              state: state,
              currentPage: currentPage,
            );
          },
      dialogConfiguration: dialogConfiguration,
      contentWrapper: (context, content) {
        return Center(
          child: FractionallySizedBox(
            heightFactor: heightFactorProvider?.call(context) ?? 1,
            widthFactor: widthFactorProvider?.call(context) ?? 1,
            child: content,
          ),
        );
      },
    );
  }
}

class _FormeSearchableDropdownState<T extends Object>
    extends FormeFieldState<List<T>>
    with FormeAsyncOperationHelper<_PageResult<T>> {
  final FormeKey _formKey = FormeKey();
  final LayerLink _layerLink = LayerLink();

  late final ValueNotifier<double?> _widthNotifier =
      FormeMountedValueNotifier(null, this);

  @override
  FormeSearchableDropdown<T> get widget =>
      super.widget as FormeSearchableDropdown<T>;

  late final ValueNotifier<_PageResult<T>?> _result =
      FormeMountedValueNotifier(null, this);
  late final ValueNotifier<FormeAsyncOperationState?> _stateNotifier =
      FormeMountedValueNotifier(null, this);

  OverlayEntry? _overlayEntry;
  Future? _dialog;

  void _delete(T data) {
    final List<T> copy = List.of(value);
    if (copy.remove(data)) {
      didChange(copy);
    }
  }

  void _toggle(T data) {
    if (widget.multiSelect) {
      final List<T> copy = List.of(value);
      if (!copy.remove(data)) {
        copy.add(data);
      }
      didChange(copy);
    } else {
      didChange([data]);
    }
  }

  @override
  void updateFieldValueInDidUpdateWidget(FormeField<List<T>> oldWidget) {
    super.updateFieldValueInDidUpdateWidget(oldWidget);
    if (!widget.multiSelect && value.length > 1) {
      setValue([value.first]);
    }
  }

  void _onSizeChange(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _widthNotifier.value =
          (context.findRenderObject()! as RenderBox).size.width;
    });
  }

  bool get needClose => _overlayEntry != null || _dialog != null;

  void _closeDialog() {
    if (!needClose) {
      return;
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_dialog != null) {
      Navigator.pop(context);
      _dialog = null;
    }
    _onClosed();
  }

  void _onClosed() {
    cancelAsyncOperation();
    _dialog = null;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    if (_dialog != null) {
      Navigator.pop(context);
    }
    _widthNotifier.dispose();
    _stateNotifier.dispose();
    _result.dispose();
    super.dispose();
  }

  Widget get _content {
    final Widget content = ValueListenableBuilder3<
            _PageResult<T>?,
            FormeAsyncOperationState?,
            List<T>>(_result, _stateNotifier, controller.valueListenable,
        builder: (context, result, state, value, child) {
      return Material(
        elevation: 4,
        child: widget.contentWidgetBuilder(
          _formKey,
          _query,
          result,
          state,
          result?.currentPage,
        ),
      );
    });
    return FormeSearchableController<T>._(this,
        LayoutBuilder(builder: (context, constraints) {
      if (widget.contentWrapper != null) {
        return widget.contentWrapper!(context, content);
      }
      return content;
    }));
  }

  void _showDialog() {
    if ((widget.type == FormeSearchablePopupType.bottomSheet ||
            widget.type == FormeSearchablePopupType.dialog) &&
        (_formKey.currentState != null || _dialog != null)) {
      return;
    }

    if (widget.type == FormeSearchablePopupType.overlay &&
        _overlayEntry != null) {
      return;
    }
    _result.value = null;
    _stateNotifier.value = null;

    if (widget.type == FormeSearchablePopupType.bottomSheet) {
      _dialog = showModalBottomSheet<void>(
          backgroundColor: widget.bottomSheetConfiguration?.backgroundColor,
          elevation: widget.bottomSheetConfiguration?.elevation,
          shape: widget.bottomSheetConfiguration?.shape,
          clipBehavior: widget.bottomSheetConfiguration?.clipBehavior,
          constraints: widget.bottomSheetConfiguration?.constraints,
          barrierColor: widget.bottomSheetConfiguration?.barrierColor,
          isScrollControlled:
              widget.bottomSheetConfiguration?.isScrollControlled ?? false,
          isDismissible: widget.bottomSheetConfiguration?.isDismissible ?? true,
          transitionAnimationController:
              widget.bottomSheetConfiguration?.transitionAnimationController,
          context: context,
          builder: (context) {
            return _content;
          }).whenComplete(_onClosed);
    }

    if (widget.type == FormeSearchablePopupType.dialog) {
      _dialog = showDialog<void>(
        barrierDismissible:
            widget.dialogConfiguration?.barrierDismissible ?? true,
        barrierColor:
            widget.dialogConfiguration?.barrierColor ?? Colors.black54,
        barrierLabel: widget.dialogConfiguration?.barrierLabel,
        useSafeArea: widget.dialogConfiguration?.useSafeArea ?? true,
        context: context,
        builder: (context) {
          return _content;
        },
      ).whenComplete(_onClosed);
    }

    if (widget.type == FormeSearchablePopupType.overlay) {
      _overlayEntry = OverlayEntry(builder: (context) {
        return CompositedTransformFollower(
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          link: _layerLink,
          child: ValueListenableBuilder<double?>(
            valueListenable: _widthNotifier,
            builder: (context, value, child) {
              return Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: value ?? double.infinity,
                  ),
                  child: _content,
                ),
              );
            },
          ),
        );
      });
      Overlay.of(context, rootOverlay: true)!.insert(_overlayEntry!);
    }
  }

  void _query(int page) {
    perform(widget.query(_formKey.data, page).then((value) {
      return _PageResult(value, page);
    }));
  }

  @override
  void onAsyncStateChanged(FormeAsyncOperationState state, Object? key) {
    if (mounted) {
      _stateNotifier.value = state;
    }
  }

  @override
  void onSuccess(_PageResult<T> result, Object? key) {
    if (mounted) {
      _result.value = result;
    }
  }
}

class FormeSearchableController<T extends Object> extends InheritedWidget {
  final _FormeSearchableDropdownState<T> _state;

  const FormeSearchableController._(this._state, Widget child)
      : super(child: child);

  /// get selected value
  List<T> get value => List.of(_state.value);

  /// close current dialog|overlay|bottomSheet
  void close() {
    _state._closeDialog();
  }

  /// whether data is selected
  bool contains(T data) => _state.value.contains(data);

  /// select|unselect data
  void toggle(T data) => _state._toggle(data);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static FormeSearchableController<E> of<E extends Object>(
      BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FormeSearchableController<E>>()!;
  }
}
