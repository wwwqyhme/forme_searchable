import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';
import '../../../forme_searchable.dart';

import 'single_text_search_field.dart';

/// build search fields
///
/// [query] used to perform  a query , query condition comes from from [formKey]
///
/// [selectHighlight] used to select current highlighted item
typedef FormeSearchFieldsBuilder = Widget Function(
    FormeKey formKey, VoidCallback query, VoidCallback selectHighlight);
typedef FormeSearchPaginationBuilder = Widget Function(
  BuildContext context,
  ValueListenable<PageInfo> listenable,
  ValueChanged<int> onPageChanged,
);

class FormeSearchableDefaultContent<T extends Object>
    extends FormeSearchableObserverHelper<T> {
  final FormePaginationConfiguration paginationConfiguration;

  final FormeSearchFieldsBuilder? searchFieldsBuilder;
  final MaterialType type;
  final double elevation;
  final Color? color;
  final Color? shadowColor;
  final TextStyle? textStyle;
  final BorderRadiusGeometry? borderRadius;
  final ShapeBorder? shape;
  final bool borderOnForeground;
  final Clip clipBehavior;
  final Duration animationDuration;
  final WidgetBuilder? processingBuilder;
  final WidgetBuilder? errorBuilder;
  final Widget Function(
          BuildContext context, int index, T data, bool isSelected)?
      selectableItemBuilder;
  final bool performQueryWhenInitialed;
  final Widget? closeIcon;
  final bool sizeAnimationEnable;
  final Curve sizeAnimationCurve;
  final Duration sizeAnimationDuration;
  final Alignment sizeAnimationAlignment;
  final FormeSearchPaginationBuilder? paginationBuilder;

  /// whether show close button
  final bool closeable;
  final PaginationBarPosition paginationBarPosition;
  final double scrollAlignment;
  final Duration scrollDuration;

  /// whether enable highlight
  final bool enableHighlight;

  const FormeSearchableDefaultContent({
    Key? key,
    this.paginationBarPosition = PaginationBarPosition.top,
    this.paginationConfiguration = const FormePaginationConfiguration(),
    this.searchFieldsBuilder,
    this.shape,
    this.type = MaterialType.canvas,
    this.elevation = 0.0,
    this.color,
    this.shadowColor,
    this.textStyle,
    this.borderRadius,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    this.animationDuration = kThemeChangeDuration,
    this.processingBuilder,
    this.errorBuilder,
    this.selectableItemBuilder,
    this.performQueryWhenInitialed = false,
    this.closeIcon,
    this.sizeAnimationEnable = true,
    this.sizeAnimationCurve = Curves.linear,
    this.sizeAnimationAlignment = Alignment.topCenter,
    this.sizeAnimationDuration = const Duration(milliseconds: 200),
    this.paginationBuilder,
    this.closeable = true,
    this.scrollAlignment = 0.5,
    this.scrollDuration = const Duration(milliseconds: 200),
    this.enableHighlight = true,
  }) : super(key: key);

  @override
  _FormeSearchableDefaultContentState<T> createState() =>
      _FormeSearchableDefaultContentState<T>();
}

class _FormeSearchableDefaultContentState<T extends Object>
    extends FormeSearchableObserverHelperState<T> {
  final FormeKey _formKey = FormeKey();
  final _FormeSearchablePaginationNotifier _paginationNotifier =
      _FormeSearchablePaginationNotifier(PageInfo._(1, 1));
  late final ValueNotifier<int> _indexNotifier;
  late final Map<Type, Action<Intent>> _actionMap;
  final ScrollController _scrollController = ScrollController();

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
    // SingleActivator(LogicalKeyboardKey.escape):
    SingleActivator(LogicalKeyboardKey.arrowUp):
        AutocompletePreviousOptionIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown):
        AutocompleteNextOptionIntent(),
    SingleActivator(LogicalKeyboardKey.escape): _EscapeOptionIntent(),
  };

  @override
  FormeSearchableDefaultContent<T> get widget =>
      super.widget as FormeSearchableDefaultContent<T>;

  bool _initialed = false;
  bool get _paginationEnable =>
      result != null &&
      result!.totalPage > 1 &&
      widget.paginationConfiguration.enable;

  @override
  void initState() {
    super.initState();
    _indexNotifier = ValueNotifier(widget.enableHighlight ? 0 : -1);
    _actionMap = <Type, Action<Intent>>{
      AutocompletePreviousOptionIntent:
          CallbackAction<AutocompletePreviousOptionIntent>(
              onInvoke: _highlightPreviousOption),
      AutocompleteNextOptionIntent:
          CallbackAction<AutocompleteNextOptionIntent>(
              onInvoke: _highlightNextOption),
      _EscapeOptionIntent: CallbackAction<_EscapeOptionIntent>(
        onInvoke: (intent) {
          close();
        },
      ),
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialed) {
      _initialed = true;
      if (widget.performQueryWhenInitialed) {
        /// query when frame completed
        /// we need formekey to get query condition
        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          _query();
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant FormeSearchableObserverHelper<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enableHighlight) {
      _indexNotifier.value = -1;
    } else if (_indexNotifier.value == -1) {
      _indexNotifier.value = 0;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _indexNotifier.dispose();
    _paginationNotifier.dispose();
    super.dispose();
  }

  void _updateHighlight(int newIndex) {
    _indexNotifier.value = newIndex;
  }

  void _highlightPreviousOption(AutocompletePreviousOptionIntent intent) {
    if (_indexNotifier.value == 0) {
      return;
    }
    _updateHighlight(_indexNotifier.value - 1);
  }

  void _highlightNextOption(AutocompleteNextOptionIntent intent) {
    final int? dataLength = result?.datas.length;
    if (dataLength == null || _indexNotifier.value == dataLength - 1) {
      return;
    }
    _updateHighlight(_indexNotifier.value + 1);
  }

  Widget _defaultSearchFieldsBuilder(
      FormeKey key, VoidCallback query, VoidCallback selectHighlighted) {
    return SingleTextSearchField(
      formKey: key,
      query: query,
      selectHighlight: selectHighlighted,
    );
  }

  void _query([int page = 1]) {
    final Map<String, dynamic> condition =
        _formKey.initialized ? _formKey.data : <String, dynamic>{};
    super.query(condition, page);
  }

  Widget _paginationBar() {
    return widget.paginationBuilder == null
        ? FormeSearchablePaginationBar(
            notifier: _paginationNotifier,
            onPageChanged: _query,
            configuration: widget.paginationConfiguration,
          )
        : widget.paginationBuilder!(context, _paginationNotifier, _query);
  }

  /// build default pagination bar and close button
  Widget _header() {
    final List<Widget> children = [];
    if (_paginationEnable &&
        widget.paginationBarPosition == PaginationBarPosition.top) {
      children.add(
        Expanded(
          child: _paginationBar(),
        ),
      );
    }
    if (children.isEmpty) {
      children.add(const Spacer());
    }
    if (widget.closeable) {
      children.add(
        IconButton(
            onPressed: close,
            icon: widget.closeIcon ?? const Icon(Icons.close)),
      );
    }
    return Row(
      children: children,
    );
  }

  Widget _defaultSelectableItemBuilder(
      BuildContext context, int index, T data, bool isSelected) {
    final bool isHighlight = widget.enableHighlight &&
        AutocompleteHighlightedOption.of(context) == index;
    return Container(
      color: isHighlight ? Theme.of(context).focusColor : null,
      child: ListTile(
        leading: isSelected ? const Icon(Icons.check_circle) : null,
        title: Text('$data'),
      ),
    );
  }

  Widget _defaultProcessingBuilder(BuildContext context) {
    return const Flexible(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _defaultErrorBuilder(BuildContext context) {
    return const Flexible(
      child: Center(
        child: Icon(Icons.error),
      ),
    );
  }

  void _selectHighlight() {
    if (result == null || result!.datas.isEmpty) {
      return;
    }
    toggle(result!.datas[_indexNotifier.value]);
  }

  @override
  bool toggle(T data) {
    final bool toggled = super.toggle(data);
    if (toggled && result != null && widget.enableHighlight) {
      _indexNotifier.value = result!.datas.indexOf(data);
    }
    return toggled;
  }

  @override
  Widget build(BuildContext context) {
    final Widget searchFields =
        (widget.searchFieldsBuilder ?? _defaultSearchFieldsBuilder)
            .call(_formKey, _query, _selectHighlight);
    final Column column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(),
        Shortcuts(
          shortcuts: widget.enableHighlight ? _shortcuts : {},
          child: Actions(
            actions: widget.enableHighlight ? _actionMap : {},
            child: searchFields,
          ),
        ),
        if (state == null) const SizedBox.shrink(),
        if (state == FormeAsyncOperationState.processing)
          (widget.processingBuilder ?? _defaultProcessingBuilder)(context),
        if (state == FormeAsyncOperationState.error)
          (widget.errorBuilder ?? _defaultErrorBuilder)(context),
        if (state == FormeAsyncOperationState.success)
          AutocompleteHighlightedOption(
            highlightIndexNotifier: _indexNotifier,
            child: Flexible(
                child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, index) {
                final T data = result!.datas[index];
                return InkWell(
                  onTap: () {
                    toggle(data);
                  },
                  child: Builder(
                    builder: (context) {
                      final bool highlight =
                          AutocompleteHighlightedOption.of(context) == index;
                      if (highlight) {
                        WidgetsBinding.instance!
                            .addPostFrameCallback((timeStamp) {
                          _scrollController.position.ensureVisible(
                            context.findRenderObject()!,
                            alignment: widget.scrollAlignment,
                            duration: widget.scrollDuration,
                          );
                        });
                      }
                      return (widget.selectableItemBuilder ??
                              _defaultSelectableItemBuilder)(
                          context, index, data, isSelected(data));
                    },
                  ),
                );
              },
              itemCount: result!.datas.length,
              shrinkWrap: true,
            )),
          ),
        if (_paginationEnable &&
            widget.paginationBarPosition == PaginationBarPosition.bottom)
          _paginationBar(),
      ],
    );
    return Material(
      type: widget.type,
      color: widget.color,
      shadowColor: widget.shadowColor,
      textStyle: widget.textStyle,
      borderRadius: widget.borderRadius,
      shape: widget.shape,
      borderOnForeground: widget.borderOnForeground,
      clipBehavior: widget.clipBehavior,
      animationDuration: widget.animationDuration,
      elevation: widget.elevation,
      child: widget.sizeAnimationEnable
          ? AnimatedSize(
              curve: widget.sizeAnimationCurve,
              alignment: widget.sizeAnimationAlignment,
              duration: widget.sizeAnimationDuration,
              child: column,
            )
          : column,
    );
  }

  @override
  void onErrorIfMounted(Object error, StackTrace stackTrace) {
    setState(() {});
  }

  @override
  void onProcessingIfMounted() {
    setState(() {});
  }

  @override
  void onSelectedIfMounted(List<T> selected) {
    setState(() {});
  }

  @override
  void onSuccessIfMounted(FormeSearchablePageResult<T> result, int currentPage,
      Map<String, dynamic> condition) {
    _indexNotifier.value = widget.enableHighlight ? 0 : -1;
    setState(() {
      _paginationNotifier.value = PageInfo._(currentPage, result.totalPage);
    });
  }
}

class _FormeSearchablePaginationNotifier extends ValueNotifier<PageInfo> {
  _FormeSearchablePaginationNotifier(PageInfo value) : super(value);
}

class PageInfo {
  final int currentPage;
  final int totalPage;

  bool get hasNextPage => currentPage < totalPage;
  bool get hasPrevPage => currentPage > 1;
  PageInfo._(this.currentPage, this.totalPage);
}

enum PaginationBarPosition {
  top,
  bottom,
}

class _EscapeOptionIntent extends Intent {
  const _EscapeOptionIntent();
}
