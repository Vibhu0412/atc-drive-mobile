import 'dart:convert';

import 'package:get_storage/get_storage.dart';

class StorageService {
  static final GetStorage _storage = GetStorage();

  // Keys
  static const String _userKey = 'loggedInUser';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Save user data to storage
  static void saveUserData(dynamic user) {
    _storage.write(_userKey, jsonEncode(user));
  }

  // Get user data from storage
  static Map<String, dynamic>? getUserData() {
    final data = _storage.read(_userKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // Remove user data from storage
  static void clearUserData() {
    _storage.remove(_userKey);
  }

  // Check if user is logged in
  static bool isUserLoggedIn() {
    return _storage.hasData(_userKey);
  }

  // Save access token
  static void saveAccessToken(String token) {
    _storage.write(_accessTokenKey, token);
  }

  // Get access token
  static String? getAccessToken() {
    return _storage.read(_accessTokenKey);
  }

  // Save refresh token
  static void saveRefreshToken(String token) {
    _storage.write(_refreshTokenKey, token);
  }

  // Get refresh token
  static String? getRefreshToken() {
    return _storage.read(_refreshTokenKey);
  }

  // Clear all tokens
  static void clearTokens() {
    _storage.remove(_accessTokenKey);
    _storage.remove(_refreshTokenKey);
  }

  // Clear all user-related data (user data + tokens)
  static void clearAll() {
    clearUserData();
    clearTokens();
  }
}
