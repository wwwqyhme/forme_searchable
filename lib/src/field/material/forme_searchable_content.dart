import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import 'forme_page_result.dart';
import 'forme_searchable.dart';
import 'pagination_bar.dart';
import 'single_text_search_field.dart';

typedef FormeSearchFieldsBuilder = Widget Function(
    FormeKey formKey, VoidCallback onSubmitted);

class FormeSearchableContent<T extends Object> extends StatefulWidget {
  final Alignment alignment;
  final ShapeBorder? shape;
  final FormeSearchablePageResult<T>? result;
  final FormeKey formKey;
  final ValueChanged<int> onPageChanged;
  final FormeAsyncOperationState? state;
  final int? currentPage;
  final FormePaginationConfiguration paginationConfiguration;
  final FormeSearchFieldsBuilder? searchFieldsBuilder;
  final WidgetBuilder? processingBuilder;
  final WidgetBuilder? errorBuilder;
  final Widget Function(BuildContext context, T data, bool isSelected)?
      selectableItemBuilder;
  const FormeSearchableContent({
    Key? key,
    this.alignment = Alignment.topCenter,
    this.shape,
    required this.result,
    required this.formKey,
    required this.onPageChanged,
    required this.state,
    required this.currentPage,
    this.paginationConfiguration = const FormePaginationConfiguration(),
    this.searchFieldsBuilder,
    this.processingBuilder,
    this.errorBuilder,
    this.selectableItemBuilder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FormeSearchableContentState<T>();
}

class _FormeSearchableContentState<T extends Object>
    extends State<FormeSearchableContent<T>> {
  late FormeSearchableController<T> _searchableController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _searchableController = FormeSearchableController.of<T>(context);
  }

  void _query() {
    widget.onPageChanged(1);
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
    final List<T> datas = List.of(widget.result!.datas);
    datas.sort((a, b) {
      final bool isASelected = _searchableController.contains(a);
      final bool isBSelected = _searchableController.contains(b);
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
    final bool paginationEnable = widget.result != null &&
        widget.result!.totalPage > 1 &&
        widget.paginationConfiguration.enable;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (paginationEnable)
              Expanded(
                child: FormeSearchablePaginationBar(
                  totalPage: widget.result!.totalPage,
                  currentPage: widget.currentPage ?? 1,
                  onPageChanged: (int page) {
                    widget.onPageChanged(page);
                  },
                  configuration: widget.paginationConfiguration,
                ),
              ),
            if (!paginationEnable) const Spacer(),
            IconButton(
                onPressed: () {
                  _searchableController.close();
                },
                icon: const Icon(Icons.close)),
          ],
        ),
        (widget.searchFieldsBuilder ?? _defaultSearchFieldsBuilder)
            .call(widget.formKey, _query),
        if (widget.state == FormeAsyncOperationState.processing)
          (widget.processingBuilder ?? _defaultProcessingBuilder).call(context),
        if (widget.state == FormeAsyncOperationState.error)
          (widget.errorBuilder ?? _defaultErrorBuilder).call(context),
        if (widget.state == FormeAsyncOperationState.success &&
            widget.result != null)
          Flexible(
            child: ListView.builder(
              itemCount: widget.result!.datas.length,
              itemBuilder: (context, index) {
                final T data = _sortedDatas[index];
                return InkWell(
                  onTap: () {
                    _searchableController.toggle(data);
                  },
                  child: (widget.selectableItemBuilder ??
                      _defaultSelectableItemBuilder)(
                    context,
                    data,
                    _searchableController.contains(data),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
