import 'dart:convert';

import 'package:doc_sync/features/authentication/models/user_model.dart';
import 'package:doc_sync/utils/constants/enums.dart' show StorageType;
import 'package:doc_sync/utils/local_storage/app_local_storage.dart';
import 'package:doc_sync/utils/local_storage/app_secure_storage.dart';

class StorageUtility {
  static StorageUtility? _instance;
  final AppSecureStorage _secure;

  StorageUtility._internal() : _secure = AppSecureStorage.instance();

  factory StorageUtility.instance() {
    _instance ??= StorageUtility._internal();
    return _instance!;
  }

  Future<void> writeData(
    String key,
    String value, {
    StorageType type = StorageType.local,
    String bucket = 'userData',
  }) async {
    if (type == StorageType.secure) {
      await _secure.writeData(key, value);
    } else {
      final local = await AppLocalStorage.getInstance(bucket);
      await local.writeData<String>(key, value);
    }
  }

  Future<String?> readData(
    String key, {
    StorageType type = StorageType.local,
    String bucket = 'userData',
  }) async {
    try {
      if (type == StorageType.secure) {
        return await _secure.readData(key);
      } else {
        final local = await AppLocalStorage.getInstance(bucket);
        return local.readData<String>(key);
      }
    } catch (e) {
      // Log the error
      print('Error reading data from ${type.name} storage: $e');
      
      // If secure storage fails, return null to trigger recovery logic
      if (type == StorageType.secure) {
        return null;
      }
      
      // For local storage, we can rethrow as it's less likely to have encryption issues
      rethrow;
    }
  }

  Future<void> removeData(
    String key, {
    StorageType type = StorageType.local,
    String bucket = 'userData',
  }) async {
    if (type == StorageType.secure) {
      await _secure.removeData(key);
    } else {
      final local = await AppLocalStorage.getInstance(bucket);
      await local.removeData(key);
    }
  }

  Future<void> clearAll({
    bool clearLocal = true,
    bool clearSecure = true,
    List<String> localBuckets = const ['userData'],
  }) async {
    if (clearLocal) {
      for (final bucket in localBuckets) {
        final local = await AppLocalStorage.getInstance(bucket);
        await local.clearAll();
      }
    }
    if (clearSecure) await _secure.clearAll();
  }

  Future<void> clearUser() async {
    await _secure.removeData(
      User.fromJson(jsonDecode(await readData("user", type: StorageType.local) ?? '{}')).id ?? '',
    );

    final local = await AppLocalStorage.getInstance('userData');
    await local.clearAll();
  }
}
