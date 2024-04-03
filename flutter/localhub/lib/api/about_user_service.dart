import 'package:localhub/api/base_api_service.dart';

class AboutUserApiService extends BaseApiService {
//   functions for seperate api activities
  Future<Map<String, dynamic>> aboutUserData() async {
    await getUserToken();

    return await makeMapPOSTRequest(endpoint: '/api/v1/me', body: {
      'token': "$token",
    });
  }

  Future<Map<String, dynamic>> updateUser({
    required password,
    String? username,
    String? bio,
    String? avatar_url,
    String? locality_city,
    String? locality_state,
    String? locality_country,
  }) async {
    await getUserToken();

    Map<String, dynamic> sendBody = {
      'token': '$token',
      'password': '$password',
    };

    if (username != null) {
      sendBody['username'] = "$username";
    }

    if (bio != null || bio != "") {
      sendBody['bio'] = "$bio";
    }

    if (avatar_url != null || avatar_url != "") {
      sendBody['avatar_url'] = "$avatar_url";
    }

    if (locality_city != null || locality_city != "") {
      sendBody['locality_city'] = "$locality_city";
    }

    if (locality_state != null || locality_state != "") {
      sendBody['locality_state'] = "$locality_state";
    }

    if (locality_country != null || locality_country != "") {
      sendBody['locality_country'] = "$locality_country";
    }
    return await makeMapPUTRequest(endpoint: '/api/v1/users', body: sendBody);
  }
}
