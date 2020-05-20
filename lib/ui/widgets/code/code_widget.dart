import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/code/code_model.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:provider/provider.dart';

///
/// 验证码控件
class CodeField extends StatefulWidget {
  final TextEditingController controller;

  ///关联
  final TextEditingController relatedWidgetController;
  final Key codeKey;
  final Key relatedWidgetKey;
  final FocusNode relatedWidgetNode;
  final FocusNode codeNode;
  final ValueChanged<String> onFieldSubmitted;
  final FormFieldValidator<String> validator;
  final void Function(int time) onChange;
  final void Function() onSendEnd;
  final void Function() onSendStart;

  ///1:登录，2:注册，3:忘记密码
  final int codeType;

  const CodeField({
    Key key,
    @required this.codeType,
    @required this.controller,
    this.codeKey,
    this.codeNode,
    this.onFieldSubmitted,
    this.validator,
    this.onChange,
    this.onSendEnd,
    this.onSendStart,
    this.relatedWidgetController,
    this.relatedWidgetKey,
    this.relatedWidgetNode,
  }) : super(key: key);

  @override
  CodeFieldState createState() => new CodeFieldState();
}

class CodeFieldState extends CustomState<CodeField> {
  CodeModel _codeModel;

  @override
  void initState() {
    _codeModel = CodeModel();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
      child: TextFormField(
        key: widget.codeKey,
        autovalidate: false,
        autofocus: false,
        focusNode: widget.codeNode,
        controller: widget.controller,
        style: textStyle(
          color: textColor,
          fontWeight: bold,
          fontSize: sp(18),
        ),
        showCursor: false,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.done,
        cursorColor: accentColor,
        textCapitalization: TextCapitalization.words,
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: false),
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6)
        ],
        toolbarOptions: ToolbarOptions(),
        decoration: InputDecoration(
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(width(4))),
          contentPadding: EdgeInsets.only(
              top: height(4), bottom: height(4), right: width(16)),
          labelText: "验证码",
          hintText: "请输入手机验证码",
          labelStyle: textStyle(fontWeight: bold),
          focusColor: accentColor,
//                    icon: Icon(Icons.phone_iphone),
          //下划线包裹icon
          prefixIcon: Icon(Icons.mail),
          suffixIcon: _counter(),
          hintStyle: textStyle(
              color: hintColor, fontWeight: FontWeight.w400, fontSize: sp(14)),
        ),
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
      ),
    );
  }

  Widget _counter() {
    ThemeData themeData = Theme.of(context);
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.only(right: width(10)),
      constraints: BoxConstraints(maxWidth: width(100), maxHeight: height(25)),
      child: Theme(
        data: themeData.copyWith(
            buttonTheme: themeData.buttonTheme.copyWith(height: height(25))),
        child: ChangeNotifierProvider(
          create: (context) => _codeModel,
          child: Selector<CodeModel, int>(
            builder: (context, count, child) {
              return RaisedButton(
                disabledElevation: 0,
                disabledColor: buttonDisableColor,
                color: accentColor,
                elevation: 0,
                highlightElevation: 0,
                padding: EdgeInsets.symmetric(
                    horizontal: width(10), vertical: height(0)),
                onPressed: count >= 0
                    ? null
                    : () {
                        String phone = widget.controller.text;
                        if (StringUtils.isEmpty(phone)) {
                          showToast("请输入手机号");
                        } else {
                          _codeModel.sendMsg({"phone": phone});
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
      ),
    );
  }
}
