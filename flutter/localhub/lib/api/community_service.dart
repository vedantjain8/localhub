import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommunityApiService {
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

  CommunityApiService() {
    getHostAddress(); // Fetch hostaddress once per instance
    getUserToken();
  }

  Future<Map<String, dynamic>> getCommunityData(
      {required int communityID}) async {
    await getHostAddress();
    Map<String, dynamic> responseData = {};
    try {
      var url = Uri.https(hostaddress, '/api/v1/community/$communityID');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
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

  Future<List<Map<String, dynamic>>> getCommunityPost(
      {int offset = 0, required int communityID}) async {
    await getHostAddress();
    List<Map<String, dynamic>> responseData = [];
    try {
      var url = Uri.https(
          hostaddress, '/api/v1/community/posts', {'offset': '$offset'});
      var response =
          await http.post(url, body: {'community_id': '$communityID'});

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          // Check if jsonResponse is a List
          responseData = jsonResponse.cast<Map<String, dynamic>>().toList();
        } else {
          // Handle the case where jsonResponse is not a List
          responseData = [
            {'error': 'Unexpected response format'}
          ];
        }
      } else {
        responseData = [
          {'error': 'else Request failed with status: ${response.statusCode}'}
        ];
      }
    } catch (e) {
      responseData = [
        {'error': 'catch Request failed with status: $e'}
      ];
    }
    return responseData;
  }

  Future<List<Map<String, dynamic>>> getCommunityList(
      {String? communityName}) async {
    await getHostAddress();
    List<Map<String, dynamic>> responseData = [];
    try {
      var url = Uri.https(hostaddress, '/api/v1/community/search',
          {'communityName': '$communityName'});
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          // Check if jsonResponse is a List
          responseData = jsonResponse.cast<Map<String, dynamic>>().toList();
        } else {
          // Handle the case where jsonResponse is not a List
          print('Unexpected response format: $jsonResponse');
          responseData = [
            {'error': 'Unexpected response format'}
          ];
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');

        responseData = [
          {'error': 'else Request failed with status: ${response.statusCode}'}
        ];
      }
    } catch (e) {
      print('Error: $e');
      responseData = [
        {'error': 'catch Request failed with status: $e'}
      ];
    }
    return responseData;
  }
}
