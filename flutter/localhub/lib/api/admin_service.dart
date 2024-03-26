import 'package:localhub/api/base_api_service.dart';

class AdminService extends BaseApiService {
//   functions for seperate api activities
  Future<Map<String, dynamic>> adminStatsData({required String token}) async {
    return await makeMapPOSTRequest(endpoint: '/api/admin/v1/stats', body: {
      'token': "$token",
    });
  }

  Future<Map<String, dynamic>> makeAdmin({
    required int targetUserID,
    required String token,
  }) async {
    Map<String, dynamic> sendBody = {
      'token': "$token",
      'new_admin_user_id': "$targetUserID",
    };

    return await makeMapPOSTRequest(
        endpoint: '/api/admin/v1/admin/makeadmin', body: sendBody);
  }

  Future<Map<String, dynamic>> disableAccount({
    required int targetUserID,
    required String token,
  }) async {
    Map<String, dynamic> sendBody = {
      'token': "$token",
      'target_user_id': "$targetUserID",
    };

    return await makeMapPOSTRequest(
        endpoint: '/api/admin/v1/users/disable', body: sendBody);
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
      var response = await makeMapPOSTRequest(
          endpoint: '/api/admin/v1/users/list',
          parameter: {
            'offset': '$offsetN'
          },
          body: {
            "token": "${token}",
            if (sortby != null) "sort": "${sortby}",
            if (order != null) "order": "${order}"
          });

      var jsonResponse = response['response'];
      if (jsonResponse is List) {
        // Check if jsonResponse is a List
        responseData = jsonResponse.cast<Map<String, dynamic>>().toList();
      } else {
        // Handle the case where jsonResponse is not a List
        responseData = [
          {'error': 'Unexpected response format'}
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
    List<Map<String, dynamic>> responseData = [];
    try {
      var response = await makeMapPOSTRequest(
          endpoint: '/api/admin/v1/posts/list',
          parameter: {
            'offset': '$offsetN'
          },
          body: {
            "token": "${token}",
          });

      var jsonResponse = response['response'];
      if (jsonResponse is List) {
        // Check if jsonResponse is a List
        responseData = jsonResponse.cast<Map<String, dynamic>>().toList();
      } else {
        // Handle the case where jsonResponse is not a List
        responseData = [
          {'error': 'Unexpected response format'}
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
    List<Map<String, dynamic>> responseData = [];
    try {
      var response = await makeMapPOSTRequest(
          endpoint: '/api/admin/v1/comments/list',
          parameter: {
            'offset': '$offsetN'
          },
          body: {
            "token": "${token}",
          });

      var jsonResponse = response['response'];
      if (jsonResponse is List) {
        // Check if jsonResponse is a List
        responseData = jsonResponse.cast<Map<String, dynamic>>().toList();
      } else {
        // Handle the case where jsonResponse is not a List
        responseData = [
          {'error': 'Unexpected response format'}
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
