import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/dialog/base_dialog.dart';

/*
 * 加载动画
 */
class LoadingDialog extends BaseDialog {
  final String msg;
  final bool cancelable;

  LoadingDialog({Key key, this.cancelable = true, this.msg});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: SizedBox(
              width: width(100),
              height: width(100),
              child: Center(
                child: Container(
                  decoration: ShapeDecoration(
                      color: Color(0x7f000000),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(width(8))))),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: width(32),
                          height: width(32),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        msg?.isNotEmpty == true
                            ? Padding(
                                padding: EdgeInsets.only(top: height(12)),
                                child: Text(
                                  msg,
                                  style: textStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: sp(12)),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () => Future.value(cancelable));
  }
}
