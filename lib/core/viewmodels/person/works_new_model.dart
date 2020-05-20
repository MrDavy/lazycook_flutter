import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lazycook/core/models/dish.dart';
import 'package:lazycook/core/models/result_data.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/utils/string_utils.dart';

class ParamData {
  String title;
  String ingredients = "";
  String burden = "";
  List<RecipeStep> steps;
  int canBeSale = 0;

  ParamData(
      {this.title = "",
      this.ingredients = "",
      this.burden = "",
      this.steps,
      this.canBeSale});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['ingredients'] = this.ingredients;
    data['burden'] = this.burden;
    data['canBeSale'] = this.canBeSale;
    if (this.steps != null) {
      data['steps'] = this.steps.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RecipeMaterial {
  String name;
  String amount;
  TextEditingController nameController;
  TextEditingController amountController;

  RecipeMaterial(
      {this.name = "",
      this.amount = "",
      this.nameController,
      this.amountController});

  @override
  String toString() {
    return "${nameController.text},${amountController.text}";
  }
}

class RecipeStep extends BaseChangeNotifier {
  int d_id;
  int id;
  String img;
  String local_img;
  String ori_img;
  String step;
  TextEditingController stepController;

  RecipeStep(
      {this.d_id,
      this.id,
      this.local_img,
      this.ori_img,
      this.step = "",
      this.img,
      this.stepController});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['d_id'] = this.d_id;
    data['id'] = this.id;
    data['img'] = this.img;
    data['ori_img'] = this.ori_img;
    data['step'] = stepController.text;
    return data;
  }

  updateLocalImg(img) {
    local_img = img;
    notifyListeners();
  }
}

class NewWorksModel extends BaseModel {
  NewWorksModel(API api) : super(api);
  TextEditingController nameEtController = TextEditingController();
  TextEditingController studyEtController = TextEditingController();

  String _album;

  String get album => _album;

  List<RecipeMaterial> _ingredients;

  List<RecipeMaterial> get ingredients => _ingredients;

  List<RecipeMaterial> _burdens;

  List<RecipeMaterial> get burdens => _burdens;

  List<RecipeStep> _steps;

  List<RecipeStep> get steps => _steps;

  createEmptyData() {
    _ingredients = [RecipeMaterial(name: "", amount: "")];
    _burdens = [RecipeMaterial(name: "", amount: "")];
    _steps = [RecipeStep()];
  }

  _addStep() {
    _steps.add(RecipeStep());
    notifyListeners();
  }

  _addIngredient() {
    _ingredients.add(RecipeMaterial());
    notifyListeners();
  }

  _addBurden() {
    _burdens.add(RecipeMaterial());
    notifyListeners();
  }

  addItem(type) {
    switch (type) {
      case 1:
        _addIngredient();
        break;
      case 2:
        _addBurden();
        break;
      case 3:
        _addStep();
        break;
    }
  }

  deleteItem(type, index) {
    switch (type) {
      case 1:
        if (index < (_ingredients?.length ?? 0)) {
          _ingredients.removeAt(index);
        }
        break;
      case 2:
        if (index < (_burdens?.length ?? 0)) {
          _burdens.removeAt(index);
        }
        break;
      case 3:
        if (index < (_steps?.length ?? 0)) {
          _steps.removeAt(index);
        }
        break;
    }
    notifyListeners();
  }

  updateAlbum(album) {
    _album = album;
    notifyListeners();
  }

  updateStepImg(img, index) {
    _steps[index].updateLocalImg(img);
  }

  Future checkParams() async {
    dynamic result;
    await Future.sync(() {
      if (StringUtils.isEmpty(_album)) {
        result = "请上传成品图";
        return null;
      }
      for (var step in _steps) {
        if (StringUtils.isEmpty(step.local_img) &&
            StringUtils.isEmpty(step.img)) {
          result = "请选择制作过程图片";
          return null;
        }
      }
      Map<String, dynamic> params = {};
      List<MultipartFile> files = [];
      for (var step in _steps) {
        if (StringUtils.isNotEmpty(step.local_img)) {
          files.add(MultipartFile.fromFileSync(step.local_img,
              filename: step.local_img));
        }
      }

      params["album"] =
          MultipartFile.fromFileSync(album, filename: "album.png");
      params["step_img"] = files;

      params["title"] = nameEtController.text;
      params["canBeSale"] = 1;
      params["steps"] = _steps;

      String ingredients = "";
      _ingredients.forEach((value) {
        ingredients += value.toString();
        ingredients += ";";
      });
      params["ingredients"] =
          ingredients.substring(0, ingredients.lastIndexOf(";"));
      String burden = "";
      _burdens.forEach((value) {
        burden += value.toString();
        burden += ";";
      });
      params["burden"] = burden.substring(0, burden.lastIndexOf(";"));
      logger.log("params = $params");
      result = params;
    });
    return result;
  }

  Future submit(params) {
    return api.addWork(params);
  }

  @override
  List<String> requests() {
    return null;
  }
}
