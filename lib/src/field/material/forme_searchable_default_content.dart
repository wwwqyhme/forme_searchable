import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forme/forme.dart';
import '../../../forme_searchable.dart';

import 'forme_searchable_event.dart';
import 'forme_searchable_event_consumer.dart';
import 'single_text_search_field.dart';

typedef FormeSearchFieldsBuilder = Widget Function(
    FormeKey formKey, VoidCallback onSubmitted);
typedef FormeSearchableDefaultContentEventBuilder<T extends Object> = Widget
    Function(
  BuildContext context,
  Stream<FormeSearchableEvent<T>> stream,
);

class FormeSearchableDefaultContent<T extends Object>
    extends FormeSearchableContent<T> {
  final Alignment alignment;
  final FormePaginationConfiguration paginationConfiguration;
  final FormeSearchFieldsBuilder? searchFieldsBuilder;
  final FormeSearchableDefaultContentEventBuilder<T> eventBuilder;
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

  const FormeSearchableDefaultContent({
    Key? key,
    this.alignment = Alignment.topCenter,
    this.paginationConfiguration = const FormePaginationConfiguration(),
    this.searchFieldsBuilder,
    required this.eventBuilder,
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
      _FormeSearchableDefaultContentState<T>();
}

class _FormeSearchableDefaultContentState<T extends Object>
    extends FormeSearchableContentState<T> {
  final StreamController<FormeSearchableEvent<T>> _eventNotifier =
      StreamController<FormeSearchableEvent<T>>.broadcast();

  FormeSearchableEvent<T>? _lastSuccessEvent;
  final FormeKey _formKey = FormeKey();

  @override
  FormeSearchableDefaultContent<T> get widget =>
      super.widget as FormeSearchableDefaultContent<T>;

  @override
  void dispose() {
    _eventNotifier.close();
    super.dispose();
  }

  void _query([int page = 1]) {
    searchable.query(condition, page);
  }

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
      stream: _eventNotifier.stream,
      paginationConfiguration: widget.paginationConfiguration,
      query: _query,
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
        widget.eventBuilder(context, _eventNotifier.stream),
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
  void onSuccess(FormeSearchablePageResult<T> result, int currentPage,
      Map<String, dynamic> condition) {
    if (!mounted) {
      return;
    }
    _eventNotifier
        .add(FormeSearchableEvent.success(result, currentPage, condition));
  }

  @override
  void onProcessing() {
    if (!mounted) {
      return;
    }
    _eventNotifier.add(FormeSearchableEvent.processing());
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    if (!mounted) {
      return;
    }
    final FormeSearchableEvent<T> successEvent =
        FormeSearchableEvent.error(error, stackTrace);
    _lastSuccessEvent = successEvent;
    _eventNotifier.add(successEvent);
  }

  @override
  void onSelectedChanged(List<T> value) {
    if (_lastSuccessEvent != null) {
      _eventNotifier.add(_lastSuccessEvent!);
    }
  }
}

class _Header<T extends Object> extends FormeSearchableEventConsumer<T> {
  final FormePaginationConfiguration paginationConfiguration;
  final ValueChanged<int> query;

  const _Header({
    Key? key,
    required Stream<FormeSearchableEvent<T>> stream,
    required this.paginationConfiguration,
    required this.query,
  }) : super(key: key, stream: stream);

  @override
  _HeaderState<T> createState() => _HeaderState<T>();
}

class _HeaderState<T extends Object>
    extends FormeSearchableEventConsumerState<T> {
  @override
  _Header<T> get widget => super.widget as _Header<T>;

  FormeSearchableEvent<T>? _event;

  @override
  void onEventChanged(FormeSearchableEvent<T> event) {
    if (event.isSuccess) {
      setState(() {
        _event = event;
      });
    }
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

class DefaultEventBuilder<T extends Object>
    extends FormeSearchableEventConsumer<T> {
  final WidgetBuilder? processingBuilder;
  final WidgetBuilder? errorBuilder;
  final Widget Function(BuildContext context, T data, bool isSelected)?
      selectableItemBuilder;
  DefaultEventBuilder({
    Key? key,
    required Stream<FormeSearchableEvent<T>> stream,
    this.processingBuilder,
    this.errorBuilder,
    this.selectableItemBuilder,
  }) : super(key: key, stream: stream);
  @override
  _FormeDefaultSearchableDataContentState<T> createState() =>
      _FormeDefaultSearchableDataContentState<T>();
}

class _FormeDefaultSearchableDataContentState<T extends Object>
    extends FormeSearchableEventConsumerState<T> {
  @override
  DefaultEventBuilder<T> get widget => super.widget as DefaultEventBuilder<T>;

  FormeSearchableEvent<T>? _event;

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
    if (_event == null) {
      return const SizedBox.shrink();
    }
    if (_event!.isProcessing) {
      return (widget.processingBuilder ?? _defaultProcessingBuilder)(context);
    }
    if (_event!.hasError) {
      return (widget.errorBuilder ?? _defaultErrorBuilder)(context);
    }
    return Flexible(
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
    ));
  }

  @override
  void onEventChanged(FormeSearchableEvent<T> event) {
    setState(() {
      _event = event;
    });
  }
}
