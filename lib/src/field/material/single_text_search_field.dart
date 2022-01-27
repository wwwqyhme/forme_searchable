import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forme/forme.dart';

class SingleTextSearchField extends StatefulWidget {
  final Duration debounce;
  final InputDecoration? decoration;
  final FormeKey formKey;
  final String name;
  final VoidCallback query;
  final VoidCallback selectHighlight;
  final EdgeInsetsGeometry? padding;

  const SingleTextSearchField({
    Key? key,
    this.debounce = const Duration(milliseconds: 200),
    this.decoration,
    required this.formKey,
    this.name = 'query',
    required this.query,
    required this.selectHighlight,
    this.padding,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SingleSearchFieldState();
}

class _SingleSearchFieldState extends State<SingleTextSearchField> {
  Timer? timer;

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Forme(
      key: widget.formKey,
      onValueChanged: (f, dynamic v) {
        timer?.cancel();
        timer = Timer(widget.debounce, () {
          widget.query();
        });
      },
      child: FormeField<String>(
          name: widget.name,
          registrable: true,
          onInitialed: (field) {
            WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
              field.focusNode?.requestFocus();
            });
          },
          builder: (state) {
            return Padding(
                padding: widget.padding ??
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: TextFormField(
                  onFieldSubmitted: (String value) {
                    widget.selectHighlight();

                    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                      state.focusNode.requestFocus();
                    });
                  },
                  // autofocus: true,
                  controller: _controller,
                  focusNode: state.focusNode,
                  decoration: widget.decoration ??
                      InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        suffixIconConstraints: const BoxConstraints.tightFor(),
                        suffixIcon: Builder(
                          builder: (context) {
                            return ValueListenableBuilder2<bool, String>(
                                state.controller.focusListenable,
                                state.controller.valueListenable,
                                builder: (context, a, b, child) {
                              if (a && b.isNotEmpty) {
                                return IconButton(
                                    onPressed: () {
                                      state.value = '';
                                      _controller.clear();
                                    },
                                    icon: const Icon(Icons.clear));
                              }
                              return const SizedBox.shrink();
                            });
                          },
                        ),
                      ),
                  onChanged: (String v) {
                    state.didChange(v);
                  },
                ));
          },
          initialValue: ''),
    );
  }
}
