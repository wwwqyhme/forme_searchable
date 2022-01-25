import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forme/forme.dart';
import '../../../forme_searchable.dart';

import 'single_text_search_field.dart';

typedef FormeSearchFieldsBuilder = Widget Function(
    FormeKey formKey, VoidCallback onSubmitted);
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
  final Widget Function(BuildContext context, T data, bool isSelected)?
      selectableItemBuilder;
  final bool performQueryWhenInitialed;
  final Widget? closeIcon;
  final bool sizeAnimationEnable;
  final Curve sizeAnimationCurve;
  final Duration sizeAnimationDuration;
  final Alignment sizeAnimationAlignment;
  final FormeSearchPaginationBuilder? paginationBuilder;

  const FormeSearchableDefaultContent({
    Key? key,
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

  @override
  FormeSearchableDefaultContent<T> get widget =>
      super.widget as FormeSearchableDefaultContent<T>;

  bool _initialed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialed) {
      _initialed = true;
      if (widget.performQueryWhenInitialed) {
        _query();
      }
    }
  }

  @override
  void dispose() {
    _paginationNotifier.dispose();
    super.dispose();
  }

  Widget _defaultSearchFieldsBuilder(FormeKey key, VoidCallback onSubmitted) {
    return SingleTextSearchField(formKey: key, onSubmitted: onSubmitted);
  }

  void _query([int page = 1]) {
    final Map<String, dynamic> condition =
        _formKey.initialized ? _formKey.data : <String, dynamic>{};
    super.query(condition, page);
  }

  /// build default pagination bar and close button
  Widget _header() {
    final List<Widget> children = [];
    if (result != null) {
      final bool paginationEnable =
          result!.totalPage > 1 && widget.paginationConfiguration.enable;
      if (paginationEnable) {
        children.add(
          Expanded(
            child: widget.paginationBuilder == null
                ? FormeSearchablePaginationBar(
                    notifier: _paginationNotifier,
                    onPageChanged: _query,
                    configuration: widget.paginationConfiguration,
                  )
                : widget.paginationBuilder!(
                    context, _paginationNotifier, _query),
          ),
        );
      }
    }
    if (children.isEmpty) {
      children.add(const Spacer());
    }
    children.add(
      IconButton(
          onPressed: close, icon: widget.closeIcon ?? const Icon(Icons.close)),
    );
    return Row(
      children: children,
    );
  }

  Widget _defaultSelectableItemBuilder(
      BuildContext context, T data, bool isSelected) {
    return ListTile(
      leading: isSelected ? const Icon(Icons.check_circle) : null,
      title: Text('$data'),
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

  @override
  Widget build(BuildContext context) {
    final Column column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(),
        (widget.searchFieldsBuilder ?? _defaultSearchFieldsBuilder)
            .call(_formKey, _query),
        if (state == null) const SizedBox.shrink(),
        if (state == FormeAsyncOperationState.processing)
          (widget.processingBuilder ?? _defaultProcessingBuilder)(context),
        if (state == FormeAsyncOperationState.error)
          (widget.errorBuilder ?? _defaultErrorBuilder)(context),
        if (state == FormeAsyncOperationState.success)
          Flexible(
              child: ListView.builder(
            itemBuilder: (context, index) {
              final T data = result!.datas[index];
              return InkWell(
                onTap: () {
                  toggle(data);
                },
                child: Builder(
                  builder: (context) {
                    return (widget.selectableItemBuilder ??
                            _defaultSelectableItemBuilder)(
                        context, data, isSelected(data));
                  },
                ),
              );
            },
            itemCount: result!.datas.length,
            shrinkWrap: true,
          )),
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
