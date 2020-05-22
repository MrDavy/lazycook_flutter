import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/base_state.dart';

class SearchView extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool autofocus;
  final Color borderColor;
  final Color fillColor;
  final String hintText;
  final Color hintColor;
  final Color contentColor;
  final ValueChanged<String> onFieldSubmitted;
  final Widget prefixIcon;
  final bool enable;
  final VoidCallback onClick;
  final String initialValue;

  SearchView({
    this.initialValue,
    this.enable = true,
    this.margin,
    this.focusNode,
    this.controller,
    this.autofocus = true,
    this.borderColor = white,
    this.fillColor = white,
    this.hintText,
    this.hintColor = const Color(0x60969696),
    this.contentColor = color_222,
    this.prefixIcon = const Icon(Icons.search, color: color_999),
    this.onFieldSubmitted,
    this.onClick,
  });

  @override
  SearchViewState createState() => new SearchViewState();
}

class SearchViewState extends BaseState<SearchView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: height(28),
      margin: widget.margin,
      decoration: BoxDecoration(
          color: widget.fillColor,
          borderRadius: BorderRadius.all(Radius.circular(width(18)))),
      child: InkWell(
        onTap: widget.onClick,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: TextFormField(
                  enabled: widget.enable,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.text,
                  focusNode: widget.focusNode,
                  cursorRadius: Radius.circular(width(1)),
                  cursorWidth: width(2),
                  controller: widget.controller,
                  autofocus: widget.autofocus,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: textStyle(
                        color: widget.hintColor,
                        fontSize: sp(14),
                        fontWeight: bold),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(width(18))),
                      borderSide: BorderSide(color: widget.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(width(18))),
                      borderSide: BorderSide(color: widget.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(width(18))),
                      borderSide: BorderSide(color: widget.borderColor),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(width(18))),
                      borderSide: BorderSide(color: widget.borderColor),
                    ),
                    filled: true,
                    fillColor: widget.fillColor,
                    hasFloatingPlaceholder: false,
                    alignLabelWithHint: false,
                    contentPadding: EdgeInsets.zero,
                    prefixIcon: widget.prefixIcon,
                  ),
                  style: textStyle(
                      color: widget.contentColor,
                      fontSize: sp(14),
                      fontWeight: FontWeight.w600),
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (value) {
                    widget.onFieldSubmitted(value);
                  }
//              keyboardAppearance: Theme.of(context).brightness,
                  ),
            )
          ],
        ),
      ),
    );
  }
}
