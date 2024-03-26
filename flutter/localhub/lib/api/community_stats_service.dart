import 'package:localhub/api/base_api_service.dart';

class CommunityStatsApiService extends BaseApiService {
  Future<Map<String, dynamic>> getCommunityStats(
      {required int communityID}) async {
    await getHostAddress();
    return makeMapGETRequest(endpoint: '/api/v1/community/stats/$communityID');
  }

  Future<Map<String, dynamic>> checkCommunityJoinStatus(
      {required communityID}) async {
    Map<String, dynamic> sendBody = {
      "token": "$token",
      "community_id": "$communityID"
    };
    return await makeMapPOSTRequest(
        endpoint: '/api/v1/community/check/join', body: sendBody);
  }

  Future<Map<String, dynamic>> joinCommuntiy({required communityID}) async {
    await getUserToken();
    return await makeMapPOSTRequest(
        endpoint: '/api/v1/community/join',
        body: {"token": "$token", "community_id": "$communityID"});
  }

  Future<Map<String, dynamic>> leaveCommuntiy({required communityID}) async {
    await getUserToken();
    return await makeMapPOSTRequest(
        endpoint: '/api/v1/community/leave',
        body: {"token": "$token", "community_id": "$communityID"});
  }
}
