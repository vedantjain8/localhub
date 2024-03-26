import 'package:localhub/api/base_api_service.dart';

class UserApiService extends BaseApiService {
  Future<Map<String, dynamic>> httpRegisterFun({
    required String username,
    required String password,
    required String email,
    required String localityCountry,
    required String localityState,
    required String localityCity,
  }) async {
    Map<String, dynamic> sendBody = {
      "username": "$username",
      "email": "$email",
      "password": "$password",
      "locality_country": "$localityCountry",
      "locality_state": "$localityState",
      "locality_city": "$localityCity",
    };

    return await makeMapPOSTRequest(endpoint: "/api/v1/users", body: sendBody);
  }

  Future<Map<String, dynamic>> httpLoginFun({
    required String username,
    required String password,
  }) async {
    Map<String, dynamic> sendBody = {
      'username': "$username",
      'password': "$password",
    };

    return await makeMapPOSTRequest(endpoint: "/api/v1/login", body: sendBody);
  }

  Future<Map<String, dynamic>> httpAdminLoginFun({
    required String username,
    required String password,
  }) async {
    Map<String, dynamic> sendBody = {
      'username': "$username",
      'password': "$password",
    };

    return await makeMapPOSTRequest(
        endpoint: "/api/admin/v1/login", body: sendBody);
  }
}
