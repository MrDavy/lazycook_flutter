import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/viewmodels/person/works_new_model.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/dialog/custom_dialog.dart';
import 'package:lazycook/ui/widgets/icon_text.dart';
import 'package:lazycook/ui/widgets/main_widget.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/utils/fluro/src/common.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:lazycook/utils/utils.dart';
import 'package:provider/provider.dart';

class NewWork extends StatefulWidget {
  final int workId;

  const NewWork({Key key, this.workId}) : super(key: key);

  @override
  NewWorkState createState() => new NewWorkState();
}

class NewWorkState extends CustomState<NewWork> {
  NewWorksModel _newWorksModel;
  GlobalKey _formKey = GlobalKey<FormState>();
  var albumHeight = 0.0;
  var stepImageWidth;
  var stepImageHeight;

  @override
  void initState() {
    super.initState();
    _newWorksModel = NewWorksModel(Provider.of(context, listen: false));
    if (widget.workId == null) {
      _newWorksModel.createEmptyData();
    }
    albumHeight = ScreenUtil.screenWidthDp * .7;
    stepImageWidth = ScreenUtil.screenWidthDp - width(120) - 10;
    stepImageHeight = stepImageWidth * .7;
  }

  submit(type) async {
    if ((_formKey.currentState as FormState).validate()) {
      FocusScope.of(context).requestFocus(FocusNode());
      var result = await _newWorksModel.checkParams();
      logger.log("result type = ${result.runtimeType.toString()}");
      if (result is String) {
        logger.log("result = $result");
      } else if (result is Map) {
        showLoading("正在提交...");
        _newWorksModel.submit(result).then((resultData) {
          hideLoading();
          logger.log("resultData = $resultData");
          if (resultData.error != null) {
            showToast(resultData.error.message);
          } else {
            FocusScope.of(context).requestFocus(FocusNode());
            Nav.back();
          }
        }).catchError((error) {
          hideLoading();
          logger.log("error = $error");
          showToast("${error}");
        });
      }
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          InkWell(
            onTap: () async {
              int type = await showConfirmDialog();
              if (type != null) {
                submit(type);
              }
            },
            child: Padding(
              padding: EdgeInsets.only(right: width(16)),
              child: Image.asset(
                "assets/images/menu.png",
                width: width(24),
                height: height(16),
              ),
            ),
          )
        ],
        leading: Container(
          height: height(48),
          width: width(48),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              size: width(24),
              color: white,
            ),
          ),
        ),
        elevation: 0,
        title: Text(
          "新建作品",
          style: textStyle(
            color: Colors.white,
            fontSize: sp(18),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: MainWidget(
        noHeader: true,
        decoration: BoxDecoration(color: white),
        child: ChangeNotifierProvider(
          create: (context) => _newWorksModel,
          child: ProviderWidget(
            model: _newWorksModel,
            onModelReady: (model) {},
            builder: (context, model, child) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          return true;
                        },
                        child: Form(
                            key: _formKey,
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              children: <Widget>[
                                _buildAlbumView(),
                                _buildTitleView("菜名：", null),
                                _buildNameView(),
                                _buildTitleView("食材：", 1),
                                _buildIngredientsView(),
                                _buildTitleView("调料：", 2),
                                _buildBurdensView(),
                                _buildTitleView("步骤：", 3),
                                _buildStepsView(),
                                _buildTitleView("心得：", null),
                                _buildStudyView(),
                                SizedBox(height: height(100))
                              ],
                            )),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsView() {
    return Selector<NewWorksModel, List<RecipeMaterial>>(
        builder: (context, ingredients, _) {
      return Container(
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: ingredients?.length ?? 1,
          shrinkWrap: true,
          separatorBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: width(16)),
              height: 1,
              color: skeletonGray,
            );
          },
          itemBuilder: (context, index) {
            if (ingredients[index].nameController == null)
              ingredients[index].nameController =
                  TextEditingController(text: ingredients[index].name);
            if (ingredients[index].amountController == null)
              ingredients[index].amountController =
                  TextEditingController(text: ingredients[index].amount);
            return Container(
              width: double.infinity,
              padding: EdgeInsets.only(right: width(16)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: _buildTextFiled("名称", color_666, sp(16),
                          ingredients[index].nameController, 10,
                          validator: (v) =>
                              v.trim().length <= 0 ? "请输入食材名" : null),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: _buildTextFiled("用量", color_666, sp(16),
                          ingredients[index].amountController, 10,
                          validator: (v) =>
                              v.trim().length <= 0 ? "输入食材用量" : null),
                    ),
                  ),
                  _buildDeleteIcon(1, index)
                ],
              ),
            );
          },
          physics: NeverScrollableScrollPhysics(),
        ),
      );
    }, selector: (context, model) {
      return model.ingredients;
    });
  }

  Widget _buildBurdensView() {
    return Selector<NewWorksModel, List<RecipeMaterial>>(
        builder: (context, burdens, _) {
      return Container(
        child: ListView.separated(
          itemCount: burdens?.length ?? 1,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: width(16)),
              height: 1,
              color: skeletonGray,
            );
          },
          itemBuilder: (context, index) {
            if (burdens[index].nameController == null)
              burdens[index].nameController =
                  TextEditingController(text: burdens[index].name);
            if (burdens[index].amountController == null)
              burdens[index].amountController =
                  TextEditingController(text: burdens[index].amount);
            return Container(
              width: double.infinity,
              padding: EdgeInsets.only(right: width(16)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: _buildTextFiled("名称", color_666, sp(16),
                          burdens[index].nameController, 10,
                          validator: (v) =>
                              v.trim().length <= 0 ? "请输入调料名称" : null),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: _buildTextFiled("用量", color_666, sp(16),
                          burdens[index].amountController, 10,
                          validator: (v) =>
                              v.trim().length <= 0 ? "请输入调料用量" : null),
                    ),
                  ),
                  _buildDeleteIcon(2, index)
                ],
              ),
            );
          },
          physics: NeverScrollableScrollPhysics(),
        ),
      );
    }, selector: (context, model) {
      return model.burdens;
    });
  }

  Widget _buildStepsView() {
    return Selector<NewWorksModel, List<RecipeStep>>(
        builder: (context, steps, _) {
      return Container(
        child: ListView.separated(
          itemCount: steps?.length ?? 1,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: width(16)),
              height: 1,
              color: skeletonGray,
            );
          },
          itemBuilder: (context, index) {
            if (steps[index].stepController == null)
              steps[index].stepController =
                  TextEditingController(text: steps[index].step);
            return Container(
              margin: EdgeInsets.only(
                  left: width(0), bottom: height(16), right: width(16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: width(24)),
                    width: width(18),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        _buildTextPlaceholder(),
                        Image.asset(
                          index == 0
                              ? "assets/images/radio-checked.png"
                              : "assets/images/radio-unchecked.png",
                          width: width(16),
                          height: width(16),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: width(10)),
                    constraints: BoxConstraints(maxWidth: 26),
                    child: _buildTextPlaceholder(text: "${index + 1}."),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: _buildTextFiled("制作过程", color_666, sp(16),
                                  steps[index].stepController, 150,
                                  lines: 2,
                                  padding: EdgeInsets.only(
                                      top: height(0),
                                      bottom: height(0),
                                      left: width(0),
                                      right: width(16)),
                                  validator: (v) =>
                                      v.trim().length <= 0 ? "请输入制作过程" : null,
                                  onFieldSubmitted: (v) {}),
                            ),
                            ChangeNotifierProvider<RecipeStep>.value(
                              value: _newWorksModel.steps[index],
                              child: Consumer<RecipeStep>(
                                  builder: (context, model, child) {
                                return InkWell(
                                  onTap: () async {
                                    var image = await selectPicture(crop: true);
                                    if (image != null) {
                                      _newWorksModel?.updateStepImg(
                                          image.path, index);
                                    }
                                  },
                                  child: Container(
                                      decoration:
                                          BoxDecoration(color: skeletonGray),
                                      height: stepImageHeight,
                                      width: stepImageWidth,
                                      child: Center(
                                        child: StringUtils.isNotEmpty(
                                                model.local_img)
                                            ? Image.file(
                                                File(model.local_img),
                                                width: stepImageWidth,
                                                fit: BoxFit.fitWidth,
                                              )
                                            : StringUtils.isNotEmpty(model.img)
                                                ? Image.network(
                                                    model.img,
                                                    width: stepImageWidth,
                                                    fit: BoxFit.fitWidth,
                                                  )
                                                : Image.asset(
                                                    "assets/images/img-selector.png",
                                                  ),
                                      )),
                                );
                              }),
                            )
                          ],
                        )),
                        _buildDeleteIcon(3, index)
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          physics: NeverScrollableScrollPhysics(),
        ),
      );
    }, selector: (context, model) {
      return model.steps;
    });
  }

  Widget _buildStudyView() {
    return _buildTextFiled(
        "分享您的做菜心得...", color_666, sp(16), _newWorksModel.studyEtController, 150,
        lines: 4, validator: (v) => v.trim().length <= 0 ? "请输入您的做菜心得" : null);
  }

  Widget _buildAlbumView() {
    return InkWell(
        onTap: () async {
          var image = await selectPicture(crop: true);
          if (image != null) {
            _newWorksModel?.updateAlbum(image.path);
          }
        },
        child:
            Selector<NewWorksModel, String>(builder: (context, album, child) {
          return Container(
            height: albumHeight,
            child: StringUtils.isNotEmpty(album)
                ? Center(
                    child: Image.file(
                      File(album),
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          "assets/images/camera.png",
                          height: width(68),
                          width: width(68),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: height(0)),
                          child: Text(
                            "上传成品图",
                            style: textStyle(
                              color: themeAccentColor,
                              fontSize: sp(14),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
          );
        }, selector: (context, model) {
          return model.album;
        }));
  }

  Widget _buildNameView() {
    return _buildTextFiled(
      "输入您的菜名...",
      color_666,
      sp(16),
      _newWorksModel.nameEtController,
      10,
      validator: (v) => v.trim().length <= 0 ? "请输入菜名" : null,
    );
  }

  Widget _buildDeleteIcon(type, index) {
    return Container(
      height: height(30),
      child: InkWell(
        onTap: () {
          deleteItem(type, index);
        },
        child: Padding(
          padding: EdgeInsets.all(width(5)),
          child: index == 0
              ? SizedBox(
                  width: width(16),
                  height: width(16),
                )
              : Image.asset(
                  "assets/images/reduce.png",
                  width: width(16),
                  height: width(16),
                ),
        ),
      ),
    );
  }

  Widget _buildTitleView(title, type) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: height(6), horizontal: width(16)),
      color: color_f2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: textStyle(
                color: themeAccentColor,
                fontSize: sp(16),
                fontWeight: FontWeight.w600),
          ),
          type == null
              ? Container()
              : InkWell(
                  onTap: () {
                    addItem(type);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(width(5)),
                    child: Image.asset(
                      "assets/images/add-burden.png",
                      width: width(16),
                      height: width(16),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildTextPlaceholder({color = textColor, String text = ''}) {
    return TextFormField(
      enabled: false,
      textAlignVertical: TextAlignVertical.center,
      style: textStyle(
        color: color,
        fontWeight: bold,
        fontSize: sp(16),
      ),
      initialValue: text ?? '',
      maxLines: 1,
      decoration: InputDecoration(
        focusedErrorBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
        focusColor: themeAccentColor,
        hintStyle: textStyle(
            color: hintColor, fontWeight: FontWeight.w400, fontSize: sp(16)),
      ),
    );
  }

  Widget _buildTextFiled(
      hint, textColor, textSize, TextEditingController controller, length,
      {int lines = 1,
      EdgeInsetsGeometry padding,
      bool enable = true,
      validator,
      onFieldSubmitted}) {
    return Padding(
      padding: padding ??
          EdgeInsets.only(
              top: height(0),
              bottom: height(0),
              left: width(24),
              right: width(16)),
      child: TextFormField(
        autovalidate: false,
        enabled: enable,
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.next,
        style: textStyle(
          color: textColor,
          fontWeight: FontWeight.w400,
          fontSize: textSize,
        ),
        showCursor: true,
        maxLines: lines,
        inputFormatters: [LengthLimitingTextInputFormatter(length)],
        decoration: InputDecoration(
          focusedErrorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          border: InputBorder.none,
          hintText: hint,
          focusColor: themeAccentColor,
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

  ///1食材，2调料，3步骤
  void addItem(type) {
    _newWorksModel.addItem(type);
  }

  void deleteItem(type, index) {
    _newWorksModel.deleteItem(type, index);
  }

  Future showConfirmDialog() async {
    int type;
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
                          "提交",
                          style: textStyle(
                              color: textColor,
                              fontSize: sp(16),
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      type = 1;
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
                      type = 2;
                    },
                    child: Container(
                      width: double.infinity,
                      height: height(40),
                      child: Center(
                        child: Text(
                          "保存",
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
    return type;
  }
}
