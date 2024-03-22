import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SearchApiService {
  Future<void> getHostAddress() async {
    final prefs = await SharedPreferences.getInstance();
    hostaddress = prefs.getString('hostaddress')!;
  }

  late String hostaddress;

  Future<Map<String, dynamic>> search({
    required String searchTerm,
  }) async {
    await getHostAddress();

    Map<String, dynamic> responseData = {};
    try {
      var url = Uri.https(
          hostaddress, '/api/v1/search', {'searchData': '$searchTerm'});
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        responseData = jsonResponse;
      } else {
        print('Request failed with status: ${response.statusCode}.');

        responseData = jsonDecode(response.body);
      }
    } catch (e) {
      print('Error: $e');
      responseData = {'error': 'catch Request failed with status: $e'};
    }
    return responseData;
  }
}
