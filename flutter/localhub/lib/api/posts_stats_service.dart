import 'package:localhub/api/base_api_service.dart';

class PostStatsApiService extends BaseApiService {
// get stats like total_votes, total_comments, total_views
  Future<Map<String, dynamic>> getPostStats({
    required int postID,
  }) async {
    return await makeMapGETRequest(endpoint: '/api/v1/post/stats/$postID');
  }

  Future<Map<String, dynamic>> sendVote({
    required int postID,
    required bool upvote,
  }) async {
    if (upvote) {
      return makeMapPOSTRequest(
          endpoint: '/api/v1/posts/vote/upvote/$postID',
          body: {'token': '$token'});
    } else if (!upvote) {
      return makeMapPOSTRequest(
          endpoint: '/api/v1/posts/vote/downvote/$postID',
          body: {'token': '$token'});
    } else {
      return {"error": "Invalid vote"};
    }
  }
}
