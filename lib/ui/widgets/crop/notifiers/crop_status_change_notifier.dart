import 'package:flutter/cupertino.dart';
import 'package:lazycook/ui/widgets/crop/painter/image_clipper.dart';
import 'package:lazycook/utils/logger.dart';

class CropStatusChangeNotifier extends ChangeNotifier {
  Logger _logger = Logger("CropStatusChangeNotifier");

  ///是否裁剪完成，用于切换裁剪界面
  bool _cropComplete = false;

  bool get cropComplete => _cropComplete;

  set cropComplete(bool complete) {
    _cropComplete = complete;
    _logger.log("cropComplete = $cropComplete");
    notifyListeners();
  }

  update() {
    _logger.log("update");
  }
}
