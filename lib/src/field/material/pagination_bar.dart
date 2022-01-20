import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';

class FormePaginationConfiguration {
  final Widget? prev;
  final Widget? next;
  final IconData? prevIcon;
  final IconData? nextIcon;
  final bool enable;

  const FormePaginationConfiguration({
    this.prev,
    this.next,
    this.prevIcon,
    this.nextIcon,
    this.enable = true,
  });
}

class FormeSearchablePaginationBar extends StatefulWidget {
  final int totalPage;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final FormePaginationConfiguration configuration;

  const FormeSearchablePaginationBar({
    Key? key,
    required this.totalPage,
    required this.currentPage,
    required this.onPageChanged,
    required this.configuration,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FormeSearchablePaginationBarState();
}

class _FormeSearchablePaginationBarState
    extends State<FormeSearchablePaginationBar> {
  final FocusNode _focusNode = FocusNode();
  late final ValueNotifier<int> _pageNotifier;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _pageNotifier = FormeMountedValueNotifier(widget.currentPage, this);
    _controller = TextEditingController(text: '${widget.currentPage}');
    _pageNotifier.addListener(() {
      if (mounted) {
        _controller.text = '$_currentPage';
        widget.onPageChanged(_currentPage);
      }
    });
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _controller.text = '$_currentPage';
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageNotifier.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitInputPage() {
    final String text = _controller.text;
    final int? page = int.tryParse(text);
    if (page == null) {
      _controller.text = '$_currentPage';
    } else {
      if (page > widget.totalPage || page < 1) {
        _controller.text = '$_currentPage';
      } else {
        _pageNotifier.value = page;
      }
    }
  }

  int get _currentPage => _pageNotifier.value;

  Widget _prev() {
    return ValueListenableBuilder<int>(
        valueListenable: _pageNotifier,
        builder: (context, page, child) {
          final VoidCallback? onTap = page == 1
              ? null
              : () {
                  _pageNotifier.value = page - 1;
                };
          if (widget.configuration.prev == null) {
            return IconButton(
                onPressed: onTap,
                icon: Icon(
                    widget.configuration.prevIcon ?? Icons.arrow_left_rounded));
          }
          return InkWell(
            onTap: onTap,
            child: widget.configuration.prev,
          );
        });
  }

  Widget _next() {
    return ValueListenableBuilder<int>(
        valueListenable: _pageNotifier,
        builder: (context, page, child) {
          final VoidCallback? onTap = page == widget.totalPage
              ? null
              : () {
                  _pageNotifier.value = page + 1;
                };
          if (widget.configuration.next == null) {
            return IconButton(
                onPressed: onTap,
                icon: Icon(widget.configuration.nextIcon ??
                    Icons.arrow_right_rounded));
          }
          return InkWell(
            onTap: onTap,
            child: widget.configuration.prev,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _prev(),
        Expanded(
          child: Center(
            child: IntrinsicWidth(
              child: ValueListenableBuilder<int>(
                valueListenable: _pageNotifier,
                builder: (context, page, child) {
                  return TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.go,
                    focusNode: _focusNode,
                    controller: _controller,
                    onFieldSubmitted: (value) => _submitInputPage(),
                    inputFormatters: <TextInputFormatter>[
                      _TextInputFormatter(widget.totalPage),
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: const SizedBox.shrink(),
                      suffixIconConstraints: const BoxConstraints.tightFor(),
                      suffixText: '/${widget.totalPage}',
                      suffixStyle: Theme.of(context).textTheme.subtitle1,
                    ),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
          ),
        ),
        _next(),
      ],
    );
  }
}

class _TextInputFormatter extends TextInputFormatter {
  final int max;

  _TextInputFormatter(this.max);
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final int? current = int.tryParse(newValue.text);
    if (current == null || current < 1 || current > max) {
      return oldValue;
    }
    return newValue;
  }
}
