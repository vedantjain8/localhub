import 'package:localhub/api/base_api_service.dart';

class AboutUserApiService extends BaseApiService {
//   functions for seperate api activities
  Future<Map<String, dynamic>> aboutUserData() async {
    await getUserToken();

    return await makeMapPOSTRequest(endpoint: '/api/v1/me', body: {
      'token': "$token",
    });
  }
}
