/*
 * 网络请求的
 */
class TokenManager {
  factory TokenManager() => _getInstance();

  static TokenManager _instance;

  static TokenManager get instance => _getInstance();

  static TokenManager _getInstance() {
    if (_instance == null) {
      _instance = TokenManager._internal();
    }
    return _instance;
  }

  TokenManager._internal() {}
}
