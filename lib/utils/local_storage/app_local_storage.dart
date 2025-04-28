import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalStorage {
  final String _bucketName;
  static final Map<String, AppLocalStorage> _instances = {};
  static SharedPreferences? _prefsInstance;

  AppLocalStorage._internal(this._bucketName);

  // Helper to get the SharedPreferences instance
  static Future<SharedPreferences> _getPrefs() async {
    _prefsInstance ??= await SharedPreferences.getInstance();
    return _prefsInstance!;
  }

  // Create a prefixed key with bucket name
  String _prefixKey(String key) => '${_bucketName}_$key';

  static Future<AppLocalStorage> getInstance(String bucketName) async {
    if (!_instances.containsKey(bucketName)) {
      // Ensure SharedPreferences is initialized
      await _getPrefs();
      final storage = AppLocalStorage._internal(bucketName);
      _instances[bucketName] = storage;
    }
    print("Instance created for bucket: $bucketName");
    print(_instances[bucketName]!.readData("userData"));
    return _instances[bucketName]!;
  }

  Future<void> writeData<T>(String key, T value) async {
    final prefs = await _getPrefs();
    final prefixedKey = _prefixKey(key);
    
    if (value is String) {
      print("Writing string value: $value");
      await prefs.setString(prefixedKey, value);
    } else if (value is int) {
      print("Writing int value: $value");
      await prefs.setInt(prefixedKey, value);
    } else if (value is double) {
      print("Writing double value: $value");
      await prefs.setDouble(prefixedKey, value);
    } else if (value is bool) {
      print("Writing bool value: $value");
      await prefs.setBool(prefixedKey, value);
    } else if (value is List<String>) {
      print("Writing list value: $value");
      await prefs.setStringList(prefixedKey, value);
    } else {
      // For complex objects, convert to JSON string
      print("Writing complex object: $value");
      await prefs.setString(prefixedKey, jsonEncode(value));
    }
  }

  T? readData<T>(String key) {
    // This needs to be synchronous to match the original API
    final prefixedKey = _prefixKey(key);
    final value = _prefsInstance?.get(prefixedKey);
    
    if (value == null) return null;
    
    // Handle type conversion
    if (T == String) {
      return value as T;
    } else if (T == int) {
      return value as T;
    } else if (T == double) {
      return value as T;
    } else if (T == bool) {
      return value as T;
    } else if (value is List<String>) {
      return value as T;
    } else if (value is String) {
      // Try to decode JSON for complex objects
      try {
        print("Value read from storage: $value");
        return jsonDecode(value) as T;
      } catch (_) {
        return value as T;
      }
    }
    print("Value read from storage: $value");
    return value as T;
  }

  Future<void> removeData(String key) async {
    print("Removing data for key: $key");
    final prefs = await _getPrefs();
    await prefs.remove(_prefixKey(key));
  }

  Future<void> clearAll() async {
    print("Clearing all data for bucket: $_bucketName");
    final prefs = await _getPrefs();
    // Only remove keys that belong to this bucket
    final keysToRemove = prefs.getKeys()
        .where((key) => key.startsWith('${_bucketName}_'))
        .toList();
    
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }
}
