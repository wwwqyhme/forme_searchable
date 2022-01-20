import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

import '../../../forme_searchable.dart';

mixin FormeSearchableObserver<T extends Object> {
  void onSuccess(FormeSearchablePageResult<T> result, int currentPage,
      Map<String, dynamic> condition);

  void onError(Object error, StackTrace stackTrace);

  void onProcessing();

  void onSelected(List<T> selected);
}

abstract class FormeSearchableObserverHelper<T extends Object>
    extends StatefulWidget {
  @protected
  const FormeSearchableObserverHelper({
    Key? key,
  }) : super(key: key);

  @override
  FormeSearchableObserverHelperState<T> createState();
}

abstract class FormeSearchableObserverHelperState<T extends Object>
    extends State<FormeSearchableObserverHelper<T>>
    with FormeSearchableObserver<T> {
  @protected
  late FormeSearchableData<T> _searchable;

  FormeAsyncOperationState? _state;
  FormeSearchablePageResult<T>? _result;
  int _currentPage = 1;
  Map<String, dynamic>? _condition;

  FormeAsyncOperationState? get state => _state;
  FormeSearchablePageResult<T>? get result => _result;
  int get currentPage => _currentPage;
  Map<String, dynamic>? get condition => _condition;

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _searchable = FormeSearchableData.of<T>(context);
    _searchable.setObserver(this);
  }

  @override
  @mustCallSuper
  void onSuccess(FormeSearchablePageResult<T> result, int currentPage,
      Map<String, dynamic> condition) {
    if (mounted) {
      _result = result;
      _currentPage = currentPage;
      _condition = condition;
      _state = FormeAsyncOperationState.success;
      onSuccessIfMounted(result, currentPage, condition);
    }
  }

  @override
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    if (mounted) {
      _state = FormeAsyncOperationState.error;
      onErrorIfMounted(error, stackTrace);
    }
  }

  @override
  @mustCallSuper
  void onProcessing() {
    if (mounted) {
      _state = FormeAsyncOperationState.processing;
      onProcessingIfMounted();
    }
  }

  @override
  @mustCallSuper
  void onSelected(List<T> selected) {
    if (mounted) {
      onSelectedIfMounted(selected);
    }
  }

  void onProcessingIfMounted();
  void onErrorIfMounted(Object error, StackTrace stackTrace);
  void onSuccessIfMounted(FormeSearchablePageResult<T> result, int currentPage,
      Map<String, dynamic> condition);
  void onSelectedIfMounted(List<T> selected);

  @protected
  List<T> get selected => _searchable.value;

  @protected
  bool isSelected(T data) => _searchable.contains(data);

  @protected
  void close() => _searchable.close();

  @protected
  void toggle(T data) => _searchable.toggle(data);

  @protected
  void query(Map<String, dynamic> condition, int page) =>
      _searchable.query(condition, page);
}
