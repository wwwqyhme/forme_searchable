import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forme/forme.dart';
import '../../../forme_searchable.dart';

import 'single_text_search_field.dart';

typedef FormeSearchFieldsBuilder = Widget Function(
    FormeKey formKey, VoidCallback onSubmitted);

class FormeSearchableDefaultEventConsumer<T extends Object>
    extends FormeSearchableEventConsumer<T> {
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

  const FormeSearchableDefaultEventConsumer({
    required Stream<FormeSearchableEvent<T>> stream,
    required Stream<FormeSearchableSelectedEvent<T>> selectedStream,
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
  }) : super(key: key, stream: stream, selectedStream: selectedStream);

  @override
  _FormeSearchableDefaultEventConsumerState<T> createState() =>
      _FormeSearchableDefaultEventConsumerState<T>();
}

class _FormeSearchableDefaultEventConsumerState<T extends Object>
    extends FormeSearchableEventConsumerState<T> {
  final FormeKey _formKey = FormeKey();

  FormeSearchableEvent<T>? _event;
  FormeSearchableEvent<T>? _lastSuccessEvent;

  @override
  FormeSearchableDefaultEventConsumer<T> get widget =>
      super.widget as FormeSearchableDefaultEventConsumer<T>;

  void _query([int page = 1]) {
    searchable.query(condition, page);
  }

  Widget _defaultSearchFieldsBuilder(FormeKey key, VoidCallback onSubmitted) {
    return SingleTextSearchField(formKey: key, onSubmitted: onSubmitted);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @protected
  Map<String, dynamic> get condition {
    if (_formKey.initialized) {
      return _formKey.data;
    }
    return <String, dynamic>{};
  }

  @protected
  bool isConditionChanged(
      Map<String, dynamic> old, Map<String, dynamic> current) {
    if (old.length != current.length) {
      return true;
    }
    for (final String key in old.keys) {
      if (!current.containsKey(key)) {
        return true;
      }
      if (current[key] != old[key]) {
        return true;
      }
    }
    return false;
  }

  /// build default pagination bar and close button
  Widget _header() {
    return _Header(
      event: _lastSuccessEvent,
      paginationConfiguration: widget.paginationConfiguration,
      query: _query,
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
        if (_event == null) const SizedBox.shrink(),
        if (_event != null && _event!.isProcessing)
          (widget.processingBuilder ?? _defaultProcessingBuilder)(context),
        if (_event != null && _event!.hasError)
          (widget.errorBuilder ?? _defaultErrorBuilder)(context),
        if (_event != null && _event!.isSuccess)
          Flexible(
              child: ListView.builder(
            itemBuilder: (context, index) {
              final T data = _event!.result!.datas[index];
              return InkWell(
                onTap: () {
                  searchable.toggle(data);
                },
                child: _defaultSelectableItemBuilder(
                  context,
                  data,
                  searchable.contains(data),
                ),
              );
            },
            itemCount: _event!.result!.datas.length,
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
  void onEventChanged(FormeSearchableEvent<T> event) {
    setState(() {
      _event = event;
      if (event.isSuccess) {
        _lastSuccessEvent = event;
      }
    });
  }

  @override
  void onSelectedChanged(FormeSearchableSelectedEvent<T> event) {
    setState(() {});
  }
}

class _Header<T extends Object> extends StatefulWidget {
  final FormePaginationConfiguration paginationConfiguration;
  final ValueChanged<int> query;
  final FormeSearchableEvent<T>? event;

  const _Header({
    Key? key,
    required this.event,
    required this.paginationConfiguration,
    required this.query,
  }) : super(key: key);

  @override
  _HeaderState<T> createState() => _HeaderState<T>();
}

class _HeaderState<T extends Object> extends State<_Header<T>> {
  FormeSearchableEvent<T>? get _event => widget.event;

  late FormeSearchableData<T> searchable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    searchable = FormeSearchableData.of<T>(context);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    if (_event != null) {
      final bool paginationEnable = _event!.result!.totalPage > 1 &&
          widget.paginationConfiguration.enable;
      if (paginationEnable) {
        children.add(
          Expanded(
            child: FormeSearchablePaginationBar(
              totalPage: _event!.result!.totalPage,
              currentPage: _event!.currentPage!,
              onPageChanged: widget.query,
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
      IconButton(
          onPressed: () {
            searchable.close();
          },
          icon: const Icon(Icons.close)),
    );
    return Row(
      children: children,
    );
  }
}
