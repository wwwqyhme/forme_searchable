import 'package:flutter/widgets.dart';

import 'forme_searchable.dart';

abstract class FormeSearchableContent<T extends Object> extends StatefulWidget {
  const FormeSearchableContent({Key? key}) : super(key: key);

  @override
  FormeSearchableContentState createState();
}

abstract class FormeSearchableContentState<T extends Object>
    extends State<FormeSearchableContent<T>> with FormeSearchableObserver<T> {
  @protected
  late FormeSearchableData<T> searchable;

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    searchable = FormeSearchableData.of<T>(context);
    searchable.setObserver(this);
  }
}
