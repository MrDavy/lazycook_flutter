import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/person/code_model.dart';
import 'package:lazycook/core/viewmodels/person/login/login.dart';
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
/// 登录
///
class LoginPage extends StatefulWidget {
  final String scence;

  const LoginPage({Key key, this.scence}) : super(key: key);

  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends CustomState<LoginPage> {
  TextEditingController _phoneEtController;
  TextEditingController _pwdEtController;
  TextEditingController _codeEtController;
  ThemeData _themeData;

  ///输入框参数
  FocusNode _pwdNode = FocusNode();
  FocusNode _codeNode = FocusNode();
  FocusNode _phoneNode = FocusNode();
  GlobalKey _formKey = GlobalKey<FormState>();
  GlobalKey _phoneKey = GlobalKey<FormFieldState>();
  GlobalKey _pwdKey = GlobalKey<FormFieldState>();
  GlobalKey _codeKey = GlobalKey<FormFieldState>();

  LoginModel _loginModel;
  CodeModel _codeModel;

  Map _inputDecoration;

  @override
  void initState() {
    super.initState();
    _phoneEtController = TextEditingController();
    _pwdEtController = TextEditingController();
    _codeEtController = TextEditingController();
    var repository = Provider.of<API>(context, listen: false);
    _loginModel = LoginModel(api: repository);
    _codeModel = CodeModel(repository);
  }

  @override
  bool darkStatusBar() {
    return true;
  }

  @override
  Widget buildWidget(BuildContext context) {
    _themeData = Theme.of(context);
    _inputDecoration =
        createDecoration(Color(0xffff9900), themeAccentColor, _themeData.errorColor);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return _loginModel;
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: white,
          iconTheme: IconThemeData(color: Colors.black),
          brightness: Brightness.light,
          title: Selector<LoginModel, bool>(
              builder: (context, loginWithPwd, _) {
                return Text(
                  loginWithPwd ? '密码登陆' : "短信登录",
                  style: textStyle(
                    color: Colors.black,
                    fontSize: sp(18),
                    fontWeight: bold,
                  ),
                );
              },
              selector: (context, model) => model.loginWithPwd),
        ),
        body: Container(
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
                child: ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: <Widget>[
                    ///头像
                    SizedBox(
                      height: height(40),
                    ),
                    _buildLogo(),

                    ///表单
                    _buildForm(),

                    ///这里将LoginButton放到ListView中是因为button不需要完全显示，可以被遮挡，如果放外边就会被键盘顶起
                    _loginButton(),

                    ///登录方式、注册
                    _loginTypeChangeWidget(),

                    ///第三方登录
//                    _thirdPartyLogin(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool _clearFocus() {
    _codeNode?.consumeKeyboardToken();
    _pwdNode?.consumeKeyboardToken();
    _phoneNode?.consumeKeyboardToken();
  }

  Widget _loginButton() {
    return Button(
      margin: EdgeInsets.fromLTRB(width(30), height(22), width(30), height(0)),
      accentColor: themeAccentColor,
      text: "立即登陆",
      onPressed: () async {
        bool isPwd = _loginModel.loginWithPwd;
        if ((_formKey.currentState as FormState).validate()) {
          FocusScope.of(context).requestFocus(FocusNode());
          var result = await simpleFuture(
              _loginModel.login({
                'phone': _phoneEtController.text,
                'type': isPwd ? "2" : "1",
                'code': isPwd ? _loginModel.charCode : '',
                'authCode': isPwd ? '' : _codeEtController.text,
                'password': isPwd
                    ? await EncryptUtils.encryptMD5(_pwdEtController.text)
                    : ''
              }),
              loadingMsg: "登录中...");
          if (result == null) {
            Nav.back<bool>(param: true);
          } else if (result is LazyError) {
            logger.log("extra = ${result.extra}");
            _loginModel.charCode = result.extra;
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
                  _buildAuthInput()
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildAuthInput() {
    return Selector<LoginModel, bool>(
      builder: (context, loginWithPwd, child) {
        return Column(
          children: <Widget>[
            loginWithPwd ? _buildPwdInput() : _buildCodeInput(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(top: height(6)),
                    child: Text(
                      loginWithPwd ? "忘记密码" : "",
                      style: textStyle(
                          color: hintColor,
                          fontSize: sp(14),
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  onTap: loginWithPwd
                      ? () {
                          Nav.pageTo(context, Routers.forget, param: {
                            "phone": _phoneEtController.text?.trim()
                          });
                        }
                      : null,
                ),
                SizedBox(
                  width: width(4),
                )
              ],
            ),
          ],
        );
      },
      selector: (context, model) {
        return model.loginWithPwd;
      },
    );
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
        fontWeight: FontWeight.w600,
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
      cursorColor: themeAccentColor,
      toolbarOptions: ToolbarOptions(),
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
        return v.trim().length <= 0
            ? "手机号不能为空"
            : Utils.validatePhone(v.trim()) ? null : "手机号格式有误";
      },
      onFieldSubmitted: (v) {
        _phoneNode?.unfocus();
        FocusScope.of(context)
            .requestFocus(_loginModel.loginWithPwd ? _pwdNode : _codeNode);
      },
    );
  }

  ///
  /// 密码输入框
  /// 使用Selector来局部刷新
  Widget _buildPwdInput() {
//    logger.log("_buildPwdInput");
    return Selector<LoginModel, bool>(
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
                _loginModel.changePwdVisible(!pwdVisible);
              }),
          hintStyle: textStyle(
              color: hintColor, fontWeight: FontWeight.w400, fontSize: sp(14)),
        ),
        validator: (v) => v.trim().length <= 0 ? "密码不能为空" : null,
        onFieldSubmitted: (v) {
          _phoneNode?.unfocus();
          _pwdNode?.unfocus();
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
        textInputAction: TextInputAction.done,
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
          _phoneNode?.unfocus();
          _pwdNode?.unfocus();
          _codeNode?.unfocus();
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: widget.scence == Routers.collection ||
              widget.scence == Routers.works ||
              widget.scence == 'person'
          ? "avatar"
          : "",
      child: ClipOval(
        child: SvgPicture.asset(
          "assets/svg/logo.svg",
          color: themeAccentColor,
          width: width(88),
          height: width(88),
        ),
      ),
    );
  }

  ///
  /// 登录方式切换
  ///
  Widget _loginTypeChangeWidget() {
    return Container(
      margin: EdgeInsets.only(top: height(22)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Container(
              padding: EdgeInsets.only(top: height(8)),
              child: Selector<LoginModel, bool>(
                  builder: (context, withPwd, child) => Text(
                        withPwd ? "短信登录" : "密码登录",
                        style: textStyle(
                          color: themeAccentColor,
                          fontSize: sp(14),
                          fontWeight: bold,
                        ),
                      ),
                  selector: (context, model) => model.loginWithPwd),
            ),
            onTap: () {
              _loginModel?.loginWithPwd = !_loginModel.loginWithPwd;
            },
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
                bottom: height(2),
                top: height(8),
                left: width(10),
                right: width(10)),
            child: Text(
              "|",
              style: textStyle(
                  color: themeAccentColor,
                  fontSize: sp(14),
                  fontWeight: FontWeight.w900),
            ),
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: height(8)),
              child: Text(
                "注册账号",
                style: textStyle(
                  color: themeAccentColor,
                  fontSize: sp(14),
                  fontWeight: bold,
                ),
              ),
            ),
            onTap: () {
              Nav.pageTo(context, Routers.register);
            },
          )
        ],
      ),
    );
  }

  ///
  /// 第三方登录
  ///
  Widget _thirdPartyLogin() {
    return Container(
        margin: EdgeInsets.fromLTRB(width(50), height(30), width(50), 0),
        alignment: Alignment.bottomCenter,
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: width(50),
                  height: height(1),
                  color: buttonDisableColor,
                ),
                Text(
                  "  or  ",
                  style: textStyle(color: hintColor, fontSize: sp(14)),
                ),
                Container(
                  width: width(50),
                  height: height(1),
                  color: buttonDisableColor,
                ),
              ],
            ),
            SizedBox(
              height: height(30),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Image.asset(
                    "assets/images/icon-login-wechat.png",
                    width: width(40),
                    height: width(40),
                  ),
                  onTap: () {},
                ),
                SizedBox(
                  width: width(50),
                ),
                GestureDetector(
                  child: Image.asset(
                    "assets/images/icon-login-qq.png",
                    width: width(40),
                    height: width(40),
                  ),
                  onTap: () {},
                ),
                SizedBox(
                  width: width(50),
                ),
                GestureDetector(
                  child: Image.asset(
                    "assets/images/icon-login-weibo.png",
                    width: width(40),
                    height: width(40),
                  ),
                  onTap: () {},
                )
              ],
            ),
          ],
        ));
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
                            {"phone": _phoneEtController.text, "type": "2"}));
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

  cancelCounter() {
    _codeModel?.cancel();
  }
}
