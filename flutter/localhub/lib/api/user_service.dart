import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserApiService {
  void getHostAddress() async {
    final prefs = await SharedPreferences.getInstance();
    hostaddress = prefs.getString('hostaddress')!; // Never null
  }

  late String hostaddress;

  UserApiService() {
    getHostAddress(); // Fetch hostaddress once per instance
  }

  Future<Map<String, dynamic>> httpRegisterFun({
    required String username,
    required String password,
    required String email,
    required String localityCountry,
    required String localityState,
    required String localityCity,
  }) async {
    Map<String, dynamic> jsonResponse = {};
    try {
      Map<String, dynamic> sendBody = {
        "username": "$username",
        "email": "$email",
        "password": "$password",
        "locality_country": "$localityCountry",
        "locality_state": "$localityState",
        "locality_city": "$localityCity",
      };
      var url = Uri.https(hostaddress, '/api/v1/users');
      var response = await http.post(url, body: sendBody);

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body);
      } else {
        throw "response code: ${response.statusCode}";
      }
    } catch (e) {
      jsonResponse = {"error on login": e};
    }
    return jsonResponse;
  }

  Future<Map<String, dynamic>> httpLoginFun({
    required String username,
    required String password,
  }) async {
    Map<String, dynamic> jsonResponse = {};
    try {
      Map<String, dynamic> sendBody = {
        'username': "$username",
        'password': "$password",
      };
      var url = Uri.https(hostaddress, '/api/v1/login');
      var response = await http.post(url, body: sendBody);

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
    return jsonResponse;
  }
  
  Future<Map<String, dynamic>> httpAdminLoginFun({
    required String username,
    required String password,
  }) async {
    Map<String, dynamic> jsonResponse = {};
    try {
      Map<String, dynamic> sendBody = {
        'username': "$username",
        'password': "$password",
      };
      var url = Uri.https(hostaddress, '/api/admin/v1/login');
      var response = await http.post(url, body: sendBody);

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
    return jsonResponse;
  }
}
