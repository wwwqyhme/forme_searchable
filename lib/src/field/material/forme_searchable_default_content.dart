import 'package:flutter/material.dart';
import 'package:forme/forme.dart';
import '../../../forme_searchable.dart';

import 'single_text_search_field.dart';

typedef FormeSearchFieldsBuilder = Widget Function(
    FormeKey formKey, VoidCallback onSubmitted);

class FormeSearchableDefaultContent<T extends Object>
    extends FormeSearchableObserverHelper<T> {
  final Alignment alignment;
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

  const FormeSearchableDefaultContent({
    Key? key,
    this.alignment = Alignment.topCenter,
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
  }) : super(key: key);

  @override
  _FormeSearchableDefaultContentState<T> createState() =>
      _FormeSearchableDefaultContentState<T>();
}

class _FormeSearchableDefaultContentState<T extends Object>
    extends FormeSearchableObserverHelperState<T> {
  final FormeKey _formKey = FormeKey();

  @override
  FormeSearchableDefaultContent<T> get widget =>
      super.widget as FormeSearchableDefaultContent<T>;

  Widget _defaultSearchFieldsBuilder(FormeKey key, VoidCallback onSubmitted) {
    return SingleTextSearchField(formKey: key, onSubmitted: onSubmitted);
  }

  @protected
  Map<String, dynamic> get condition {
    if (_formKey.initialized) {
      return _formKey.data;
    }
    return <String, dynamic>{};
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
            child: FormeSearchablePaginationBar(
              totalPage: result!.totalPage,
              currentPage: currentPage,
              onPageChanged: (int page) => query(condition, page),
              configuration: widget.paginationConfiguration,
            ),
          ),
        );
      }
    }
    if (children.isEmpty) {
      children.add(const Spacer());
    }
    children.add(
      IconButton(onPressed: close, icon: const Icon(Icons.close)),
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
            .call(_formKey, () {
          query(condition, 1);
        }),
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
                child: _defaultSelectableItemBuilder(
                  context,
                  data,
                  isSelected(data),
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
      child: column,
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
    setState(() {});
  }
}
