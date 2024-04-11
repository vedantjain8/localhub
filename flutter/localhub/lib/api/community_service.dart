import 'package:localhub/api/base_api_service.dart';

class CommunityApiService extends BaseApiService {
// get data like community name, banner, logo_url, community_description, created_at, active
  Future<Map<String, dynamic>> getCommunityData(
      {required int communityID}) async {
    return await makeMapGETRequest(endpoint: '/api/v1/community/$communityID');
  }

// get community posts data
  Future<List<Map<String, dynamic>>> getCommunityPost(
      {int offset = 0, required int communityID}) async {
    List<Map<String, dynamic>> responseData = [];
    try {
      var response = await makeMapPOSTRequest(
          endpoint: '/api/v1/community/posts',
          parameter: {'offset': '$offset'},
          body: {'community_id': '$communityID'});

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

  Future<List<Map<String, dynamic>>> getCommunityList(
      {String? communityName}) async {
    await getHostAddress();
    List<Map<String, dynamic>> responseData = [];
    try {
      var response = await makeMapGETRequest(
          endpoint: '/api/v1/search/community',
          parameter: {'communityName': '$communityName'});
      var jsonResponse = response["response"];
      if (jsonResponse is List) {
        // Check if jsonResponse is a List
        responseData = jsonResponse.cast<Map<String, dynamic>>().toList();
      } else {
        // Handle the case where jsonResponse is not a List
        // print('Unexpected response format: $jsonResponse');
        responseData = [
          {'error': 'Unexpected response format'}
        ];
      }
    } catch (e) {
      // print('Error: $e');
      responseData = [
        {'error': 'catch Request failed with status: $e'}
      ];
    }
    return responseData;
  }

  Future<Map<String, dynamic>> createCommunity({
    required String communityName,
    required String communityDescription,
    required String logoUrl,
    String? bannerUrl = "",
  }) async {
    await getUserToken();
    Map<String, dynamic> sendBody = {
      'community_name': "$communityName",
      'community_description': "$communityDescription",
      'token': "$token",
      'logo_url': "$logoUrl",
      'banner_url': "$bannerUrl"
    };

    return makeMapPOSTRequest(endpoint: '/api/v1/community', body: sendBody);
  }
}
