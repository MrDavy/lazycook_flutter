import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/person/code_model.dart';
import 'package:lazycook/core/viewmodels/person/login/login.dart';
import 'package:lazycook/core/viewmodels/person/login/register.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/avatar.dart';
import 'package:lazycook/ui/widgets/button.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/utils/encrypt/encrypt.dart';
import 'package:lazycook/utils/fluro/fluro.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:lazycook/utils/utils.dart';
import 'package:provider/provider.dart';

///
/// 注册
///
class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => new RegisterPageState();
}

class RegisterPageState extends CustomState<RegisterPage> {
  TextEditingController _phoneEtController;
  TextEditingController _pwdEtController;
  TextEditingController _codeEtController;

  ///输入框参数
  FocusNode _pwdNode = FocusNode();
  FocusNode _codeNode = FocusNode();
  FocusNode _phoneNode = FocusNode();
  GlobalKey _formKey = GlobalKey<FormState>();
  GlobalKey _phoneKey = GlobalKey<FormFieldState>();
  GlobalKey _pwdKey = GlobalKey<FormFieldState>();
  GlobalKey _codeKey = GlobalKey<FormFieldState>();

  RegisterModel _registerModel;
  CodeModel _codeModel;
  TapGestureRecognizer _recognizer;
  Map _inputDecoration;
  ThemeData _themeData;

  @override
  void initState() {
    super.initState();
    _phoneEtController = TextEditingController();
    _pwdEtController = TextEditingController();
    _codeEtController = TextEditingController();
    var repository = Provider.of<API>(context, listen: false);
    _registerModel = RegisterModel(api: repository);
    _codeModel = CodeModel(repository);
    _recognizer = TapGestureRecognizer()..onTap = showProtocol;
  }

  showProtocol() {
    Nav.pageTo(context, Routers.web,
        transition: TransitionType.cupertinoFullScreenDialog,
        param: {
          "url":
              "https://storage-1255928497.cos.ap-guangzhou.myqcloud.com/lazycook/file/protocol.html",
          "title": "用户协议"
        });
  }

  @override
  bool darkStatusBar() {
    return true;
  }

  @override
  Widget buildWidget(BuildContext context) {
    _themeData = Theme.of(context);
    _inputDecoration =
        createDecoration(borderColor, themeAccentColor, _themeData.errorColor);
    return Scaffold(
      appBar: new AppBar(
        elevation: 0,
        backgroundColor: white,
        iconTheme: IconThemeData(color: Colors.black),
        brightness: Brightness.light,
        title: new Text(
          '注册账号',
          style: textStyle(
            color: Colors.black,
            fontSize: sp(18),
            fontWeight: bold,
          ),
        ),
      ),
      body: ChangeNotifierProvider(
        create: (context) {
          return _registerModel;
        },
        child: Container(
          color: white,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ///这里使用Expanded并且flex=1是为了让内部的Widget占满Column
              Expanded(
                flex: 1,

                ///这里用ListView是为了让键盘不遮挡TextField组件
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification note) {
                    return true;
                  },
                  child: ListView(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    children: <Widget>[
                      SizedBox(
                        height: height(40),
                      ),

                      ///头像
                      _buildAvatar(),

                      ///表单
                      _buildForm(),

                      ///这里将LoginButton放到ListView中是因为button不需要完全显示，可以被遮挡，如果放外边就会被键盘顶起
                      _registerButton(),

                      ///用户协议
                      _protocol(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool clearFocus() {
    if (_phoneNode.hasFocus) {
      _phoneNode.consumeKeyboardToken();
    }
  }

  Widget _protocol() {
    return Container(
      margin: EdgeInsets.fromLTRB(width(30), height(8), width(30), height(0)),
      child: RichText(
        text: TextSpan(
            text: "注册代表您同意",
            style: textStyle(
                color: hintColor,
                fontSize: sp(10),
                fontWeight: FontWeight.w400),
            children: <InlineSpan>[
              TextSpan(
                  text: "《用户协议》",
                  style: textStyle(
                      decoration: TextDecoration.underline,
                      color: themeAccentColor,
                      fontSize: sp(10),
                      fontWeight: FontWeight.w400),
                  recognizer: _recognizer)
            ]),
      ),
    );
  }

  Widget _registerButton() {
    return Button(
      margin: EdgeInsets.fromLTRB(width(30), height(22), width(30), height(0)),
      accentColor: themeAccentColor,
      text: "立即注册",
      onPressed: () async {
        if ((_formKey.currentState as FormState).validate()) {
          FocusScope.of(context).requestFocus(FocusNode());
          var result = await simpleFuture(_registerModel.register({
            "phone": _phoneEtController.text,
            "authCode": _codeEtController.text,
            "password": await EncryptUtils.encryptMD5(_pwdEtController.text)
          }));

          if (result == null) {
            Nav.back();
          }
        }
      },
    );
  }

  Widget _buildForm() {
    return Container(
        margin: EdgeInsets.only(
            left: width(30), right: width(30), top: height(40), bottom: 0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              autovalidate: false,
              child: Column(
                children: <Widget>[
                  _buildPhoneInput(),
                  SizedBox(height: height(20)),
                  _buildCodeInput(),
                  SizedBox(height: height(20)),
                  _buildPwdInput(),
                ],
              ),
            ),
          ],
        ));
  }

  ///
  /// 手机号输入框
  Widget _buildPhoneInput() {
    return TextFormField(
      key: _phoneKey,
      autofocus: true,
      focusNode: _phoneNode,
      controller: _phoneEtController,
      style: textStyle(
        color: textColor,
        fontWeight: FontWeight.w700,
        fontSize: sp(18),
      ),
      showCursor: true,
      cursorWidth: width(1),
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.next,
      keyboardType:
          TextInputType.numberWithOptions(signed: true, decimal: false),
      inputFormatters: [
        WhitelistingTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11)
      ],
      toolbarOptions: ToolbarOptions(),
      cursorColor: themeAccentColor,
      decoration: InputDecoration(
        focusedErrorBorder: _inputDecoration['focusedErrorBorder'],
        focusedBorder: _inputDecoration['focusedBorder'],
        border: _inputDecoration['border'],
        contentPadding: _inputDecoration['contentPadding'],
        labelText: "手机号",
        hintText: "输入用户手机号",
        labelStyle: inputLabelStyle(),
        focusColor: themeAccentColor,
        prefixIcon: Icon(Icons.phone_iphone),
        hintStyle: textStyle(
            color: hintColor, fontWeight: FontWeight.w400, fontSize: sp(14)),
      ),
      validator: (v) {
        logger.log("phone = $v");
        return v.trim().length <= 0
            ? "手机号不能为空"
            : Utils.validatePhone(v.trim()) ? null : "手机号格式有误";
      },
      onFieldSubmitted: (v) {
        _phoneNode.unfocus();
        FocusScope.of(context).requestFocus(_codeNode);
      },
    );
  }

  ///
  /// 密码输入框
  /// 使用Selector来局部刷新
  Widget _buildPwdInput() {
//    logger.log("_buildPwdInput");
    return Selector<RegisterModel, bool>(
      builder: (context, pwdVisible, child) => TextFormField(
        key: _pwdKey,
        autovalidate: false,
        autofocus: false,
        focusNode: _pwdNode,
        controller: _pwdEtController,
        style: textStyle(
          color: textColor,
          fontWeight: bold,
          fontSize: sp(18),
        ),
        showCursor: true,
        cursorWidth: width(1),
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.done,
        cursorColor: themeAccentColor,
        obscureText: Platform.isIOS ? false : !pwdVisible,
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.visiblePassword,
        toolbarOptions: ToolbarOptions(),
        inputFormatters: [LengthLimitingTextInputFormatter(16)],
        decoration: InputDecoration(
          focusedErrorBorder: _inputDecoration['focusedErrorBorder'],
          focusedBorder: _inputDecoration['focusedBorder'],
          border: _inputDecoration['border'],
          contentPadding: _inputDecoration['contentPadding'],
          labelText: "密码",
          hintText: "请输入密码",
          labelStyle: inputLabelStyle(),
          focusColor: themeAccentColor,
          //下划线包裹icon
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
              icon: Icon(
                pwdVisible ? Icons.visibility : Icons.visibility_off,
                color: hintColor,
                size: width(18),
              ),
              onPressed: () {
                _registerModel.changePwdVisible(!pwdVisible);
              }),
          hintStyle: textStyle(
              color: hintColor, fontWeight: FontWeight.w400, fontSize: sp(14)),
        ),
        validator: (v) => v.trim().length <= 0 ? "密码不能为空" : null,
        onFieldSubmitted: (v) {
          _pwdNode.unfocus();
        },
      ),
      selector: (context, loginModel) => loginModel.pwdVisible,
    );
  }

  ///
  /// 验证码输入框
  Widget _buildCodeInput() {
    return ChangeNotifierProvider(
      create: (context) => _codeModel,
      child: TextFormField(
        key: _codeKey,
        autovalidate: false,
        autofocus: false,
        focusNode: _codeNode,
        controller: _codeEtController,
        style: textStyle(
          color: textColor,
          fontWeight: bold,
          fontSize: sp(18),
        ),
        showCursor: true,
        cursorWidth: width(1),
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.next,
        cursorColor: themeAccentColor,
        textCapitalization: TextCapitalization.words,
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: false),
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6)
        ],
        toolbarOptions: ToolbarOptions(),
        decoration: InputDecoration(
          focusedErrorBorder: _inputDecoration['focusedErrorBorder'],
          focusedBorder: _inputDecoration['focusedBorder'],
          border: _inputDecoration['border'],
          contentPadding: _inputDecoration['contentPadding'],
          labelText: "验证码",
          hintText: "请输入手机验证码",
          labelStyle: inputLabelStyle(),
          focusColor: themeAccentColor,
//                    icon: Icon(Icons.phone_iphone),
          //下划线包裹icon
          prefixIcon: Icon(Icons.mail),
          suffixIcon: _codeCounter(),
          hintStyle: textStyle(
              color: hintColor, fontWeight: FontWeight.w400, fontSize: sp(14)),
        ),
        validator: (v) => v.trim().length <= 0 ? "验证码不能为空" : null,
        onFieldSubmitted: (v) {
          _codeNode.unfocus();
          FocusScope.of(context).requestFocus(_pwdNode);
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
        tag: "avatar",
        child: Image(
          image: AssetImage("assets/images/icon-app.png"),
          width: width(88),
          height: width(88),
        ));
  }

  ///
  /// 头像
  ///
  Widget _buildAvatar() {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: <Widget>[
        GestureDetector(
          onTap: () async {
            var result = await selectPicture(
                crop: true,
                mWidth: ScreenUtil.screenWidthDp,
                mHeight: ScreenUtil.screenWidthDp);
            logger.log("result = ${result?.path}");
            if (StringUtils.isNotEmpty(result?.path)) {
              _registerModel?.avatar = result;
            }
          },
          child: Selector<RegisterModel, File>(
              builder: (context, imageFile, child) {
                return Hero(
                  tag: "avatar",
                  child: Avatar(
                    width: width(80),
                    height: width(80),
                    bgHeight: width(88),
                    bgWidth: width(88),
                    bgColor: white,
                    showShadow: true,
                    image: imageFile == null
                        ? AssetImage("assets/images/icon-default.png")
                        : FileImage(imageFile),
                    hover: Positioned(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: white),
                        child: Text(
                          "编辑",
                          style: textStyle(
                              color: buttonDisableColor,
                              fontSize: sp(10),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      left: 0,
                      right: 0,
                      bottom: height(2),
                    ),
                  ),
                );
              },
              selector: (context, loginModel) => loginModel.avatar),
        ),
      ],
    );
  }

  ///
  /// 验证码倒计时按钮
  ///
  Widget _codeCounter() {
    ThemeData themeData = Theme.of(context);
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.only(right: width(10)),
      constraints: BoxConstraints(maxWidth: width(100), maxHeight: height(25)),
      child: Theme(
        data: themeData.copyWith(
            buttonTheme: themeData.buttonTheme.copyWith(height: height(25))),
        child: Selector<CodeModel, int>(
          builder: (context, count, child) {
            return RaisedButton(
              disabledElevation: 0,
              disabledColor: buttonDisableColor,
              color: themeAccentColor,
              elevation: 0,
              highlightElevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(height(25))),
              padding: EdgeInsets.symmetric(
                  horizontal: width(10), vertical: height(0)),
              onPressed: count >= 0
                  ? null
                  : () async {
                      if ((_phoneKey.currentState as FormFieldState)
                          .validate()) {
                        var result = await simpleFuture(_codeModel.sendMsg(
                            {"phone": _phoneEtController.text, "type": "1"}));
                        if (result == null) {
                          _codeModel.countDown(120);
                        }
                      }
                    },
              child: Text(
                count >= 0 ? "${count}s" : "发送验证码",
                style: textStyle(fontSize: sp(13), color: white),
              ),
            );
          },
          selector: (context, model) => _codeModel.time,
        ),
      ),
    );
  }

  Future selectAvatar() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Nav.pageTo(context, Routers.crop,
              param: {"image": image.path}, transition: TransitionType.fadeIn)
          .then((value) {
        if (value != null) {
          _registerModel?.avatar = value['image'];
        }
      });
    }
  }
}
