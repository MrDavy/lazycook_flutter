import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/viewmodels/person/consumer_service.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/button.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/provider_selector_widget.dart';
import 'package:provider/provider.dart';

///
/// 客服
///
class FeedbackPage extends StatefulWidget {
  FeedbackPage({Key key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends CustomState<FeedbackPage> {
  TextEditingController _titleController;
  TextEditingController _contentController;
  GlobalKey _formKey = GlobalKey();
  FocusNode _titleNode = FocusNode();
  FocusNode _contentNode = FocusNode();

  ConsumerService _model;

  @override
  void initState() {
    super.initState();
    _model = ConsumerService(Provider.of(context, listen: false));
    _titleController = TextEditingController()
      ..addListener(() {
        _model.updateTitle(_titleController.text);
      });
    _contentController = TextEditingController()
      ..addListener(() {
        _model.updateContent(_contentController.text);
      });
  }

  @override
  bool darkStatusBar() {
    return true;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: ChangeNotifierProvider<ConsumerService>(
        create: (context) => _model,
        child: MainWidget(
          statusBarColor: white,
          headerDecoration: BoxDecoration(color: white),
          leadingColor: Colors.black,
          titleColor: Colors.black,
          decoration: BoxDecoration(color: white),
          title: "意见反馈",
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: width(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: height(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: height(4)),
                                child: Text(
                                  "标题",
                                  style: textStyle(
                                      color: color_666,
                                      fontSize: sp(16),
                                      fontWeight: bold),
                                ),
                              ),
                              _buildTextFiled(
                                "输入标题",
                                textColor,
                                sp(14),
                                _titleController,
                                20,
                                lines: 1,
                                autoFocus: true,
                                node: _titleNode,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  _titleNode?.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_contentNode);
                                },
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: height(4)),
                                child: Text(
                                  "内容",
                                  style: textStyle(
                                      color: color_666,
                                      fontSize: sp(16),
                                      fontWeight: bold),
                                ),
                              ),
                              _buildTextFiled(
                                "输入您的意见或建议，我们将尽快回复您！",
                                textColor,
                                sp(14),
                                _contentController,
                                160,
                                lines: 6,
                                textInputAction: TextInputAction.done,
                                node: _contentNode,
                                onFieldSubmitted: (value) {},
                              )
                            ],
                          ),
                        ),
                        Selector<ConsumerService, bool>(
                            builder: (context, canBeSubmit, _) {
                              return Button(
                                width: double.infinity,
                                margin: EdgeInsets.fromLTRB(
                                    width(0), height(22), width(0), height(50)),
                                accentColor: secondColor,
                                text: "提交",
                                enable: canBeSubmit,
                                onPressed: () async {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  var result = await simpleFuture(
                                      _model.submit(),
                                      loadingMsg: "正在提交...");
                                  if (result == null) {
                                    showToast("提交成功");
                                    Nav.back();
                                  } else if (result is LazyError) {
                                    showToast(result.message);
                                  }
                                },
                              );
                            },
                            selector: (context, model) => model.canBeSubmit)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFiled(
    hint,
    textColor,
    textSize,
    TextEditingController controller,
    length, {
    int lines = 1,
    EdgeInsetsGeometry padding,
    bool enable = true,
    validator,
    onFieldSubmitted,
    textInputAction,
    autoFocus,
    node,
  }) {
    return Padding(
      padding: padding ??
          EdgeInsets.only(
              top: height(0),
              bottom: height(0),
              left: width(0),
              right: width(0)),
      child: TextFormField(
        autovalidate: false,
        focusNode: node,
        autofocus: autoFocus ?? false,
        enabled: enable,
        controller: controller,
        textInputAction: textInputAction ?? TextInputAction.done,
        style: textStyle(
          color: textColor,
          fontWeight: FontWeight.w400,
          fontSize: textSize,
        ),
        showCursor: true,
        maxLines: lines,
        maxLength: length,
        toolbarOptions: ToolbarOptions(),
        decoration: InputDecoration(
          filled: true,
          fillColor: skeletonGray,
          focusedErrorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          border: InputBorder.none,
          hintText: hint,
          focusColor: accentColor,
          hintStyle: textStyle(
              color: hintColor,
              fontWeight: FontWeight.w400,
              fontSize: textSize),
        ),
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }
}
