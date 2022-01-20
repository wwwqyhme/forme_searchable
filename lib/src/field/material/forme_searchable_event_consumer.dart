import 'package:flutter/material.dart';

import '../../../forme_searchable.dart';
import 'forme_searchable_event.dart';

abstract class FormeSearchableEventConsumer<T extends Object>
    extends StatefulWidget {
  final Stream<FormeSearchableEvent<T>> stream;
  @protected
  const FormeSearchableEventConsumer({Key? key, required this.stream})
      : super(key: key);

  @override
  FormeSearchableEventConsumerState<T> createState();
}

abstract class FormeSearchableEventConsumerState<T extends Object>
    extends State<FormeSearchableEventConsumer<T>> {
  late StreamSubscription<FormeSearchableEvent<T>> _streamSubscription;
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
    _streamSubscription = widget.stream.listen(onEventChanged);
  }

  void onEventChanged(FormeSearchableEvent<T> event);

  @override
  void didUpdateWidget(FormeSearchableEventConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream) {
      _streamSubscription.cancel();
      _streamSubscription = widget.stream.listen(onEventChanged);
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
