import 'package:localhub/api/base_api_service.dart';

class SearchApiService extends BaseApiService {
  Future<Map<String, dynamic>> search({
    required String searchTerm,
  }) async {
    return await makeMapGETRequest(
        endpoint: "/api/v1/search", parameter: {'searchData': '$searchTerm'});
  }
}
