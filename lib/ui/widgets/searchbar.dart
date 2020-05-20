import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///  @author Davy
///  @date 2019/8/1 14:06
///  @desc

class SearchAppBarWidgetWidget extends StatefulWidget
    implements PreferredSizeWidget {
  @override
  State<StatefulWidget> createState() => _SearchAppBarState();

  final double height;
  final double elevation; //阴影
  final Widget leading;
  final String hintText;
  final FocusNode focusNode;
  final TextEditingController controller;
  final IconData prefixIcon;
  final List<TextInputFormatter> inputFormatters;
  final VoidCallback onEditingComplete;

  const SearchAppBarWidgetWidget(
      {Key key,
      this.height: 46.0,
      this.elevation: 0.5,
      this.leading,
      this.hintText: '',
      this.focusNode,
      this.controller,
      this.inputFormatters,
      this.onEditingComplete,
      this.prefixIcon: Icons.search})
      : super(key: key);

  @override
  Size get preferredSize => null;
}

class _SearchAppBarState extends State<SearchAppBarWidgetWidget> {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      child: Container(
        child: Text("搜索头"),
      ),
      preferredSize: Size.fromHeight(widget.height),
    );
  }
}
