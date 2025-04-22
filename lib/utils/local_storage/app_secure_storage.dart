import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  static AppSecureStorage? _instance;
  late final FlutterSecureStorage _secureStorage;

  AppSecureStorage._internal() {
    _secureStorage = const FlutterSecureStorage();
  }

  factory AppSecureStorage.instance() {
    _instance ??= AppSecureStorage._internal();
    return _instance!;
  }

  Future<void> writeData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> readData(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> removeData(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
