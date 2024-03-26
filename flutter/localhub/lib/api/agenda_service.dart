import 'package:localhub/api/base_api_service.dart';

class AgendaApiService extends BaseApiService {
//   functions for seperate api activities
  Future<List<Map<String, dynamic>>> getAgendaList({int offsetN = 0}) async {
    List<Map<String, dynamic>> responseData = [];
    try {
      var response = await makeMapGETRequest(
          endpoint: '/api/v1/agendas', parameter: {'offset': '$offsetN'});

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
