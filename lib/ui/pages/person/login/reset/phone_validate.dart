import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazycook/core/viewmodels/person/login/phone_validate.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/button.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/utils/utils.dart';
import 'package:provider/provider.dart';

///
/// 手机号输入
///
class PhoneValidatePage extends StatefulWidget {
  @override
  PhoneValidatePageState createState() => new PhoneValidatePageState();
}

class PhoneValidatePageState extends CustomState<PhoneValidatePage> {
  TextEditingController _phoneEtController;
  ThemeData _themeData;

  ///输入框参数
  FocusNode _phoneNode = FocusNode();
  GlobalKey _formKey = GlobalKey<FormState>();
  GlobalKey _phoneKey = GlobalKey<FormFieldState>();

  Map _inputDecoration;

  PwdResetModel _model;

  @override
  void initState() {
    super.initState();
    _phoneEtController = TextEditingController();
    _model = PwdResetModel(api());
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
    return ChangeNotifierProvider(
      create: (context) {
        return _model;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: white,
          iconTheme: IconThemeData(color: Colors.black),
          brightness: Brightness.light,
          title: Text(
            '输入手机号',
            style: textStyle(
              color: Colors.black,
              fontSize: sp(18),
              fontWeight: bold,
            ),
          ),
        ),
        body: Container(
          color: white,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: <Widget>[
                    _buildForm(),
                    _loginButton(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return Button(
      margin: EdgeInsets.fromLTRB(width(30), height(22), width(30), height(0)),
      accentColor: themeAccentColor,
      text: "下一步",
      onPressed: () async {
        if ((_formKey.currentState as FormState).validate()) {
          FocusScope.of(context).requestFocus(FocusNode());
          showCustomDialog(
              context: context,
              dialogType: DialogType.GENERAL,
              msg: "将发送验证码到手机${_phoneEtController.text}上，是否现在发送？",
              cancelText: "否",
              confirmText: "是",
              onCancel: () {
                hideDialog();
              },
              onConfirm: () async {
                hideDialog();
                var result = await simpleFuture(
                    _model.authCode(_phoneEtController.text),
                    loadingMsg: "发送中...");
                if (result == null) {
                  Nav.pageTo(context, Routers.forget_code,
                      param: {"phone": _phoneEtController.text});
                }
              });
        }
      },
    );
  }

  Widget _buildForm() {
    return Container(
        margin: EdgeInsets.only(
            left: width(30), right: width(30), top: height(48), bottom: 0),
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
        return v.trim().length <= 0
            ? "手机号不能为空"
            : Utils.validatePhone(v.trim()) ? null : "手机号格式有误";
      },
      onFieldSubmitted: (v) {
        _phoneNode?.unfocus();
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }
}
