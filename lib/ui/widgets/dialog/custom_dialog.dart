import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/base_state.dart';
import 'package:lazycook/ui/widgets/dialog/base_dialog.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:lazycook/utils/string_utils.dart';

class CustomDialog extends BaseDialog {
  final String title;
  final String msg;
  final Color cancelColor;
  final Color confirmColor;
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Widget contentView;
  final AlignmentGeometry alignment;
  final num maxWidth;
  final num maxHeight;
  final num mWidth;
  final num mHeight;
  final bool touchOutCancel;
  final bool cancelable;

  final Decoration decoration;

  CustomDialog({
    this.title,
    this.msg,
    this.cancelText,
    this.confirmText,
    this.contentView,
    this.cancelColor,
    this.confirmColor,
    this.onCancel,
    this.onConfirm,
    this.alignment,
    this.maxWidth,
    this.maxHeight,
    this.mWidth,
    this.mHeight,
    this.decoration,
    this.touchOutCancel = true,
    this.cancelable=true,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (title?.isNotEmpty == true)
      children.add(Padding(
        padding: EdgeInsets.only(top: height(8)),
        child: Text(
          title,
          style: textStyle(
              color: textColor, fontSize: sp(17), fontWeight: FontWeight.w600),
        ),
      ));
    if (msg?.isNotEmpty == true) {
      children.add(Padding(
        padding:
            EdgeInsets.symmetric(vertical: height(16), horizontal: width(16)),
        child: Text(
          msg,
          style: textStyle(fontSize: sp(16), fontWeight: bold),
        ),
      ));
    }

    if (contentView != null) {
      children.add(contentView);
    }
    List<Widget> rowChildren = [];
    if (onCancel != null && StringUtils.isNotEmpty(cancelText)) {
      rowChildren.add(Expanded(
          child: InkWell(
        onTap: onCancel,
        child: Container(
          child: Center(
            child: Text(
              cancelText,
              style: textStyle(
                  color: cancelColor ?? Colors.black54,
                  fontSize: sp(16),
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
      )));
    }
    if (onConfirm != null && StringUtils.isNotEmpty(confirmText)) {
      rowChildren.add(Expanded(
          child: InkWell(
        onTap: onConfirm,
        child: Container(
          child: Center(
            child: Text(
              confirmText,
              style: textStyle(
                  color: confirmColor ?? accentColor,
                  fontSize: sp(16),
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
      )));
    } else {}

    if (rowChildren.isNotEmpty) {
      children.add(Container(
        height: 1,
        decoration: BoxDecoration(color: Colors.grey[100]),
      ));
      if (rowChildren.length == 2) {
        rowChildren.insert(
            1,
            Container(
              width: 1,
              height: 30,
              decoration: BoxDecoration(color: Colors.grey[100]),
            ));
      }
      children.add(Flexible(
        child: Container(
          height: height(40),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: rowChildren,
          ),
        ),
      ));
    }
    Offset offset;

    return WillPopScope(
        child: SafeArea(
          child: Listener(
            onPointerDown: cancelable && touchOutCancel
                ? (event) {
                    Offset pos = event.position;
                    if (offset == null ||
                        pos.dy != offset.dy ||
                        pos.dx != offset.dx) {
                      Navigator.pop(context);
                    }
                  }
                : null,
            child: Material(
              type: MaterialType.transparency,
              child: Align(
                alignment: alignment ?? Alignment.center,
                child: GestureDetector(
                  onPanDown: (event) {
                    offset = event.globalPosition;
                  },
                  child: Container(
                    constraints: BoxConstraints(
                        maxHeight: maxHeight ?? ScreenUtil.screenHeightDp * .8,
                        maxWidth: maxWidth ?? ScreenUtil.screenWidthDp * .8),
                    width: mWidth ?? ScreenUtil.screenWidthDp * 0.8,
                    height: mHeight,
                    decoration: decoration ??
                        BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () {
          return Future.value(cancelable ?? true);
        });
  }
}
