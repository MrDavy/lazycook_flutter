import 'package:lazycook/utils/logger.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

///本地存储
class StorageManager {
  static LocalStorage localStorage;

  static SharedPreferences sharedPreferences;

  ///初始化，该方法只执行一次
  static init() async {
    if (localStorage == null) {
      localStorage = LocalStorage("localstorage");
      await localStorage.ready;
    }
    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then((PermissionStatus status) {
      if (status != PermissionStatus.granted) {
        PermissionHandler().requestPermissions(<PermissionGroup>[
          PermissionGroup.storage,
          // 在这里添加需要的权限
        ]);
      }
    });
    Logger("StorageManager").log("localStorage init end");
  }
}
