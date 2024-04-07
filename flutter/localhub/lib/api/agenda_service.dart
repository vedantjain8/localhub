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

  Future<Map<String, dynamic>> createAgenda({
    required String agendaTitle,
    String? agendaDescription,
    String? imageUrl,
    required String localityCity,
    required String localityState,
    required String localityCountry,
    required DateTime agendaStartDate,
    required DateTime agendaEndDate,
  }) async {
    await getUserToken();
    Map<String, dynamic> sendBody = {
      'token': '${token}',
      'agenda_title': '${agendaTitle}',
      'agenda_description': '${agendaDescription}',
      'image_url': '${imageUrl}',
      'locality_city': '${localityCity}',
      'locality_state': '${localityState}',
      'locality_country': '${localityCountry}',
      'agenda_start_date': '${agendaStartDate.toIso8601String()}',
      'agenda_end_date': '${agendaEndDate.toIso8601String()}',
    };

    return await makeMapPOSTRequest(
        endpoint: '/api/v1/agendas/create', body: sendBody);
  }

  // Future<List<Map<String, dynamic>>> getAgendaById(
  //     {required int agendaId}) async {
  //   await getUserToken();
  //   List<Map<String, dynamic>> responseData = [];
  //   try {
  //     var response = await makeMapGETRequest(
  //         endpoint: '/api/v1/agendas?offset=1/$agendaId');
  //     var jsonResponse = response['response'];
  //     if (jsonResponse is List) {
  //       // Check if jsonResponse is a List
  //       responseData = jsonResponse.cast<Map<String, dynamic>>().toList();
  //     } else {
  //       // Handle the case where jsonResponse is not a List
  //       responseData = [
  //         {'error': 'Unexpected response format'}
  //       ];
  //     }
  //   } catch (e) {
  //     responseData = [
  //       {'error': 'catch Request failed with status: $e'}
  //     ];
  //   }
  //   return responseData;
  // }

  Future<List<Map<String, dynamic>>> getAgendaById(
      {required int agendaId}) async {
    await getUserToken();
    List<Map<String, dynamic>> responseData = [];
    try {
      var response =
          await makeMapGETRequest(endpoint: '/api/v1/agendas/$agendaId');

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
