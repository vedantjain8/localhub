import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  Future<void> getHostAddress() async {
    final prefs = await SharedPreferences.getInstance();
    hostaddress = prefs.getString('hostaddress')!;
  }

  late String hostaddress;

  AdminService() {
    getHostAddress(); // Fetch hostaddress once per instance
  }

//   functions for seperate api activities
  Future<Map<String, dynamic>> adminStatsData({required String token}) async {
    await getHostAddress();
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

  Future<Map<String, dynamic>> makeAdmin({
    required int targetUserID,
    required String token,
  }) async {
    await getHostAddress();
    Map<String, dynamic> responseData = {};
    try {
      Map<String, dynamic> sendBody = {
        'token': "$token",
        'new_admin_user_id': "$targetUserID",
      };
      var url = Uri.https(hostaddress, '/api/admin/v1/admin/makeadmin');
      var response = await http.post(url, body: sendBody);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
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
  
  Future<Map<String, dynamic>> disableAccount({
    required int targetUserID,
    required String token,
  }) async {
    await getHostAddress();
    Map<String, dynamic> responseData = {};
    try {
      Map<String, dynamic> sendBody = {
        'token': "$token",
        'target_user_id': "$targetUserID",
      };
      var url = Uri.https(hostaddress, '/api/admin/v1/users/disable');
      var response = await http.post(url, body: sendBody);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
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

  Future<List<Map<String, dynamic>>> getAllUsersList({
    int offsetN = 0,
    String? sortby,
    String? order,
    required String token,
  }) async {
    await getHostAddress();
    List<Map<String, dynamic>> responseData = [];
    try {
      var url = Uri.https(
          hostaddress, '/api/admin/v1/users/list', {'offset': '$offsetN'});
      var response = await http.post(url, body: {
        "token": "${token}",
        if (sortby != null) "sort": "${sortby}",
        if (order != null) "order": "${order}"
      });

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
  Future<List<Map<String, dynamic>>> getReportedPosts({
    int offsetN = 0,
    required String token,
  }) async {
    await getHostAddress();
    List<Map<String, dynamic>> responseData = [];
    try {
      var url = Uri.https(
          hostaddress, '/api/admin/v1/posts/list', {'offset': '$offsetN'});
      var response = await http.post(url, body: {
        "token": "${token}",
      });

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
  Future<List<Map<String, dynamic>>> getReportedComments({
    int offsetN = 0,
    required String token,
  }) async {
    await getHostAddress();
    List<Map<String, dynamic>> responseData = [];
    try {
      var url = Uri.https(
          hostaddress, '/api/admin/v1/comments/list', {'offset': '$offsetN'});
      var response = await http.post(url, body: {
        "token": "${token}",
      });

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
}
