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
    String? avatarurl,
    String? localitycity,
    String? localitystate,
    String? localitycountry,
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

    if (avatarurl != null || avatarurl != "") {
      sendBody['avatar_url'] = "$avatarurl";
    }

    if (localitycity != null || localitycity != "") {
      sendBody['locality_city'] = "$localitycity";
    }

    if (localitystate != null || localitystate != "") {
      sendBody['locality_state'] = "$localitystate";
    }

    if (localitycountry != null || localitycountry != "") {
      sendBody['locality_country'] = "$localitycountry";
    }
    return await makeMapPUTRequest(endpoint: '/api/v1/users', body: sendBody);
  }
}
