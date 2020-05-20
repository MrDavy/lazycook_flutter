import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lazycook/application.dart';
import 'package:lazycook/core/viewmodels/person/login/pwd_input.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/button.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/utils/encrypt/encrypt.dart';
import 'package:provider/provider.dart';

class PwdInputWidget extends StatefulWidget {
  final String token;
  final String phone;
  final String code;

  const PwdInputWidget({Key key, this.token, this.phone, this.code})
      : super(key: key);

  @override
  _PwdInputWidgetState createState() => _PwdInputWidgetState();
}

class _PwdInputWidgetState extends CustomState<PwdInputWidget> {
  PwdInputModel _model;

  TextEditingController _pwdEtController;
  ThemeData _themeData;

  ///输入框参数
  FocusNode _pwdNode = FocusNode();
  GlobalKey _formKey = GlobalKey<FormState>();
  GlobalKey _pwdKey = GlobalKey<FormFieldState>();

  Map _inputDecoration;

  @override
  void initState() {
    super.initState();
    _model = PwdInputModel(api());
    _pwdEtController = TextEditingController();
  }

  @override
  Widget buildWidget(BuildContext context) {
    _themeData = Theme.of(context);
    _inputDecoration =
        createDecoration(borderColor, accentColor, _themeData.errorColor);
    return WillPopScope(
        child: ChangeNotifierProvider<PwdInputModel>(
          create: (context) => _model,
          child: Scaffold(
            appBar: new AppBar(
              leading: null,
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: white,
              brightness: Brightness.light,
            ),
            body: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: width(30)),
              color: white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      children: <Widget>[
                        Text(
                          "请设置密码",
                          style: textStyle(
                              color: textColor,
                              fontSize: sp(24),
                              fontWeight: bold),
                        ),
                        _buildForm(),
                        _loginButton(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        onWillPop: () => Future.value(true));
  }

  Widget _buildForm() {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(
            left: width(0), right: width(0), top: height(48), bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              autovalidate: false,
              child: Column(
                children: <Widget>[
                  _buildPwdInput(),
                  SizedBox(height: height(20)),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _loginButton() {
    return Button(
      text: "提交",
      margin: EdgeInsets.fromLTRB(width(0), height(22), width(0), height(0)),
      accentColor: accentColor,
      onPressed: () async {
        if ((_formKey.currentState as FormState).validate()) {
          FocusScope.of(context).requestFocus(FocusNode());
          var pwd = await EncryptUtils.encryptMD5(_pwdEtController.text);
          logger.log("pwd = $pwd");
          var result = await simpleFuture(_model.submit({
            "phone": widget.phone,
            "password": pwd,
            "confirmPassword": pwd,
            "authCode": widget.code
          }));
          if (result == null) {
            Nav.back();
          }
        }
      },
    );
  }

  ///
  /// 密码输入框
  /// 使用Selector来局部刷新
  Widget _buildPwdInput() {
    return Selector<PwdInputModel, bool>(
      builder: (context, pwdVisible, child) {
        return TextFormField(
          key: _pwdKey,
          autofocus: true,
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
          cursorColor: accentColor,
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
            focusColor: accentColor,
            //下划线包裹icon
            prefixIcon: Icon(Icons.lock),
            suffixIcon: IconButton(
                icon: Icon(
                  pwdVisible ? Icons.visibility : Icons.visibility_off,
                  color: hintColor,
                  size: width(18),
                ),
                onPressed: () {
                  _model.changePwdVisible(!pwdVisible);
                }),
            hintStyle: textStyle(
                color: hintColor,
                fontWeight: FontWeight.w400,
                fontSize: sp(14)),
          ),
          validator: (v) => v.trim().length <= 0
              ? "密码不能为空"
              : v.trim().length < 6 ? "密码长度至少6位" : null,
          onFieldSubmitted: (v) {},
        );
      },
      selector: (context, model) => model.pwdVisible,
    );
  }
}
