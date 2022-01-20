import 'forme_page_result.dart';

class FormeSearchableEvent<T extends Object> {
  final Object? error;
  final StackTrace? stackTrace;
  final bool processing;
  final FormeSearchablePageResult<T>? result;
  final int? currentPage;
  final Map<String, dynamic>? condition;

  bool get isSuccess => result != null;
  bool get isProcessing => processing;
  bool get hasError => stackTrace != null;

  FormeSearchableEvent._(this.error, this.stackTrace, this.processing,
      this.result, this.currentPage, this.condition);

  factory FormeSearchableEvent.error(Object error, StackTrace stackTrace) {
    return FormeSearchableEvent._(error, stackTrace, false, null, null, null);
  }

  factory FormeSearchableEvent.processing() {
    return FormeSearchableEvent._(null, null, true, null, null, null);
  }

  factory FormeSearchableEvent.success(FormeSearchablePageResult<T> result,
      int currentPage, Map<String, dynamic> condition) {
    return FormeSearchableEvent._(
        null, null, true, result, currentPage, condition);
  }
}
