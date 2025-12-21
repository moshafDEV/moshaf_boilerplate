import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../env/secure_storage_key.dart';

const FlutterSecureStorage storage = FlutterSecureStorage();

class SecureStorageUtils {
  static Future<void> setStorageJSON(
    String key,
    Map<String, dynamic> value,
  ) async {
    if (value.isNotEmpty) {
      var jsonString = jsonEncode(value);
      await storage.write(
        key: key,
        value: base64Encode(utf8.encode(jsonString)),
      );
    }
  }

  static Future<Map<String, dynamic>> getStorageJSON(String key) async {
    try {
      var jsonString = utf8.decode(
        base64Decode(await storage.read(key: key) ?? ''),
      );
      return jsonDecode(jsonString);
    } catch (e) {
      return {};
    }
  }

  static Future<void> setStorage(String key, String data) async {
    await storage.write(key: key, value: data);
  }

  static Future<String> getStorage(String key) async {
    return (await storage.read(key: key) ?? '');
  }

  static Future<void> removeStorage(String key) async {
    await storage.delete(key: key);
  }

  static Future<void> clearStorage() async {
    final valueToKeep = await storage.read(key: fcmToken);

    await storage.deleteAll();

    if (valueToKeep != null) {
      await storage.write(key: fcmToken, value: valueToKeep);
    }
  }
}
