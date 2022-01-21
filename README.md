## FormeSearchable 

searchable widget for `Forme` 

## Demo 

https://www.qyh.me/forme3/#/FormeSearchable


## infinite scroll pagination

if you do not like default pagination , you can implementing infinite scroll pagination  via [infinite_scroll_pagination](https://pub.dev/packages/infinite_scroll_pagination) easily

 create a `FormeSearchableContent` widget first

``` Dart
import 'package:flutter/material.dart';
import 'package:forme/forme.dart';
import 'package:forme_searchable/forme_searchable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FormeSearchableContent2<T extends Object>
    extends FormeSearchableObserverHelper<T> {
  const FormeSearchableContent2({
    Key? key,
  }) : super(
          key: key,
        );

  @override
  _FormeSearchableContent2State<T> createState() =>
      _FormeSearchableContent2State<T>();
}

class _FormeSearchableContent2State<T extends Object>
    extends FormeSearchableObserverHelperState<T> {
  late final PagingController<int, T> _pagingController;

  @override
  void initState() {
    _pagingController = PagingController<int, T>(
      firstPageKey: 1,
    );
    _pagingController.addPageRequestListener((pageKey) {
      query({'query': '1'}, pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: Material(
        elevation: 4,
        child: PagedListView.separated(
          pagingController: _pagingController,
          padding: const EdgeInsets.all(16),
          separatorBuilder: (context, index) => const SizedBox(
            height: 16,
          ),
          builderDelegate: PagedChildBuilderDelegate<T>(
            itemBuilder: (context, data, index) => InkWell(
              child: ListTile(
                leading: isSelected(data) ? const Text('checked') : null,
                title: Text('$data'),
              ),
              onTap: () {
                toggle(data);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onErrorIfMounted(Object error, StackTrace stackTrace) {
    _pagingController.error = error;
  }

  @override
  void onProcessingIfMounted() {}

  @override
  void onSelectedIfMounted(List<T> selected) {
    setState(() {});
  }

  @override
  void onSuccessIfMounted(FormeSearchablePageResult<T> result, int currentPage,
      Map<String, dynamic> condition) {
    if (currentPage == result.totalPage) {
      _pagingController.appendLastPage(result.datas);
    } else {
      _pagingController.appendPage(result.datas, currentPage + 1);
    }
  }
}
```

use this content in your `FormeSearchable` widget :

``` Dart
FormeSearchable<String>.overlay(
    name: 'searchable',
    query: _defaultQuery,
    maxHeightProvider: (context) => 300,
    contentBuilder: (context) {
        return const FormeSearchableContent2<String>();
    },
)
```