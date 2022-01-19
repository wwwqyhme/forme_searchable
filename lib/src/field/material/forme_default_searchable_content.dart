import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import 'forme_page_result.dart';
import 'forme_searchable_content.dart';
import 'pagination_bar.dart';
import 'single_text_search_field.dart';

typedef FormeSearchFieldsBuilder = Widget Function(
    FormeKey formKey, VoidCallback onSubmitted);

class FormeDefaultSearchableContent<T extends Object>
    extends FormeSearchableContent<T> {
  final Alignment alignment;
  final FormePaginationConfiguration paginationConfiguration;
  final FormeSearchFieldsBuilder? searchFieldsBuilder;
  final WidgetBuilder? processingBuilder;
  final WidgetBuilder? errorBuilder;
  final Widget Function(BuildContext context, T data, bool isSelected)?
      selectableItemBuilder;

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

  const FormeDefaultSearchableContent({
    Key? key,
    this.alignment = Alignment.topCenter,
    this.paginationConfiguration = const FormePaginationConfiguration(),
    this.searchFieldsBuilder,
    this.processingBuilder,
    this.errorBuilder,
    this.selectableItemBuilder,
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
  }) : super(key: key);

  @override
  FormeSearchableContentState<T> createState() =>
      _FormeDefaultSearchableContentState<T>();
}

class _FormeDefaultSearchableContentState<T extends Object>
    extends FormeSearchableContentState<T> {
  FormeSearchablePageResult<T>? _result;
  FormeAsyncOperationState? _state;
  int _currentPage = 1;

  final FormeKey _formKey = FormeKey();

  @override
  FormeDefaultSearchableContent<T> get widget =>
      super.widget as FormeDefaultSearchableContent<T>;

  void _query(int page) {
    final Map<String, dynamic> condition =
        _formKey.initialized ? _formKey.data : <String, dynamic>{};
    searchable.query(condition, page);
  }

  Widget _defaultSearchFieldsBuilder(FormeKey key, VoidCallback onSubmitted) {
    return SingleTextSearchField(formKey: key, onSubmitted: onSubmitted);
  }

  Widget _defaultProcessingBuilder(BuildContext context) {
    return const Flexible(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _defaultErrorBuilder(BuildContext context) {
    return const SizedBox();
  }

  Widget _defaultSelectableItemBuilder(
      BuildContext context, T data, bool isSelected) {
    return ListTile(
      leading: isSelected ? const Icon(Icons.check_circle) : null,
      title: Text('$data'),
    );
  }

  List<T> get _sortedDatas {
    final List<T> datas = List.of(_result!.datas);
    datas.sort((a, b) {
      final bool isASelected = searchable.contains(a);
      final bool isBSelected = searchable.contains(b);
      if (isASelected && !isBSelected) {
        return -1;
      }
      if (isBSelected && !isASelected) {
        return 1;
      }
      return datas.indexOf(a).compareTo(datas.indexOf(b));
    });
    return datas;
  }

  @override
  Widget build(BuildContext context) {
    final bool paginationEnable = _result != null &&
        _result!.totalPage > 1 &&
        widget.paginationConfiguration.enable;
    final Column column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (paginationEnable)
              Expanded(
                child: FormeSearchablePaginationBar(
                  totalPage: _result!.totalPage,
                  currentPage: _currentPage,
                  onPageChanged: _query,
                  configuration: widget.paginationConfiguration,
                ),
              ),
            if (!paginationEnable) const Spacer(),
            IconButton(
                onPressed: () {
                  searchable.close();
                },
                icon: const Icon(Icons.close)),
          ],
        ),
        (widget.searchFieldsBuilder ?? _defaultSearchFieldsBuilder)
            .call(_formKey, () {
          _query(1);
        }),
        if (_state == FormeAsyncOperationState.processing)
          (widget.processingBuilder ?? _defaultProcessingBuilder).call(context),
        if (_state == FormeAsyncOperationState.error)
          (widget.errorBuilder ?? _defaultErrorBuilder).call(context),
        if (_state == FormeAsyncOperationState.success && _result != null)
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _result!.datas.length,
              itemBuilder: (context, index) {
                final T data = _sortedDatas[index];
                return InkWell(
                  onTap: () {
                    searchable.toggle(data);
                  },
                  child: (widget.selectableItemBuilder ??
                      _defaultSelectableItemBuilder)(
                    context,
                    data,
                    searchable.contains(data),
                  ),
                );
              },
            ),
          ),
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
  void onStateChanged(FormeAsyncOperationState state,
      FormeSearchablePageResult<T>? result, int? currentPage) {
    if (!mounted) {
      return;
    }
    if (state != FormeAsyncOperationState.success) {
      setState(() {
        _state = state;
      });
    } else {
      setState(() {
        _state = FormeAsyncOperationState.success;
        _result = result;
        _currentPage = currentPage!;
      });
    }
  }

  @override
  void onSelectedChanged(List<T> value) {
    setState(() {});
  }
}
