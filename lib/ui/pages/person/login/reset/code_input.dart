import 'package:flutter/material.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/viewmodels/person/login/code_input.dart';
import 'package:lazycook/core/viewmodels/person/login/phone_validate.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/button.dart';
import 'package:lazycook/ui/widgets/code_widget/code_widget.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:provider/provider.dart';

class CodeInput extends StatefulWidget {
  final String phone;

  const CodeInput({Key key, this.phone}) : super(key: key);

  @override
  CodeInputState createState() => new CodeInputState();
}

class CodeInputState extends CustomState<CodeInput> {
  static const MAX_COUNT = 6;

  CodeInputModel _model;

  CodeController _codeController;

  @override
  void initState() {
    super.initState();
    _model = CodeInputModel(api());
    _codeController = CodeController()
      ..addListener((value) {
        _submit();
      });
  }

  _submit() async {
    var value = _codeController.value;
    if (StringUtils.isNotEmpty(value) && value.length == MAX_COUNT) {
      var result = await simpleFuture(_model.validateCode(widget.phone, value));
      if (result != null) {
        _model.setReSubmit(true);
      } else {
        Nav.navigateTo(Routers.forget_pwd_input,
            param: {'phone': widget.phone, 'type': '4', 'code': value},
            replace: true,
            clearStack: true,
            predicate: ModalRoute.withName(Routers.root));
      }
    } else {
//      showToast("请输入验证码");
    }
  }

  @override
  bool darkStatusBar() => true;

  @override
  Widget buildWidget(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        brightness: Brightness.light,
        elevation: 0,
        backgroundColor: white,
      ),
      body: ChangeNotifierProvider<CodeInputModel>(
        create: (context) => _model,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: width(30)),
          color: white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "验证码已发送至手机：",
                style: textStyle(
                    color: textColor,
                    fontSize: sp(24),
                    fontWeight: bold),
              ),
              Text(
                "+86 ${widget.phone}",
                style: textStyle(
                    color: accentColor,
                    fontSize: sp(26),
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: height(36),
              ),
              Text(
                "请输入验证码",
                style: textStyle(
                    color: textColor.withOpacity(.6), fontSize: sp(12)),
              ),
              Container(
                margin: EdgeInsets.only(top: height(30)),
                child: CodeWidget(
                  count: MAX_COUNT,
                  controller: _codeController,
                ),
              ),
              _submitButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Consumer<CodeInputModel>(
      builder: (context, model, _) {
        return Container(
          margin: EdgeInsets.only(top: height(48)),
          child: model.reSubmit
              ? Button(
                  accentColor: accentColor,
                  text: "重新提交",
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    var value = _codeController.value;
                    if (StringUtils.isNotEmpty(value) &&
                        value.length == MAX_COUNT) {
                      _submit();
                    } else {
                      showToast("请输入验证码");
                    }
                  },
                )
              : Container(),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
