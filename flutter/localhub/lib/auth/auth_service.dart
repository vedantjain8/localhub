import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class AuthService{
    

    final _storage = const FlutterSecureStorage();

    Future<bool> isAuthenticated() async {
    String? token = await _storage.read(key: 'token');
    return token != null;
  }

  Future<String> returnToken() async {
    String token = await _storage.read(key: 'token') ?? "null";
    return token;
  }
}