import 'dart:async';

import 'package:flutter/material.dart';

import '../../../forme_searchable.dart';

abstract class FormeSearchableEventConsumer<T extends Object>
    extends StatefulWidget {
  final Stream<FormeSearchableEvent<T>> stream;
  final Stream<FormeSearchableSelectedEvent<T>> selectedStream;
  @protected
  const FormeSearchableEventConsumer({
    Key? key,
    required this.stream,
    required this.selectedStream,
  }) : super(key: key);

  @override
  FormeSearchableEventConsumerState<T> createState();
}

abstract class FormeSearchableEventConsumerState<T extends Object>
    extends State<FormeSearchableEventConsumer<T>> {
  late StreamSubscription<FormeSearchableEvent<T>> _streamSubscription;
  late StreamSubscription<FormeSearchableSelectedEvent<T>>
      _selectedStreamSubscription;
  @protected
  late FormeSearchableData<T> searchable;

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    searchable = FormeSearchableData.of<T>(context);
  }

  @override
  void initState() {
    super.initState();
    _selectedStreamSubscription =
        widget.selectedStream.listen(_onSelectedChanged);
    _streamSubscription = widget.stream.listen(_onEventChanged);
  }

  void _onEventChanged(FormeSearchableEvent<T> event) {
    if (mounted) {
      onEventChanged(event);
    }
  }

  void _onSelectedChanged(FormeSearchableSelectedEvent<T> event) {
    if (mounted) {
      onSelectedChanged(event);
    }
  }

  @protected
  void onEventChanged(FormeSearchableEvent<T> event);
  @protected
  void onSelectedChanged(FormeSearchableSelectedEvent<T> event);

  @override
  void didUpdateWidget(FormeSearchableEventConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream) {
      _streamSubscription.cancel();
      _streamSubscription = widget.stream.listen(_onEventChanged);
    }
    if (widget.selectedStream != oldWidget.selectedStream) {
      _selectedStreamSubscription.cancel();
      _selectedStreamSubscription =
          widget.selectedStream.listen(_onSelectedChanged);
    }
  }

  @override
  void dispose() {
    _selectedStreamSubscription.cancel();
    _streamSubscription.cancel();
    super.dispose();
  }
}
