// import 'dart:convert';
// import 'package:atc_drive/app/model/get_all_files_model.dart';
// import 'package:atc_drive/app/model/get_all_user_model.dart';
// import 'package:atc_drive/app/services/storage_service.dart';
// import 'package:http/http.dart' as http;

// class NetworkService {
//   final String baseUrl = "http://65.2.96.95/v1";

//   Future<dynamic> post(String endpoint, {dynamic body}) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/$endpoint'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(body),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<dynamic> get(String endpoint) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/$endpoint'),
//         headers: {
//           'Authorization': 'Bearer ${StorageService.getAccessToken()}',
//           'Content-Type': 'application/json',
//         },
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<dynamic> createFolder(String endpoint, {dynamic body}) async {
//     try {
//       final headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${StorageService.getAccessToken()}',
//       };

//       final response = await http.post(
//         Uri.parse('$baseUrl/$endpoint'),
//         headers: headers,
//         body: json.encode(body),
//       );

//       return _handleResponse(response);
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<GetAllFiles?> fetchFiles() async {
//     try {
//       final response = await get('folder/files');
//       return GetAllFiles.fromJson(response);
//     } catch (e) {
//       throw Exception('Failed to fetch files: $e');
//     }
//   }

//   Future<List<User>> getAllUsers() async {
//     try {
//       final response = await get('auth/all/users');
//       final List<dynamic> userList = response['detail'];
//       return userList.map((userJson) => User.fromJson(userJson)).toList();
//     } catch (e) {
//       throw Exception('Failed to fetch users: $e');
//     }
//   }

//   Future<void> shareItem({
//     required String itemId,
//     required String itemType,
//     required List<String> sharedWithUserEmails,
//     required List<String> actions,
//   }) async {
//     try {
//       await post(
//         'folder/$itemType/share',
//         body: {
//           'item_type': itemType,
//           'item_id': itemId,
//           'shared_with_user_emails': sharedWithUserEmails,
//           'actions': actions,
//         },
//       );
//     } catch (e) {
//       throw Exception('Failed to share item: $e');
//     }
//   }

//   dynamic _handleResponse(http.Response response) {
//     switch (response.statusCode) {
//       case 200:
//         return json.decode(response.body);
//       case 400:
//         throw Exception('Bad Request: ${response.body}');
//       case 401:
//         throw Exception('Unauthorized: ${response.body}');
//       case 500:
//         throw Exception('Server Error: ${response.body}');
//       default:
//         throw Exception('Unexpected error: ${response.statusCode}');
//     }
//   }
// }

import 'dart:convert';

import 'package:atc_drive/app/model/get_all_files_model.dart';
import 'package:atc_drive/app/model/get_all_user_model.dart';
import 'package:atc_drive/app/services/storage_service.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  final String baseUrl = "http://93.127.137.160/v1";

  /// 🔹 Generic method to handle all API requests with refresh token logic
  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    dynamic body,
    bool retrying = false,
  }) async {
    Uri url = Uri.parse('$baseUrl/$endpoint');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${StorageService.getAccessToken()}',
    };

    http.Response response;

    try {
      if (method == 'POST') {
        response =
            await http.post(url, headers: headers, body: json.encode(body));
      } else if (method == 'GET') {
        response = await http.get(url, headers: headers);
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      // 🔹 Handle 401 Unauthorized (Token Expired)
      if (response.statusCode == 401 && !retrying) {
        bool refreshed = await refreshToken();
        if (refreshed) {
          return _makeRequest(method, endpoint, body: body, retrying: true);
        } else {
          throw Exception('Session expired. Please log in again.');
        }
      }

      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 🔹 Refresh Token API Call
  Future<bool> refreshToken() async {
    try {
      String? refreshToken = StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse("$baseUrl/auth/refresh-token"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final newAccessToken = data['detail']['access_token'];
        if (newAccessToken != null) {
          StorageService.saveAccessToken(newAccessToken);
          return true;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<dynamic> post(String endpoint, {dynamic body}) async {
    final response = await _makeRequest('POST', endpoint, body: body);
    return _handleResponse(response);
  }

  Future<dynamic> get(String endpoint) async {
    final response = await _makeRequest('GET', endpoint);
    return _handleResponse(response);
  }

  Future<dynamic> createFolder(String endpoint, {dynamic body}) async {
    final response = await _makeRequest('POST', endpoint, body: body);
    return _handleResponse(response);
  }

  Future<GetAllFiles?> fetchFiles() async {
    final response = await get('folder/files');
    return GetAllFiles.fromJson(response);
  }

  Future<List<User>> getAllUsers() async {
    final response = await get('auth/all/users');
    final List<dynamic> userList = response['detail'];
    return userList.map((userJson) => User.fromJson(userJson)).toList();
  }

  Future<void> shareItem({
    required String itemId,
    required String itemType,
    required List<String> sharedWithUserEmails,
    required List<String> actions,
  }) async {
    await post(
      'folder/$itemType/share',
      body: {
        'item_type': itemType,
        'item_id': itemId,
        'shared_with_user_emails': sharedWithUserEmails,
        'actions': actions,
      },
    );
  }

  /// 🔹 Handles API Response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body);
      case 400:
        throw Exception('Bad Request: ${response.body}');
      case 401:
        throw Exception('Unauthorized: ${response.body}');
      case 500:
        throw Exception('Server Error: ${response.body}');
      default:
        throw Exception('Unexpected error: ${response.statusCode}');
    }
  }
}
