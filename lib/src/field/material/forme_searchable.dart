import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import 'dialog_configuration.dart';
import 'forme_page_result.dart';
import 'forme_searchable_default_content.dart';
import 'forme_searchable_observer.dart';
import 'popup_type.dart';

typedef FormeSearchableSelectedItemsBuilder<T extends Object> = Widget Function(
    BuildContext context, List<T> selected, ValueChanged<T>? onDelete);
typedef FormeQuery<T extends Object> = Future<FormeSearchablePageResult<T>>
    Function(Map<String, dynamic> condition, int page);

class FormeSearchable<T extends Object> extends FormeField<List<T>> {
  final WidgetBuilder contentBuilder;
  final bool multiSelect;
  final FormeQuery<T> query;
  final FormeSearchableSelectedItemsBuilder<T>? selectedItemsBuilder;
  final FormeSearchablePopupType type;
  final Widget Function(BuildContext context, Widget content)? contentDecorator;
  final FormeBottomSheetConfiguration? bottomSheetConfiguration;
  final FormeDialogConfiguration? dialogConfiguration;
  final InputDecoration? decoration;
  final int? limit;
  final ValueChanged<BuildContext>? onLimitExceeded;
  FormeSearchable._({
    required this.type,
    Key? key,
    required String name,
    required this.query,
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
    FormeFieldDecorator<List<T>>? decorator,
    required this.contentBuilder,
    this.multiSelect = true,
    this.selectedItemsBuilder,
    this.contentDecorator,
    this.bottomSheetConfiguration,
    this.dialogConfiguration,
    this.decoration,
    this.limit,
    this.onLimitExceeded,
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
              final _FormeSearchableState<T> state =
                  genericState as _FormeSearchableState<T>;

              if (type == FormeSearchablePopupType.overlay) {
                return LayoutBuilder(builder: (context, constraints) {
                  state._onSizeChange(context);
                  return state._buildFieldViewWidget(decorator);
                });
              }

              return state._buildFieldViewWidget(decorator);
            });
  @override
  FormeFieldState<List<T>> createState() => _FormeSearchableState<T>();

  factory FormeSearchable.overlay({
    required String name,
    required FormeQuery<T> query,
    WidgetBuilder? contentBuilder,
    double Function(BuildContext context)? maxHeightProvider,
    bool multiSelect = true,
    FormeSearchableSelectedItemsBuilder<T>? selectedItemsBuilder,
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
    int? limit,
    ValueChanged<BuildContext>? onLimitExceeded,
    FormeFieldDecorator<List<T>>? decorator,
    Widget Function(BuildContext context, T data, bool isSelected)?
        selectableItemBuilder,
  }) {
    return FormeSearchable._(
      query: query,
      decorator: decorator,
      limit: limit,
      onLimitExceeded: onLimitExceeded,
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
      selectedItemsBuilder: selectedItemsBuilder,
      multiSelect: multiSelect,
      type: FormeSearchablePopupType.overlay,
      contentBuilder: contentBuilder ??
          (context) {
            return FormeSearchableDefaultContent<T>(
              elevation: 4,
              selectableItemBuilder: selectableItemBuilder,
              processingBuilder: (context) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              },
            );
          },
      contentDecorator: (context, content) {
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

  factory FormeSearchable.bottomSheet({
    required String name,
    required FormeQuery<T> query,
    WidgetBuilder? contentBuilder,
    double? Function(BuildContext context)? heightProvider,
    double? Function(BuildContext context)? maxHeightProvider,
    FormeBottomSheetConfiguration? bottomSheetConfiguration,
    bool multiSelect = true,
    FormeSearchableSelectedItemsBuilder<T>? selectedItemsBuilder,
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
    int? limit,
    ValueChanged<BuildContext>? onLimitExceeded,
    FormeFieldDecorator<List<T>>? decorator,
    Widget Function(BuildContext context, T data, bool isSelected)?
        selectableItemBuilder,
  }) {
    return FormeSearchable._(
      query: query,
      decorator: decorator,
      limit: limit,
      onLimitExceeded: onLimitExceeded,
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
      selectedItemsBuilder: selectedItemsBuilder,
      multiSelect: multiSelect,
      type: FormeSearchablePopupType.bottomSheet,
      contentBuilder: contentBuilder ??
          (context) {
            return FormeSearchableDefaultContent<T>(
              selectableItemBuilder: selectableItemBuilder,
              processingBuilder:
                  (heightProvider == null && maxHeightProvider != null)
                      ? (context) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          );
                        }
                      : null,
            );
          },
      bottomSheetConfiguration: bottomSheetConfiguration,
      contentDecorator: (context, content) {
        Widget _content;
        if (heightProvider == null) {
          if (maxHeightProvider != null) {
            _content = ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeightProvider(context) ?? double.infinity,
              ),
              child: content,
            );
          } else {
            _content = content;
          }
        } else {
          _content = SizedBox(
            height: heightProvider(context),
            child: content,
          );
        }
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _content,
        );
      },
    );
  }

  factory FormeSearchable.dialog({
    required String name,
    required FormeQuery<T> query,
    WidgetBuilder? contentBuilder,
    Size? Function(BuildContext context)? sizeProvider,
    FormeDialogConfiguration? dialogConfiguration,
    bool multiSelect = true,
    FormeSearchableSelectedItemsBuilder<T>? selectedItemsBuilder,
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
    int? limit,
    ValueChanged<BuildContext>? onLimitExceeded,
    FormeFieldDecorator<List<T>>? decorator,
    Widget Function(BuildContext context, T data, bool isSelected)?
        selectableItemBuilder,
  }) {
    return FormeSearchable._(
      query: query,
      decorator: decorator,
      limit: limit,
      onLimitExceeded: onLimitExceeded,
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
      selectedItemsBuilder: selectedItemsBuilder,
      multiSelect: multiSelect,
      type: FormeSearchablePopupType.dialog,
      contentBuilder: contentBuilder ??
          (context) {
            return FormeSearchableDefaultContent<T>(
              selectableItemBuilder: selectableItemBuilder,
            );
          },
      dialogConfiguration: dialogConfiguration,
      contentDecorator: (context, content) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);
        final Size size = sizeProvider?.call(context) ?? mediaQuery.size;
        double bottomPadding;
        if (size == mediaQuery.size) {
          bottomPadding = mediaQuery.viewInsets.bottom;
        } else {
          double statusBarHeight = 0;
          if (dialogConfiguration?.useSafeArea ?? true) {
            statusBarHeight = mediaQuery.padding.top;
          }
          final double bottom = (mediaQuery.size.height - size.height) / 2;
          bottomPadding =
              mediaQuery.viewInsets.bottom - bottom + statusBarHeight / 2;
          if (bottomPadding < 0) {
            bottomPadding = 0;
          }
        }

        return Center(
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: content,
            ),
          ),
        );
      },
    );
  }

  factory FormeSearchable.builder({
    required String name,
    required FormeQuery<T> query,
    required WidgetBuilder contentBuilder,
    Widget Function(BuildContext context, Widget content)? contentDecorator,
    bool multiSelect = true,
    FormeSearchableSelectedItemsBuilder<T>? selectedItemsBuilder,
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
    int? limit,
    ValueChanged<BuildContext>? onLimitExceeded,
    required FormeSearchablePopupType type,
    FormeFieldDecorator<List<T>>? decorator,
    FormeDialogConfiguration? dialogConfiguration,
    FormeBottomSheetConfiguration? bottomSheetConfiguration,
  }) {
    return FormeSearchable._(
      query: query,
      dialogConfiguration: dialogConfiguration,
      bottomSheetConfiguration: bottomSheetConfiguration,
      decorator: decorator,
      limit: limit,
      onLimitExceeded: onLimitExceeded,
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
      selectedItemsBuilder: selectedItemsBuilder,
      multiSelect: multiSelect,
      type: type,
      contentBuilder: contentBuilder,
      contentDecorator: contentDecorator,
    );
  }
}

class _FormeSearchableState<T extends Object> extends FormeFieldState<List<T>>
    with FormeAsyncOperationHelper<_PageResult<T>> {
  final LayerLink _layerLink = LayerLink();

  late final ValueNotifier<double?> _widthNotifier =
      FormeMountedValueNotifier(null, this);

  FormeSearchableObserver<T>? _observer;

  @override
  FormeSearchable<T> get widget => super.widget as FormeSearchable<T>;

  OverlayEntry? _overlayEntry;
  Future? _dialog;
  bool get _needClose => _overlayEntry != null || _dialog != null;

  void _query(Map<String, dynamic> condition, int page) {
    perform(widget
        .query(condition, page)
        .then((value) => _PageResult(value, page, condition)));
  }

  @override
  void afterInitiation() {
    super.afterInitiation();
    controller.readOnlyListenable.addListener(() {
      if (readOnly) {
        _close();
      }
    });
  }

  Widget _buildFieldViewWidget(FormeFieldDecorator<List<T>>? decorator) {
    Widget field = widget.selectedItemsBuilder == null
        ? Wrap(
            spacing: 10,
            // runSpacing: 10,
            children: value
                .map((e) => InputChip(
                      label: Text('$e'),
                      onDeleted: readOnly
                          ? null
                          : () {
                              _delete(e);
                            },
                    ))
                .toList(),
          )
        : widget.selectedItemsBuilder!(
            context,
            List.of(value),
            readOnly ? null : _delete,
          );

    final FormeFieldDecorator<List<T>> finalDecorator = decorator ??
        FormeInputDecoratorBuilder(
            decoration: widget.decoration ??
                const InputDecoration(
                  suffixIcon: Icon(Icons.search),
                ),
            emptyChecker: (value, controller) {
              return value.isNotEmpty;
            });

    field = finalDecorator.build(controller, field);

    field = Focus(
      focusNode: focusNode,
      child: GestureDetector(
        onTap: readOnly ? null : _toggleContent,
        child: field,
      ),
    );

    if (widget.type == FormeSearchablePopupType.overlay) {
      return CompositedTransformTarget(
        link: _layerLink,
        child: field,
      );
    }
    return field;
  }

  void _delete(T data) {
    final List<T> copy = List.of(value);
    if (copy.remove(data)) {
      didChange(copy);
      requestFocusOnUserInteraction();
    }
  }

  void _toggle(T data) {
    if (widget.multiSelect) {
      final List<T> copy = List.of(value);
      if (!copy.remove(data)) {
        if (widget.limit != null && copy.length >= widget.limit!) {
          widget.onLimitExceeded?.call(context);
          return;
        }
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
    if (widget.limit != null && widget.limit! < value.length) {
      final List<T> items = List.of(value);
      setValue(items.sublist(0, widget.limit));
    }
  }

  void _onSizeChange(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _widthNotifier.value = double.parse(
          (context.findRenderObject()! as RenderBox)
              .size
              .width
              .toStringAsFixed(2));
    });
  }

  @override
  void onValueChanged(List<T> value) {
    super.onValueChanged(value);
    _observer?.onSelected(List.of(value));
  }

  void _close() {
    if (!_needClose) {
      return;
    }
    _overlayEntry?.remove();
    if (_dialog != null) {
      Navigator.pop(context);
    }
    _onClosed();
  }

  void _onClosed() {
    _observer = null;
    _dialog = null;
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    if (_dialog != null) {
      Navigator.pop(context);
    }
    _widthNotifier.dispose();
    super.dispose();
  }

  Widget get _content {
    final Widget content = widget.contentBuilder(
      context,
    );

    return _MediaQueryHolder(
      child: FormeSearchableData<T>._(this, Builder(builder: (context) {
        if (widget.contentDecorator != null) {
          return widget.contentDecorator!(context, content);
        }
        return content;
      })),
    );
  }

  void _toggleContent() {
    if (_needClose) {
      _close();
      return;
    }
    _show();
  }

  void _show() {
    focusNode.requestFocus();
    if (widget.type == FormeSearchablePopupType.bottomSheet) {
      _dialog = showModalBottomSheet<void>(
          backgroundColor: widget.bottomSheetConfiguration?.backgroundColor,
          elevation: widget.bottomSheetConfiguration?.elevation,
          shape: widget.bottomSheetConfiguration?.shape,
          clipBehavior: widget.bottomSheetConfiguration?.clipBehavior,
          constraints: widget.bottomSheetConfiguration?.constraints,
          barrierColor: widget.bottomSheetConfiguration?.barrierColor,
          isScrollControlled:
              widget.bottomSheetConfiguration?.isScrollControlled ?? true,
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
      Overlay.of(context)!.insert(_overlayEntry!);
    }
  }

  @override
  FormeFieldController<List<T>> createFormeFieldController() {
    return FormeSearchableController._(
        this, super.createFormeFieldController());
  }

  @override
  void onAsyncStateChanged(FormeAsyncOperationState state, Object? key) {
    if (mounted && state == FormeAsyncOperationState.processing) {
      _observer?.onProcessing();
    }
  }

  @override
  void onSuccess(_PageResult<T> result, Object? key) {
    if (mounted) {
      _observer?.onSuccess(result, result.currentPage, result.condition);
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (mounted) {
      _observer?.onError(error, stackTrace);
    }
  }
}

class FormeSearchableController<T extends Object>
    extends FormeFieldControllerDelegate<List<T>> {
  final _FormeSearchableState<T> _state;
  FormeSearchableController._(
      this._state, FormeFieldController<List<T>> delegate)
      : super(delegate);

  /// close dialog|bottomSheet|overlay
  void close() {
    _state._close();
  }
}

class FormeSearchableData<T extends Object> extends InheritedWidget {
  final _FormeSearchableState<T> _state;

  const FormeSearchableData._(this._state, Widget child) : super(child: child);

  /// get selected value
  List<T> get value => List.of(_state.value);

  /// close current dialog|overlay|bottomSheet
  void close() {
    _state._close();
  }

  /// whether data is selected
  bool contains(T data) => _state.value.contains(data);

  /// select|unselect data
  void toggle(T data) => _state._toggle(data);

  /// perform a query
  void query(Map<String, dynamic> condition, int page) =>
      _state._query(condition, page);

  void setObserver(FormeSearchableObserver<T> observer) =>
      _state._observer = observer;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static FormeSearchableData<E> of<E extends Object>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FormeSearchableData<E>>()!;
  }
}

class _MediaQueryHolder extends StatefulWidget {
  final Widget child;

  const _MediaQueryHolder({Key? key, required this.child}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _MediaQueryHolderState();
}

class _MediaQueryHolderState extends State<_MediaQueryHolder>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    return MediaQuery(data: data, child: widget.child);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }
}

class _PageResult<T extends Object> extends FormeSearchablePageResult<T> {
  final int currentPage;
  final Map<String, dynamic> condition;
  _PageResult(
    FormeSearchablePageResult<T> result,
    this.currentPage,
    this.condition,
  ) : super(result.datas, result.totalPage);
}
