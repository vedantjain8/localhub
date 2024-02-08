import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommunityStatsApiService {
  Future<void> getHostAddress() async {
    final prefs = await SharedPreferences.getInstance();
    hostaddress = prefs.getString('hostaddress')!;
  }

  late String hostaddress;

  CommunityStatsApiService() {
    getHostAddress(); // Fetch hostaddress once per instance
  }

  Future<Map<String, dynamic>> getCommunityStats({
    required int communityID
  }) async {
    await getHostAddress();
    Map<String, dynamic> jsonResponse = {};
    try {
      var url = Uri.https(hostaddress, '/api/v1/community/stats/$communityID');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
    return jsonResponse;
  }
}
