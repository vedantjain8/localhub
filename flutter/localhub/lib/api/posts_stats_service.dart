import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostStatsApiService {
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

  PostStatsApiService() {
    getHostAddress(); // Fetch hostaddress once per instance
    getUserToken();
  }

// get stats like total_votes, total_comments, total_views
  Future<Map<String, dynamic>> getPostStats({
    required int postID,
  }) async {
    await getHostAddress();
    Map<String, dynamic> jsonResponse = {};
    try {
      var url = Uri.https(hostaddress, '/api/v1/post/stats/$postID');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body)['response'];
      }
    } catch (e) {
      rethrow;
    }
    return jsonResponse;
  }

  Future<Map<String, dynamic>> sendVote({
    required int postID,
    required bool upvote,
  }) async {
    await getHostAddress();
    Map<String, dynamic> jsonResponse = {};
    try {
      if (upvote) {
        var url = Uri.https(hostaddress, '/api/v1/posts/vote/upvote/$postID');
        var response = await http.post(url, body: {'token': '$token'});

        if (response.statusCode == 200) {
          jsonResponse = jsonDecode(response.body)['response'];
        }
      } else if (!upvote) {
        var url = Uri.https(hostaddress, '/api/v1/posts/vote/downvote/$postID');
        var response = await http.post(url, body: {'token': '$token'});

        if (response.statusCode == 200) {
          jsonResponse = jsonDecode(response.body);
        }
      }
    } catch (e) {
      rethrow;
    }
    return jsonResponse;
  }
}
