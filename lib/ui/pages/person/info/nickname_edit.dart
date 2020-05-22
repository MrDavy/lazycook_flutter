import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazycook/core/viewmodels/person/login/user_model.dart';
import 'package:lazycook/core/viewmodels/person/person.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/button.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:provider/provider.dart';

///
/// 编辑昵称
///
class NickNameEditPage extends StatefulWidget {
  NickNameEditPage({Key key}) : super(key: key);

  @override
  _NickNameEditPageState createState() => _NickNameEditPageState();
}

class _NickNameEditPageState extends CustomState<NickNameEditPage> {
  PersonModel _personModel;
  TextEditingController _nameEtController;
  ThemeData _themeData;

  ///输入框参数
  FocusNode _nameNode = FocusNode();
  GlobalKey _formKey = GlobalKey<FormState>();
  GlobalKey _nameKey = GlobalKey<FormFieldState>();

  Map _inputDecoration;

  @override
  void initState() {
    super.initState();
    _nameEtController = TextEditingController(
        text: Provider.of<UserModel>(context, listen: false).user.nikename);
    _personModel = PersonModel(api());
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        iconTheme: IconThemeData(color: Colors.black),
        brightness: Brightness.light,
        title: Text(
          "设置昵称",
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
    );
  }

  Widget _loginButton() {
    return Button(
      margin: EdgeInsets.fromLTRB(width(30), height(22), width(30), height(0)),
      accentColor: themeAccentColor,
      text: "完成",
      onPressed: () async {
        if ((_formKey.currentState as FormState).validate()) {
          FocusScope.of(context).requestFocus(FocusNode());
          var result = await simpleFuture(_personModel
              ?.updateNickName({"nickname": _nameEtController.text}));
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
      key: _nameKey,
      autofocus: true,
      focusNode: _nameNode,
      controller: _nameEtController,
      style: textStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: sp(18),
      ),
      showCursor: true,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      inputFormatters: [LengthLimitingTextInputFormatter(8)],
      toolbarOptions: ToolbarOptions(),
      cursorWidth: width(1),
      cursorColor: themeAccentColor,
      decoration: InputDecoration(
        focusedErrorBorder: _inputDecoration['focusedErrorBorder'],
        focusedBorder: _inputDecoration['focusedBorder'],
        border: _inputDecoration['border'],
        contentPadding: _inputDecoration['contentPadding'],
        labelText: "昵称",
        hintText: "输入昵称",
        labelStyle: inputLabelStyle(),
        focusColor: themeAccentColor,
        prefixIcon: Icon(Icons.border_color,size: width(20),),
        hintStyle: textStyle(
            color: hintColor, fontWeight: FontWeight.w400, fontSize: sp(14)),
      ),
      validator: (v) {
        return v.trim().length <= 0 ? "昵称不能为空" : null;
      },
      onFieldSubmitted: (v) {
        _nameNode?.unfocus();
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }
}

//ChangeNotifierProvider(
//create: (context) => _personModel,
//child: Container(
//color: backgroundGray,
//child: Consumer<UserModel>(builder: (context, model, child) {
//return Text(model.user.nikename);
//}),
//),
//)
