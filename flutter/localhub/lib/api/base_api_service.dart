import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseApiService {
  late String hostaddress;
  late String? token;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  BaseApiService() {
    getUserToken();
    getHostAddress();
  }

  Future<void> getHostAddress() async {
    final prefs = await SharedPreferences.getInstance();
    hostaddress = prefs.getString('hostaddress')!;
  }

  Future<void> getUserToken() async {
    token = await _storage.read(key: 'token');
  }

  Future<Map<String, dynamic>> makeMapPOSTRequest({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? parameter,
  }) async {
    await getHostAddress();
    Map<String, dynamic> jsonResponse = {};
    try {
      var url = Uri.https(hostaddress, endpoint, parameter);
      var response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body);
      } else {
        jsonResponse = {"error": jsonDecode(response.body)['response']};
      }
    } catch (e) {
      jsonResponse = {"error": e};
    }
    return jsonResponse;
  }

  Future<Map<String, dynamic>> makeMapPUTRequest({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? parameter,
  }) async {
    await getHostAddress();
    Map<String, dynamic> jsonResponse = {};
    try {
      var url = Uri.https(hostaddress, endpoint, parameter);
      var response = await http.put(url, body: body);

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body);
      } else {
        jsonResponse = {"error": jsonDecode(response.body)['response']};
      }
    } catch (e) {
      jsonResponse = {"error": e};
    }
    return jsonResponse;
  }

  Future<Map<String, dynamic>> makeMapDELETERequest({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? parameter,
  }) async {
    await getHostAddress();
    Map<String, dynamic> jsonResponse = {};
    try {
      var url = Uri.https(hostaddress, endpoint, parameter);
      var response = await http.delete(url, body: body);

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body);
      } else {
        jsonResponse = {"error": jsonDecode(response.body)['response']};
      }
    } catch (e) {
      jsonResponse = {"error": e};
    }
    return jsonResponse;
  }

  Future<Map<String, dynamic>> makeMapGETRequest({
    required String endpoint,
    Map<String, dynamic>? parameter,
  }) async {
    await getHostAddress();
    Map<String, dynamic> jsonResponse = {};
    try {
      var url = Uri.https(hostaddress, endpoint, parameter);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body);
      } else {
        jsonResponse = {"error": jsonDecode(response.body)['response']};
      }
    } catch (e) {
      jsonResponse = {"error": e};
    }
    return jsonResponse;
  }
}
