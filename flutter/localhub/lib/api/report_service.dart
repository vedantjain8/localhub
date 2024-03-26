import 'package:localhub/api/base_api_service.dart';

class ReportApiService extends BaseApiService {
//   functions for seperate api activities
  Future<Map<String, dynamic>> reportComment({
    required int commentID,
  }) async {
    Map<String, dynamic> sendBody = {
      'token': "$token",
      'comment_id': "$commentID",
    };

    return await makeMapPOSTRequest(
        endpoint: '/api/v1/report/comment', body: sendBody);
  }

  Future<Map<String, dynamic>> reportPost({
    required int postID,
  }) async {
    Map<String, dynamic> sendBody = {
      'token': "$token",
      'post_id': "$postID",
    };

    return await makeMapPOSTRequest(
        endpoint: '/api/v1/report/post', body: sendBody);
  }
}
