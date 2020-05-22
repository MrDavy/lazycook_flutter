import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lazycook/core/models/version_info.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/person/login/user_model.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/base_state.dart';
import 'package:lazycook/ui/widgets/dialog/custom_dialog.dart';
import 'package:lazycook/ui/widgets/loading_dialog.dart';
import 'package:lazycook/ui/widgets/typedef.dart';
import 'package:lazycook/utils/fluro/src/common.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:lazycook/utils/utils.dart';
import 'package:provider/provider.dart';

enum DialogType { SELECTOR, GENERAL }

abstract class CustomState<T extends StatefulWidget> extends BaseState<T>
    with AutomaticKeepAliveClientMixin {
  bool dialogShowing = false;
  BuildContext buildContext;
  BuildContext scaffoldContext;
  Color _accentColor;

  bool keepAlive() => false;

  bool darkStatusBar() => false;

  Color get themeAccentColor => _accentColor;

  @override
  Widget build(BuildContext context) {
    if (keepAlive()) super.build(context);
    _accentColor = Theme.of(context).accentColor;
    buildContext = context;
    return AnnotatedRegion(
        child: buildWidget(context),
        value: darkStatusBar()
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light);
  }

  Widget buildWidget(BuildContext context);

  API api() {
    return Provider.of(context, listen: false);
  }

  Future checkLogin() async {
    ///type：0未登录，1已登录，2未登录并重新登录成功
    var type =
        Provider.of<UserModel>(context, listen: false).hasUser == true ? 1 : 0;
    if (type == 0) {
      if (await toLogin() ?? false) {
        type = 2;
      }
    }
    return type;
  }

  Future toLogin() {
    return Nav.pageTo(context, Routers.login);
  }

  Future simpleFuture(Future future,
      {String loadingMsg = "", bool cancelable = true}) async {
    showLoading(loadingMsg ?? "", cancelable: cancelable);
    var result;
    try {
      result = await future;
    } catch (e) {}
    hideLoading();
    if (result != null && result is LazyError) {
      showToast(result.message);
    }
    return result;
  }

  showToast(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  void hideLoading() {
    if (dialogShowing && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      dialogShowing = false;
    }
  }

  showLoading(msg, {bool cancelable = true}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingDialog(
              msg: msg,
              cancelable: cancelable,
            ));
    dialogShowing = true;
  }

  hideDialog() {
    Nav.back();
  }

  showVersionUpdateDialog(VersionInfo data, {bool showTips = true}) {
    if (data.hasNewVersion == 1) {
      showCustomDialog(
          context: context,
          dialogType: DialogType.GENERAL,
          cancelable: false,
          title: "检测到新版本",
          msg: data.description,
          cancelText: "暂不",
          confirmText: "去更新",
          alignment: Alignment.center,
          onCancel: () {
            hideDialog();
          },
          onConfirm: () {
            hideDialog();
            Utils.openWebOut(data.url);
          });
    } else {
      if (showTips) showToast(data.description);
    }
  }

  showCustomDialog({
    @required BuildContext context,
    DialogType dialogType = DialogType.SELECTOR,
    title,
    msg,
    cancelText,
    confirmText,
    contentView,
    cancelColor,
    confirmColor,
    onCancel,
    onConfirm,
    alignment,
    maxWidth,
    maxHeight,
    mWidth,
    mHeight,
    decoration,
    touchOutCancel = true,
    cancelable = true,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return CustomDialog(
          title: title,
          msg: msg,
          cancelText: cancelText,
          confirmText: confirmText,
          contentView: contentView,
          cancelColor: cancelColor,
          confirmColor: confirmColor,
          onCancel: onCancel,
          onConfirm: onConfirm,
          alignment: alignment,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          mWidth: mWidth,
          mHeight: mHeight,
          decoration: decoration,
          touchOutCancel: touchOutCancel,
          cancelable: cancelable,
        );
      },
      barrierColor: Colors.black.withOpacity(.3),
      barrierDismissible: false,
      barrierLabel: "",
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (dialogType == DialogType.SELECTOR) {
          return FractionalTranslation(
            translation: Offset(0, 1 - animation.value),
            child: child,
          );
        } else {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        }
      },
    );
  }

  void showSnack(String content,
      {Duration duration, Icon icon, Color backgroundColor, TextStyle style}) {
    List<Widget> views = [];
    if (icon != null) {
      views.add(icon);
      views.add(SizedBox(
        width: ScreenUtil.getInstance().setWidth(2),
      ));
    }
    views.add(Text(
      content,
      style: style ?? TextStyle(color: Colors.white),
    ));
    Scaffold.of(scaffoldContext).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: duration ?? Duration(milliseconds: 1500),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: views,
      ),
      backgroundColor: backgroundColor ?? Theme.of(context).errorColor,
    ));
  }

  Future<ImageSource> showPictureSelectDialog(
      {OnImageSourceSelect onImageSourceSelect}) async {
    ImageSource source;
    await showCustomDialog(
      context: context,
      contentView: Container(
        padding: EdgeInsets.only(bottom: height(10)),
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: <Widget>[
                  InkWell(
                    child: Container(
                      width: double.infinity,
                      height: height(40),
                      child: Center(
                        child: Text(
                          "拍照",
                          style: TextStyle(
                              color: textColor,
                              fontSize: sp(16),
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      source = ImageSource.camera;
                      if (onImageSourceSelect != null)
                        onImageSourceSelect(ImageSource.camera);
                    },
                  ),
                  Container(
                    width: double.infinity,
                    height: height(1),
                    color: gray,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      source = ImageSource.gallery;
                      if (onImageSourceSelect != null)
                        onImageSourceSelect(ImageSource.gallery);
                    },
                    child: Container(
                      width: double.infinity,
                      height: height(40),
                      child: Center(
                        child: Text(
                          "从手机相册选择",
                          style: textStyle(
                              color: textColor,
                              fontSize: sp(16),
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height(10),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: height(40),
                decoration: BoxDecoration(
                    color: white, borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(
                    "取消",
                    style: textStyle(
                        color: textColor,
                        fontSize: sp(16),
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      maxWidth: ScreenUtil.screenWidthDp * .98,
      mWidth: ScreenUtil.screenWidthDp * .98,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(),
    );
    return source;
  }

  ///type:1.album，2.step
  Future selectPicture({bool crop = false, num mWidth, num mHeight}) async {
    var source = await showPictureSelectDialog();
    if (source == null) return null;
    var image = await ImagePicker.pickImage(source: source);
    var result;
    if (crop && image != null) {
      var value = await Nav.pageTo(context, Routers.crop,
          param: {
            "image": image.path,
            "width": (mWidth == null || mWidth < 0)
                ? ScreenUtil.screenWidthDp
                : mWidth,
            "height": (mHeight == null || mHeight < 0)
                ? ScreenUtil.screenWidthDp * .7
                : mHeight
          },
          transition: TransitionType.fadeIn);
      if (value != null) {
        result = value["image"];
      }
    } else {
      result = image;
    }
    return result;
  }

  @override
  bool get wantKeepAlive => keepAlive();
}
