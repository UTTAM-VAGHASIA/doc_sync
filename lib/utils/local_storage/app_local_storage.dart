import 'package:get_storage/get_storage.dart';

class AppLocalStorage {
  final GetStorage _storage;

  static final Map<String, AppLocalStorage> _instances = {};

  AppLocalStorage._internal(this._storage);

  static Future<AppLocalStorage> getInstance(String bucketName) async {
    if (!_instances.containsKey(bucketName)) {
      await GetStorage.init(bucketName);
      final storage = AppLocalStorage._internal(GetStorage(bucketName));
      _instances[bucketName] = storage;
    }
    return _instances[bucketName]!;
  }

  Future<void> writeData<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  T? readData<T>(String key) {
    return _storage.read<T>(key);
  }

  Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

  Future<void> clearAll() async {
    await _storage.erase();
  }
}
