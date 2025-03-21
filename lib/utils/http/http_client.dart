import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class AppHttpHelper {
  static const String _baseUrl = ''; // Replace with your API base URL
  static const Duration _timeoutDuration = Duration(
    seconds: 15,
  ); // Timeout setting

  // Generic method to handle GET requests
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/$endpoint'), headers: headers)
          .timeout(_timeoutDuration);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    } on HttpException {
      throw Exception('Couldn\'t connect to server');
    } on FormatException {
      throw Exception('Bad response format');
    } on TimeoutException {
      throw Exception('Request timeout');
    }
  }

  // Generic method to handle POST requests
  static Future<Map<String, dynamic>> post(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: headers ?? {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(_timeoutDuration);
      return _handleResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  // Generic method to handle PUT requests
  static Future<Map<String, dynamic>> put(
    String endpoint,
    dynamic data, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: headers ?? {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(_timeoutDuration);
      return _handleResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  // Generic method to handle DELETE requests
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/$endpoint'), headers: headers)
          .timeout(_timeoutDuration);
      return _handleResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  // Multipart request for file upload
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? headers,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/$endpoint'),
      );
      request.headers.addAll(headers ?? {});
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  // Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to parse response');
    }
  }

  // Handle different types of exceptions
  static Map<String, dynamic> _handleException(dynamic e) {
    if (e is SocketException) {
      throw Exception('No Internet connection');
    } else if (e is HttpException) {
      throw Exception('Couldn\'t connect to server');
    } else if (e is FormatException) {
      throw Exception('Bad response format');
    } else if (e is TimeoutException) {
      throw Exception('Request timeout');
    } else {
      throw Exception('Unexpected error: $e');
    }
  }
}
