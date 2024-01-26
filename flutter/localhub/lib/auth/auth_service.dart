import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localhub/api/user_service.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final UserApiService apiService = UserApiService();

  Future<bool> isAuthenticated() async {
    String? token = await _storage.read(key: 'token');
    return token != null;
  }

  Future<String> returnToken() async {
    String token = await _storage.read(key: 'token') ?? "null";
    return token;
  }

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String localityCountry,
    required String localityState,
    required String localityCity,
  }) async {
    try {
      Map<String, dynamic> httpRegisterResult =
          await apiService.httpRegisterFun(
        username: username,
        password: password,
        email: email,
        localityCity: localityCity,
        localityCountry: localityCountry,
        localityState: localityState,
      );

      String token = httpRegisterResult['token'];

      return token; // Return the token to the caller
    } catch (error) {
      // Handle registration failure
      print('Registration failed: $error');
      return null; // Rethrow the error for the caller to handle
    }
  }

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    try {
      // Perform authentication and get the token
      Map<String, dynamic> httpLoginResult = await apiService.httpLoginFun(
        username: username,
        password: password,
      );

      if (httpLoginResult['token'] == null) {
        return null;
      }
      String token = httpLoginResult['token'];

      // Store the token securely
      await _storage.write(key: 'token', value: token);

      return token; // Return the token to the caller
    } catch (error) {
      return null; 
    }
  }

  // Method to perform logout and remove the token
  Future<void> logout() async {
    // Perform any logout logic if needed
    // ...

    // Remove the stored token
    await _storage.delete(key: 'token');
  }
}
