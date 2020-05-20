import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/base_state.dart';
import 'package:lazycook/ui/widgets/code_widget/code_widget_model.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/ui/widgets/typedef.dart';
import 'package:provider/provider.dart';

class CodeWidget extends StatefulWidget {
  final int count;
  final CodeController controller;

  const CodeWidget({Key key, this.count = 6, this.controller})
      : super(key: key);

  @override
  CodeWidgetState createState() => new CodeWidgetState();
}

class CodeWidgetState extends BaseState<CodeWidget> {
  CodeWidgetModel _model;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _model = CodeWidgetModel(widget.count);
    _controller = TextEditingController()
      ..addListener(() {
        var text = _controller.text;
        _model.updateText(text);
        widget.controller?.update(text);
      });
  }

  Widget _buildCodeView() {
    return Consumer<CodeWidgetModel>(builder: (context, model, _) {
      var nums = model.nums;
      List<Widget> list = [];
      for (int index = 0; index < widget.count; index++) {
        Num num = nums[index];
        list.add(Expanded(
            child: Container(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(bottom: height(2)),
            child: num.type == NumType.LINE
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: height(20),
                        width: width(1),
                        color: accentColor,
                      ),
                      Text(
                        "",
                        style: textStyle(color: textColor, fontSize: sp(28)),
                      )
                    ],
                  )
                : Text(
                    num.type == NumType.NUM ? num.num : "",
                    style: textStyle(color: textColor, fontSize: sp(28)),
                  ),
          ),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: buttonDisableColor))),
        )));
        if (index < widget.count - 1) {
          list.add(SizedBox(
            width: width(10),
          ));
        }
      }
      return Row(
        children: list,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChangeNotifierProvider(
        create: (context) => _model,
        child: Stack(
          children: <Widget>[
            _buildCodeView(),
            TextField(
              showCursor: false,
              autofocus: true,
              toolbarOptions: ToolbarOptions(),
              controller: _controller,
              style: textStyle(color: Colors.transparent),
              textInputAction: TextInputAction.next,
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: false),
              inputFormatters: [
                WhitelistingTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.count)
              ],
              decoration: InputDecoration(
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CodeController {
  ValueCallback<String> _call;
  String value;

  update(text) {
    if (text != value) {
      value = text;
      if (_call != null) {
        _call(value);
      }
    }
  }

  addListener(ValueCallback<String> call) {
    _call = call;
  }
}
