import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommentsApiService {
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

  CommentsApiService() {
    getHostAddress(); // Fetch hostaddress once per instance
    getUserToken();
  }

// get stats like total_votes, total_comments, total_views
  Future<List<Map<String, dynamic>>> getComments(
      {int offsetN = 0, required int postId}) async {
    await getHostAddress();
    List<Map<String, dynamic>> responseData = [];
    try {
      var url = Uri.https(
          hostaddress, '/api/v1/getpostcomment', {'offset': '$offsetN'});
      var response = await http.post(url, body: {'post_id': '$postId'});

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        jsonResponse = jsonResponse['response'];
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

  Future<Map<String, dynamic>> createCommentById(
      {required int postID, required String commentContent}) async {
    Map<String, dynamic> jsonResponse = {};
    try {
      Map<String, dynamic> sendBody = {
        'token': '$token',
        'post_id': '$postID',
        'comment_content': '$commentContent',
      };
      var url = Uri.https(hostaddress, '/api/v1/createComment/');
      var response = await http.post(url, body: sendBody);

      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body)['response'];
      }
    } catch (e) {
      jsonResponse = {"error creating comment": e};
    }
    return jsonResponse;
  }
}
