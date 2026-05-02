import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ModelNameStore {
  static final storage = FlutterSecureStorage();
  static final modelNameStorageKey = 'model_name';

  static Future<void> setModelName(String value) async {
    await storage.write(key: modelNameStorageKey, value: value);
  }

  static Future<void> deleteModelName() async {
    await storage.delete(key: modelNameStorageKey);
  }

  static Future<bool> hasModelName() async {
    return await storage.containsKey(key: modelNameStorageKey);
  }

  static Future<String?> getModelName() async {
    return storage.read(key: modelNameStorageKey);
  }
}
