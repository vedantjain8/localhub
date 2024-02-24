import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportApiService {
  Future<void> getHostAddress() async {
    final prefs = await SharedPreferences.getInstance();
    hostaddress = prefs.getString('hostaddress')!;
  }

  void getUserToken() async {
    token = await _storage.read(key: 'token');
  }

  late String hostaddress;
  late String? token;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ReportApiService() {
    getHostAddress(); // Fetch hostaddress once per instance
    getUserToken();
  }

//   functions for seperate api activities
  Future<Map<String, dynamic>> reportComment({
    required int commentID,
  }) async {
    await getHostAddress();
    Map<String, dynamic> responseData = {};
    try {
      Map<String, dynamic> sendBody = {
        'token': "$token",
        'comment_id': "$commentID",
      };
      var url = Uri.https(hostaddress, '/api/v1/report/comment');
      var response = await http.post(url, body: sendBody);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body)['response'];
        responseData = jsonResponse;
      } else {
        print('Request failed with status: ${response.statusCode}.');

        responseData = {
          'error': 'else Request failed with status: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error: $e');
      responseData = {'error': 'catch Request failed with status: $e'};
    }
    return responseData;
  }

  Future<Map<String, dynamic>> reportPost({
    required int postID,
  }) async {
    Map<String, dynamic> responseData = {};
    String? token = await _storage.read(key: 'token');
    try {
      Map<String, dynamic> sendBody = {
        'token': "$token",
        'post_id': "$postID",
      };
      var url = Uri.https(hostaddress, '/api/v1/report/post');
      var response = await http.post(url, body: sendBody);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body)['response'];
        responseData = jsonResponse;
      } else {
        print('Request failed with status: ${response.statusCode}.');

        responseData = {
          'error': 'else Request failed with status: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error: $e');
      responseData = {'error': 'catch Request failed with status: $e'};
    }
    return responseData;
  }
}
