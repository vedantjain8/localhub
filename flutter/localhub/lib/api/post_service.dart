import 'package:localhub/api/base_api_service.dart';

class PostApiService extends BaseApiService {
// get post by postid
  Future<List<Map<String, dynamic>>> getPostById({required int postId}) async {
    await getUserToken();
    List<Map<String, dynamic>> responseData = [];
    try {
      var response = await makeMapPOSTRequest(
          endpoint: '/api/v1/posts/$postId', body: {'token': '$token'});

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

// delete post by postid
  Future<Map<String, dynamic>> deletePostById({required int postId}) async {
    await getUserToken();
    return await makeMapDELETERequest(
      endpoint: '/api/v1/posts/$postId',
      body: {'token': '$token'},
    );
  }

// posts for user home screen filtered by none and order by created_at desc
  Future<List<Map<String, dynamic>>> getExplorePost({int offsetN = 0}) async {
    List<Map<String, dynamic>> responseData = [];
    try {
      var response = await makeMapGETRequest(
          endpoint: '/api/v1/posts', parameter: {'offset': '$offsetN'});

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

  Future<List<Map<String, dynamic>>> getCommunityPost(
      {int offsetN = 0, required int subredditID}) async {
    List<Map<String, dynamic>> responseData = [];
    try {
      var response = await makeMapPOSTRequest(
          endpoint: '/api/v1/getSubredditPosts',
          body: {'offset': '$offsetN', 'subreddit_id': '$subredditID'});

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

  Future<Map<String, dynamic>> createNewPost({
    required String communityName,
    required String postTitle,
    String? postContent,
    String? imageUrl = "",
  }) async {
    await getUserToken();
    Map<String, dynamic> sendBody = {
      'post_title': "$postTitle",
      'post_content': "$postContent",
      'community_name': "$communityName",
      'post_image': "$imageUrl",
      'token': "$token",
    };

    return await makeMapPOSTRequest(endpoint: '/api/v1/posts', body: sendBody);
  }

  Future<Map<String, dynamic>> updatePost({
    required int postID,
    String? postTitle,
    String? postContent,
    String? imageUrl,
    bool? isadult,
    bool? active,
  }) async {
    Map<String, dynamic> sendBody = {
      'token': "$token",
    };

    if (postTitle == null && postContent == null && imageUrl == null) {
      return {'error': 'All fields are empty'};
    }

    if (postTitle != null || postTitle != "") {
      sendBody['post_title'] = "$postTitle";
    }
    if (postContent != null || postContent != "") {
      sendBody['post_content'] = "$postContent";
    }
    if (imageUrl != null || imageUrl != "") {
      sendBody['post_image'] = "$imageUrl";
    }

    return await makeMapPOSTRequest(
        endpoint: '/api/v1/posts/$postID', body: sendBody);
  }

  // get post published by user
  Future<List<Map<String, dynamic>>> getUserPublishedPost(
      {int offsetN = 0}) async {
    await getUserToken();
    List<Map<String, dynamic>> responseData = [];
    try {
      var response = await makeMapPOSTRequest(
          endpoint: '/api/v1/posts-by-user',
          parameter: {'offset': '$offsetN'},
          body: {'token': '$token'});

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

  Future<List<Map<String, dynamic>>> getUserJoinedPost(
      {int offsetN = 0}) async {
    List<Map<String, dynamic>> responseData = [];
    try {
      await getUserToken();
      var response = await makeMapPOSTRequest(
          endpoint: '/api/v1/getUserFeedPosts',
          parameter: {'offset': '$offsetN'},
          body: {'token': '$token'});
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
