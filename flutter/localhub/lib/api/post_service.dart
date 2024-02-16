import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostApiService {
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

  PostApiService() {
    getUserToken();
    getHostAddress(); // Fetch hostaddress once per instance
  }

//   functions for seperate api activities

// get post by postid
  Future<List<Map<String, dynamic>>> getPostById({required int postId}) async {
    await getHostAddress();
    await getUserToken();
    List<Map<String, dynamic>> responseData = [];
    try {
      var url = Uri.https(hostaddress, '/api/v1/posts/$postId');
      var response = await http.post(url, body: {'token': '${token}'});
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body)['response'];
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

// posts for user home screen filtered by none and order by created_at desc
  Future<List<Map<String, dynamic>>> getHomePost({int offsetN = 0}) async {
    await getHostAddress();
    List<Map<String, dynamic>> responseData = [];
    try {
      var url = Uri.https(hostaddress, '/api/v1/posts', {'offset': '$offsetN'});
      var response = await http.get(url);

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

  Future<List<Map<String, dynamic>>> getCommunityPost(
      {int offsetN = 0, required int subredditID}) async {
    List<Map<String, dynamic>> responseData = [];

    try {
      var url = Uri.https(hostaddress, '/api/v1/getSubredditPosts');
      var response = await http.post(url,
          body: {'offset': '$offsetN', 'subreddit_id': '$subredditID'});
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        jsonResponse = jsonResponse['response'];
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

  Future<Map<String, dynamic>> createNewPost({
    required String communityName,
    required String postTitle,
    String? postContent,
    String? imageUrl = "",
  }) async {
    await getHostAddress();
    await getUserToken();
    Map<String, dynamic> responseData = {};
    try {
      Map<String, dynamic> sendBody = {
        'post_title': "$postTitle",
        'post_content': "$postContent",
        'community_name': "$communityName",
        'post_image': "$imageUrl",
        'token': "$token",
      };
      var url = Uri.https(hostaddress, '/api/v1/posts');
      var response = await http.post(url, body: sendBody);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        responseData = jsonResponse['response'];
      } else {
        print('Request failed with status: ${response.statusCode}.');
        print(responseData);

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
