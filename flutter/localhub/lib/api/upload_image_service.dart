import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ImageUploadService {
  Future<void> getHostAddress() async {
    final prefs = await SharedPreferences.getInstance();
    hostaddress = prefs.getString('hostaddress')!;
  }

  void getUserToken() async {
    token = await _storage.read(key: 'token');
  }

  late String hostaddress;
  late String? token;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ImageUploadService() {
    getHostAddress(); // Fetch hostaddress once per instance
    getUserToken();
  }

//   functions for seperate api activities

  Future<Map<String, dynamic>> uploadImageHTTP(file) async {
    var request =
        http.MultipartRequest('POST', Uri.https(hostaddress, '/upload'));
    request.files
        .add(await http.MultipartFile.fromPath('uploaded_file', file.path));
    if (token == null) {
      getUserToken();
    }
    request.fields['token'] = token!;
    var streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Response successful, return the response body
      return jsonDecode(response.body);
    } else {
      // Response not successful, throw an error or handle it accordingly
      throw Exception('Failed to upload image: ${response.reasonPhrase}');
    }
  }
}
