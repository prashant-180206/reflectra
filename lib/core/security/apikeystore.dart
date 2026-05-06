import 'package:reflectra/core/singleton.dart';

class Apikeystore {
  static final apiKeyStorageKey = 'api_key';

  static Future<void> setKey(String value) async {
    await secureStorage.write(key: apiKeyStorageKey, value: value);
  }

  static Future<void> deleteKey() async {
    await secureStorage.delete(key: apiKeyStorageKey);
  }

  static Future<bool> hasKey() async {
    return await secureStorage.containsKey(key: apiKeyStorageKey);
  }

  static Future<String?> getKey() async {
    return await secureStorage.read(key: apiKeyStorageKey);
  }
}
