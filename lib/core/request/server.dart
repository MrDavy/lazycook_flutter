import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lazycook/application.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/core/models/protocol/result.dart';
import 'package:lazycook/core/request/interceptor/auth.dart';
import 'package:lazycook/core/request/interceptor/result.dart';
import 'package:lazycook/core/request/exception/error.dart';
import 'package:lazycook/utils/encrypt/encrypt.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:lazycook/utils/string_utils.dart';
import 'package:lazycook/utils/utils.dart';

class Server {
  factory Server() => _getInstance();
  static Server _instance;

  static Server get instance => _getInstance();
  ProgressCallback onSendProgress;
  ProgressCallback onReceiveProgress;
  Dio dio;
  Logger logger = Logger('Server');

//  HashMap<String, CancelToken> tokens = HashMap();

  static Server _getInstance() {
    if (_instance == null) {
      _instance = Server._internal();
    }
    return _instance;
  }

  registerProgressCallback(
      ProgressCallback onSendProgress, ProgressCallback onReceiveProgress) {
    this.onSendProgress = onSendProgress;
    this.onReceiveProgress = onReceiveProgress;
  }

  unregisterProgressCallback() {
    this.onSendProgress = null;
    this.onReceiveProgress = null;
  }

  sendProgress(int count, int total) {
    if (onSendProgress != null) {
      onSendProgress(count, total);
    }
  }

  receiveProgress(int count, int total) {
    if (onReceiveProgress != null) {
      onReceiveProgress(count, total);
    }
  }

  Server._internal() {
    var options = BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 30000,
        baseUrl: Config.envConfig().baseUrl(),
        validateStatus: (status) {
          return status >= 200 && status < 300;
        });
    dio = Dio(options);
//    dio.transformer = FlutterTransformer();
    dio.interceptors.add(AuthInterceptor());
//    if (Config.env != Env.prod) {
//      dio.interceptors.add(LogInterceptor(
//          requestBody: true, requestHeader: true, responseBody: true));
//    }
    dio.interceptors.add(ResultInterceptor());
  }

  void cancel(String key) {
//    try {
//      var token = tokens[key];
//      if (token?.isCancelled == false) {
//        token?.cancel("中断请求");
//      }
//    } catch (e) {}
  }

  void dispose() {
//    try {
//      tokens?.forEach((key, token) {
//        if (token?.isCancelled == false) {
//          token?.cancel();
//        }
//      });
//    } catch (e) {
//      logger.log("e = $e");
//    }
//    tokens?.clear();
  }

  ///请求方式：get
  ///返回参数：{'data':<dynamic>，'error':<Error>}
  Future get(String url, CancelToken token,
      [Map<String, dynamic> headers]) async {
    if (headers?.isNotEmpty == true) {
      dio.options.headers.addAll(headers);
    }
    return await futureWrap(url, dio.get(url, cancelToken: token));
  }

  ///请求方式：post
  ///参数类型：Map<String,dynamic>
  ///返回参数：{'data':<dynamic>，'error':<Error>}
  Future<T> post<T>(String url, Map<String, dynamic> params, CancelToken token,
      [Map<String, dynamic> headers, List<String> files]) async {
//    logger.log("post url = $url，headers = $headers");
    if (headers?.isNotEmpty == true) {
      dio.options.headers.addAll(headers);
    }

    var map = await _encryptParams(json.encode(params ?? Map()));
    if (files?.isNotEmpty == true) {
      var list =
          files.map<MultipartFile>((file) => MultipartFile.fromFileSync(file)).toList();
      map["files"] = list;
    }
    var data = FormData.fromMap(map);
    return await futureWrap(url, dio.post(url, data: data, cancelToken: token));
  }

  Future<Map<String, dynamic>> _encryptParams(String paramJson) async {
//    logger.log("_encryptParams params = $paramJson");
    if (StringUtils.isEmpty(Application.encryptKey)) {
      Application.encryptKey =
          await rootBundle.loadString("assets/pem/rsa-public.pem");
    }
    var key = SecureRandom(16).base16;
    var iv = IV.fromSecureRandom(8);
//    logger.log("key = $key");
//    logger.log("iv = ${iv.base16}");
    var appKey = await EncryptUtils.encryptRSA(
        "$key.${iv.base16}", Application.encryptKey);
//    logger.log("appKey = $appKey");
    var appId = "ldc910209";
    var timestamp = DateTime.now().millisecondsSinceEpoch;
//    logger.log("timestamp = $timestamp");
    var sign = sha1.convert(
        utf8.encode("appId=$appId&appKey=$appKey&timestamp=$timestamp"));
//    logger.log("sign = $sign");
//    iv = IV.fromBase16(Encrypted(utf8.encode(iv.base16)).base16);
//    logger.log("iv base 64 = ${iv.base16}");
    var params = await EncryptUtils.encryptAES(paramJson, key,
        IV.fromBase16(Encrypted(utf8.encode(iv.base16)).base16).base16);
//    logger.log("params = $params");
    return {
      "appKey": appKey,
      "appId": appId,
      "timestamp": timestamp,
      "sign": sign,
      "params": params
    };
  }

  ///请求方式：post
  ///参数类型：FormData
  ///返回参数：{'data':<dynamic>，'error':<Error>}
  Future postForm(String url, FormData data, CancelToken token) async {
    return await futureWrap(url, dio.post(url, data: data, cancelToken: token));
  }

  download(String url) {}

  upload(String url) {}

  ///统一处理接口结果
  Future futureWrap(String key, Future future) {
    return future.then((res) {
      logger.log("res = ${res}");
//      logger.log("res.data= ${res.data.runtimeType}");
      var json = res.data;
      if (json is String) {
        json = jsonDecode(json);
      }
//      logger.log("json = $json");
      Result resultData = Result.fromJson(json);
      logger.log("code = $resultData");
      if (resultData.code == 0) {
        //成功
        var data = resultData.data;
        return {'data': data};
      } else {
//        logger.log("error = ${resultData.toString()}");
        throw LazyError(
            code: resultData.code,
            message: resultData.msg,
            extra: resultData.extra);
      }
    }).catchError((err) {
      logger.log("1url：$key，error = $err");
      var e;
      logger.log("type = ${err is DioError}");
      if (err is DioError) {
        e = LazyError(message: "系统错误", code: 2000);
      } else
        e = err;
      return {'error': e};
    });
  }
}
//
//parse(data) {
//  if (data is Map) {
//    return parseMap(data);
//  } else if (data is List) {
//    return parseList(data);
//  }
//}
//
//parseMap(data) {
//  var newData = {};
//  data.forEach((key, value) {
//    var child = value;
//    if (value is Map) {
//      child = parseMap(value);
//    } else if (value is List) {}
//
//    newData[key] = child;
//  });
//  return newData;
//}
//
//parseList(list) {
//  var newData = [];
//  list.forEach((data) {
//    var child = data;
//    if (data is Map) {
//      child = parseMap(data);
//    } else if (data is List) {
//      child = parseList(data);
//    }
//    newData.add(child);
//  });
//  return newData;
//}
