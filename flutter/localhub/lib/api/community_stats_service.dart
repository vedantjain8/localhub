import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommunityStatsApiService {
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

  CommunityStatsApiService() {
    getHostAddress(); // Fetch hostaddress once per instance
  }

  Future<Map<String, dynamic>> getCommunityStats(
      {required int communityID}) async {
    await getHostAddress();
    Map<String, dynamic> jsonResponse = {};
    try {
      var url = Uri.https(hostaddress, '/api/v1/community/stats/$communityID');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body)['response'];
      }
    } catch (e) {
      rethrow;
    }
    return jsonResponse;
  }

  Future<Map<String, dynamic>> checkCommunityJoinStatus(
      {required communityID}) async {
    await getHostAddress();
    await getUserToken();
    Map<String, dynamic> jsonResponse = {};
    try {
      var url = Uri.https(hostaddress, '/api/v1/community/check/join');
      var response = await http.post(url,
          body: {"token": "$token", "community_id": "$communityID"});

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body)['response'];
      }
    } catch (e) {
      return {"response": e.toString()};
    }
    return jsonResponse;
  }

  Future<Map<String, dynamic>> joinCommuntiy(
      {required communityID}) async {
    await getHostAddress();
    await getUserToken();
    Map<String, dynamic> jsonResponse = {};
    try {
      var url = Uri.https(hostaddress, '/api/v1/community/join');
      var response = await http.post(url,
          body: {"token": "$token", "community_id": "$communityID"});

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body)['response'];
      }
    } catch (e) {
      return {"response": e.toString()};
    }
    return jsonResponse;
  }
  
  Future<Map<String, dynamic>> leaveCommuntiy(
      {required communityID}) async {
    await getHostAddress();
    await getUserToken();
    Map<String, dynamic> jsonResponse = {};
    try {
      var url = Uri.https(hostaddress, '/api/v1/community/leave');
      var response = await http.post(url,
          body: {"token": "$token", "community_id": "$communityID"});

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body)['response'];
      }
    } catch (e) {
      return {"response": e.toString()};
    }
    return jsonResponse;
  }
}
