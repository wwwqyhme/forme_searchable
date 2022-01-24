import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final ValueChanged<int> onPageChanged;
  final FormePaginationConfiguration configuration;
  final FormeSearchablePaginationController controller;

  const FormeSearchablePaginationBar({
    Key? key,
    required this.totalPage,
    required this.onPageChanged,
    required this.configuration,
    required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FormeSearchablePaginationBarState();
}

class _FormeSearchablePaginationBarState
    extends State<FormeSearchablePaginationBar> {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.controller.value}');
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _controller.text = '$_currentPage';
      }
    });
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          _controller.text = '$_currentPage';
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
        widget.controller.value = page;
        widget.onPageChanged(_currentPage);
      }
    }
  }

  int get _currentPage => widget.controller.value;

  Widget _prev() {
    final VoidCallback? onTap = _currentPage == 1
        ? null
        : () {
            widget.controller.value = _currentPage - 1;
            widget.onPageChanged(_currentPage);
          };
    if (widget.configuration.prev == null) {
      return IconButton(
          onPressed: onTap,
          icon:
              Icon(widget.configuration.prevIcon ?? Icons.arrow_left_rounded));
    }
    return InkWell(
      onTap: onTap,
      child: widget.configuration.prev,
    );
  }

  Widget _next() {
    final VoidCallback? onTap = _currentPage == widget.totalPage
        ? null
        : () {
            widget.controller.value = _currentPage + 1;
            widget.onPageChanged(_currentPage);
          };
    if (widget.configuration.next == null) {
      return IconButton(
          onPressed: onTap,
          icon:
              Icon(widget.configuration.nextIcon ?? Icons.arrow_right_rounded));
    }
    return InkWell(
      onTap: onTap,
      child: widget.configuration.prev,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _prev(),
        Expanded(
          child: Center(
            child: IntrinsicWidth(
              child: TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.go,
                focusNode: _focusNode,
                controller: _controller,
                onFieldSubmitted: (value) => _submitInputPage(),
                inputFormatters: <TextInputFormatter>[
                  _TextInputFormatter(widget.totalPage),
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                      right: -2), //TODO -2 on all devices?
                  border: InputBorder.none,
                  suffixIcon: const SizedBox.shrink(),
                  suffixIconConstraints: const BoxConstraints.tightFor(),
                  suffixText: '/${widget.totalPage}',
                  suffixStyle: Theme.of(context).textTheme.subtitle1,
                ),
                textAlign: TextAlign.right,
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

class FormeSearchablePaginationController extends ValueNotifier<int> {
  FormeSearchablePaginationController(int value) : super(value);
}
