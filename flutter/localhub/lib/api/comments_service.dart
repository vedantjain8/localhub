import 'package:localhub/api/base_api_service.dart';

class CommentsApiService extends BaseApiService {
// get stats like total_votes, total_comments, total_views
  Future<List<Map<String, dynamic>>> getComments(
      {int offsetN = 0, required int postId}) async {
    await getHostAddress();
    List<Map<String, dynamic>> responseData = [];
    try {
      var response = await makeMapPOSTRequest(
          endpoint: '/api/v1/comments/posts',
          parameter: {'offset': '$offsetN'},
          body: {'post_id': '$postId'});

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

  Future<Map<String, dynamic>> createCommentById(
      {required int postID, required String commentContent}) async {
    Map<String, dynamic> sendBody = {
      'token': '$token',
      'post_id': '$postID',
      'comment_content': '$commentContent',
    };

    return await makeMapPOSTRequest(
        endpoint: '/api/v1/comments/create', body: sendBody);
  }

  Future<List<Map<String, dynamic>>> getUserPublishedComments(
      {int offsetN = 0}) async {
    await getUserToken();
    List<Map<String, dynamic>> responseData = [];
    try {
      var response = await makeMapPOSTRequest(
        endpoint: '/api/v1/comments/user',
        parameter: {'offset': '$offsetN'},
        body: {'token': '$token'},
      );

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

  // delete comment by comment id
  Future<Map<String, dynamic>> deleteCommentById({
    required int postId,
    required int commentId,
  }) async {
    await getUserToken();

    return await makeMapDELETERequest(
        endpoint: '/api/v1/comments/delete',
        body: {
          'token': '$token',
          'comment_id': '$commentId',
          'post_id': '$postId'
        });
  }
}
