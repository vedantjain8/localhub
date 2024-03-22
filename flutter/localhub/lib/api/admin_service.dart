import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  Future<void> getHostAddress() async {
    final prefs = await SharedPreferences.getInstance();
    hostaddress = prefs.getString('hostaddress')!;
  }

  Future<void> getUserToken() async {
    token = await _storage.read(key: 'token');
  }

  late String hostaddress;
  late String? token;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AdminService() {
    getUserToken();
    getHostAddress(); // Fetch hostaddress once per instance
  }

//   functions for seperate api activities
  Future<Map<String, dynamic>> adminStatsData() async {
    await getHostAddress();
    await getUserToken();
    Map<String, dynamic> responseData = {};
    try {
      Map<String, dynamic> sendBody = {
        'token': "$token",
      };
      var url = Uri.https(hostaddress, '/api/admin/v1/stats');
      var response = await http.post(url, body: sendBody);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body)['response'];
        responseData = jsonResponse;
      } else {
        print('Request failed with status: ${response.statusCode}.');

        responseData = {'error': '${response.statusCode}'};
      }
    } catch (e) {
      print('Error: $e');
      responseData = {'error': 'catch Request failed with status: $e'};
    }
    return responseData;
  }
}
