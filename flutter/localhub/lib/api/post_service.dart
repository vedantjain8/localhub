import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostApiService {
  Future<void> getHostAddress() async {
    final prefs = await SharedPreferences.getInstance();
    hostaddress = prefs.getString('hostaddress')!;
  }

  late String hostaddress;

  PostApiService() {
    getHostAddress(); // Fetch hostaddress once per instance
  }

//   functions for seperate api activities

// get post by postid
  Future<List<Map<String, dynamic>>> getPostById({required int postId}) async {
    await getHostAddress();
    List<Map<String, dynamic>> responseData = [];
    try {
      var url = Uri.https(hostaddress, '/api/v1/posts/$postId');
      var response = await http.get(url);
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

// posts for user home screen filtered by none and order by created_at desc
  Future<List<Map<String, dynamic>>> getHomePost({int offsetN = 0}) async {
    await getHostAddress();
    List<Map<String, dynamic>> responseData = [];
    try {
      var url = Uri.https(hostaddress, '/api/v1/posts', {'offset': '$offsetN'});
      var response = await http.get(url);

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

  Future<List<Map<String, dynamic>>> getCommunityPost(
      {int offsetN = 0, required int subredditID}) async {
    List<Map<String, dynamic>> responseData = [];

    try {
      var url = Uri.https(hostaddress, '/api/v1/getSubredditPosts');
      var response = await http.post(url,
          body: {'offset': '$offsetN', 'subreddit_id': '$subredditID'});
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
