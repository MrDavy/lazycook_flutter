import 'dart:ui';

import 'package:lazycook/config/storage_manager.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';

///
/// 主题切换
///
class ThemeModel extends BaseChangeNotifier {
  static const KEY_THEME_COLOR = "KEY_THEME_COLOR";

  Color _accentColor;
  Color _secondColor;

  int _colorIndex;

  ThemeModel() {
    _colorIndex = StorageManager.sharedPreferences.getInt(KEY_THEME_COLOR);
    _accentColor = accentColors[_colorIndex ?? 0];
    _secondColor = secondColors[_colorIndex ?? 0];
  }

  Color get accentColor => _accentColor;

  Color get secondColor => _secondColor;

  changeColor(int index) {
    _accentColor = accentColors[index];
    _secondColor = secondColors[index];
    notifyListeners();
    _saveColor(index);
  }

  _saveColor(int index) async {
    await StorageManager.sharedPreferences.setInt(KEY_THEME_COLOR, index);
  }
}

const accentColors = [
  const Color(0xffff9900),
  const Color(0xff3f48cc),
  const Color(0xffffaec8)
];
const secondColors = [
  const Color(0xFFFF6757),
  const Color(0xFFFF6757),
  const Color(0xFFFF6757)
];
