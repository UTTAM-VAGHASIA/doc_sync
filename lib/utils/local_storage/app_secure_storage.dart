import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

class AppSecureStorage {
  static AppSecureStorage? _instance;
  late final FlutterSecureStorage _secureStorage;
  
  // Flag to track if we've encountered encryption errors
  static bool _encryptionErrorDetected = false;
  
  // Getter to check encryption status from outside
  static bool get hasEncryptionError => _encryptionErrorDetected;

  AppSecureStorage._internal() {
    // Use Android options that help with migrations
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true, // More resilient to app reinstalls
      resetOnError: false, // Don't reset automatically, we'll handle it
    );
    
    _secureStorage = const FlutterSecureStorage(
      aOptions: androidOptions,
    );
  }

  factory AppSecureStorage.instance() {
    _instance ??= AppSecureStorage._internal();
    return _instance!;
  }

  Future<void> writeData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      developer.log('Error writing secure data: $e', name: 'AppSecureStorage');
      // If we get an error while writing, we might need to reset the storage
      await _handleEncryptionError();
      
      // Try one more time after reset
      try {
        await _secureStorage.write(key: key, value: value);
      } catch (e) {
        developer.log('Error writing secure data after reset: $e', name: 'AppSecureStorage');
      }
    }
  }

  Future<String?> readData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      developer.log('Error reading secure data: $e', name: 'AppSecureStorage');
      // Handle decryption or other storage errors
      await _handleEncryptionError();
      return null; // Return null when decryption fails
    }
  }

  Future<void> removeData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      developer.log('Error removing secure data: $e', name: 'AppSecureStorage');
      await _handleEncryptionError();
    }
  }

  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      // Reset the error flag when we successfully clear everything
      _encryptionErrorDetected = false;
    } catch (e) {
      developer.log('Error clearing secure storage: $e', name: 'AppSecureStorage');
      // If deleteAll fails, try individual deletes as fallback
      await _handleEncryptionError();
    }
  }
  
  // Private method to handle encryption errors
  Future<void> _handleEncryptionError() async {
    _encryptionErrorDetected = true;
    
    // Try to clear all data to recover from error state
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      developer.log('Error in recovery attempt (deleteAll): $e', name: 'AppSecureStorage');
      
      // As a last resort, try to create a new instance with resetOnError
      const lastResortOptions = AndroidOptions(
        resetOnError: true,
        encryptedSharedPreferences: true,
      );
      
      final lastResortStorage = FlutterSecureStorage(
        aOptions: lastResortOptions,
      );
      
      try {
        await lastResortStorage.deleteAll();
      } catch (e) {
        developer.log('Final recovery attempt failed: $e', name: 'AppSecureStorage');
      }
    }
  }
}
