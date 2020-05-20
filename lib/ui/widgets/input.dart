import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';

typedef OnTextFocusChange = void Function(bool hasFocus);

class Input extends StatefulWidget {
  final double iconWidth;
  final double iconHeight;
  final EdgeInsetsGeometry contentPadding;
  final double space;
  final bool autoFocus;
  final ImageProvider icon;
  final ImageProvider focusIcon;
  final String hint;
  final TextStyle hintStyle;
  final TextStyle textStyle;
  final ValueChanged<String> onSubmit;
  final TextInputAction textInputAction;
  final InputBorder border;
  final TextEditingController textEditingController;
  final OnTextFocusChange onTextFocusChange;

  const Input(
      {Key key,
      this.iconWidth,
      this.iconHeight,
      this.space,
      this.icon,
      this.focusIcon,
      this.autoFocus,
      this.hint,
      this.hintStyle,
      this.textStyle,
      this.onSubmit,
      this.textInputAction,
      this.contentPadding,
      this.border = InputBorder.none,
      this.textEditingController,
      this.onTextFocusChange})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => InputState();
}

class InputState extends CustomState<Input> {
  FocusNode _contentFocusNode = FocusNode();
  bool focus = false;

  @override
  void initState() {
    _contentFocusNode.addListener(() {
      setState(() {
        focus = _contentFocusNode.hasFocus;
      });
      if (widget.onTextFocusChange != null) {
        widget.onTextFocusChange(_contentFocusNode.hasFocus);
      }
    });
    super.initState();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Image(
          alignment: Alignment.center,
          width: widget.iconWidth,
          height: widget.iconHeight,
          image: focus ? widget.focusIcon : widget.icon,
        ),
        SizedBox(
          width: widget.space,
        ),
        Expanded(
            child: TextFormField(
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                focusNode: _contentFocusNode,
                cursorRadius: Radius.circular(width(1)),
                cursorWidth: width(2),
                controller: widget.textEditingController,
                autofocus: widget.autoFocus,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: widget.hintStyle,
                  border: widget.border,
                  filled: false,
                  hasFloatingPlaceholder: false,
                  alignLabelWithHint: false,
                  contentPadding: widget.contentPadding,
                ),
                style: widget.textStyle,
                textInputAction: widget.textInputAction,
                onFieldSubmitted: (value) {
                  if (widget.onSubmit != null) {
                    widget.onSubmit(value);
                  }
                }))
      ],
    );
  }
}
