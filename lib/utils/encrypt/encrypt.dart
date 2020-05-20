import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:lazycook/utils/logger.dart';

class EncryptUtils {
  static Logger logger = Logger('EncryptUtils');

  static String base64En(Uint8List byteData) {
    return base64Encode(byteData);
  }

  static Uint8List base64De(String s) {
    return base64Decode(s);
  }

  static Future<String> encryptMD5(String data) async {
    return md5.convert(utf8.encode(data)).toString();
  }

  static Future<String> encryptAES(String data, String key, String iv) async {
    try {
      var encrypter = Encrypter(AES(Key(utf8.encode(key)), mode: AESMode.cbc));
      return encrypter.encrypt(data, iv: IV.fromBase16(iv)).base16;
    } catch (e) {
      logger.log(e);
    }
    return "";
  }

  static Future<String> encryptRSA(String data, String publicKey) async {
    try {
      var parser = RSAKeyParser();
      var key = parser.parse(publicKey);
      var encrypter = Encrypter(RSA(publicKey: key));
      return encrypter.encrypt(data).base16;
    } catch (e) {
      logger.log(e);
    }
    return "";
  }

  static String decryptRSA(String data, String privateKey) {
    int a = 1;
    a.toRadixString(16).toLowerCase();
    return "";
  }
}
