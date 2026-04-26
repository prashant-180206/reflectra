import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Apikeystore {
  static final storage = FlutterSecureStorage();
  static final apiKeyStorageKey = 'api_key';

  static Future<void> setKey(String value) async {
    await storage.write(key: apiKeyStorageKey, value: value);
  }

  static Future<void> deleteKey() async {
    await storage.delete(key: apiKeyStorageKey);
  }

  static Future<bool> hasKey() async {
    return await storage.containsKey(key: apiKeyStorageKey);
  }

  static Future<String?> getKey() async {
    return storage.read(key: apiKeyStorageKey);
  }
}
