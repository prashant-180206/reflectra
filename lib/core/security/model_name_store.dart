import 'package:reflectra/core/singleton.dart';

class ModelNameStore {
  static final modelNameStorageKey = 'model_name';

  static Future<void> setModelName(String value) async {
    await secureStorage.write(key: modelNameStorageKey, value: value);
  }

  static Future<void> deleteModelName() async {
    await secureStorage.delete(key: modelNameStorageKey);
  }

  static Future<bool> hasModelName() async {
    return await secureStorage.containsKey(key: modelNameStorageKey);
  }

  static Future<String?> getModelName() async {
    return await secureStorage.read(key: modelNameStorageKey);
  }
}
