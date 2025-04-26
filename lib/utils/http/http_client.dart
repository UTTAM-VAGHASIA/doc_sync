import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:doc_sync/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class AppHttpHelper {
  final _baseUrl = ApiConstants().baseUrl;
  static const _timeoutDuration = ApiConstants.timeoutDuration;

  /*

    Sample Usage: 

    final result = await MultipartHttpHelper.sendMultipartRequest(
    'multi-file-upload',
    method: 'POST',
    fields: {
      'userId': '123',
      'description': 'Some files being uploaded',
    },
    fileMap: {
      'images': [
        File('/path/to/image1.jpg'),
        File('/path/to/image2.jpg'),
      ],
      'documents': [
        File('/path/to/doc1.pdf'),
      ],
    },
  );


  */

  /// Sends a multipart request with optional files and fields
  Future<Map<String, dynamic>> sendMultipartRequest(
    String endpoint, {
    required String method, // 'POST', 'PUT', etc.
    Map<String, List<File>>?
    fileMap, // NEW: key = fieldName, value = list of files
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final request = http.MultipartRequest(method, uri);

      if (headers != null) request.headers.addAll(headers);
      if (fields != null) request.fields.addAll(fields);

      // Add multiple file fields
      if (fileMap != null && fileMap.isNotEmpty) {
        for (var entry in fileMap.entries) {
          final fieldName = entry.key;
          final fileList = entry.value;

          for (File file in fileList) {
            request.files.add(
              await http.MultipartFile.fromPath(fieldName, file.path),
            );
          }
        }
      }

      final streamedResponse = await request.send().timeout(_timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      print(response.statusCode);
      final data = json.decode(response.body);
      print(data.toString());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to parse response');
    }
  }

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
