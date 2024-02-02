import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VersionCheckApiService {
  Future<void> getHostAddress() async {
    final prefs = await SharedPreferences.getInstance();
    hostaddress = prefs.getString('hostaddress')!;
  }

  late String hostaddress;

  VersionCheckApiService() {
    getHostAddress(); // Fetch hostaddress once per instance
  }

//   functions for seperate api activities
  Future<String?> versionCheck() async {
    await getHostAddress();
    String? responseData;
    try {
      var url = Uri.https(hostaddress, '/version-apk');
      var response = await http.get(
        url,
      );

      if (response.statusCode == 200) {
        responseData = response.body.toString();
      } else {
        print('Request failed with status: ${response.statusCode}.');
        responseData = null;
      }
    } catch (e) {
      print('Error: $e');
      responseData = e.toString();
    }
    return responseData;
  }
}
