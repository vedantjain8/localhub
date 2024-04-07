import 'package:flutter/material.dart';
import 'package:localhub/api/base_api_service.dart';
import 'package:http/http.dart' as http;

class ContentPolicyScreen extends StatefulWidget {
  final String toLoad;
  const ContentPolicyScreen({super.key, required this.toLoad});

  @override
  State<ContentPolicyScreen> createState() => _ContentPolicyScreenState();
}

class Policy extends BaseApiService {
  Future<String> makeGETRequest({
    required String endpoint,
  }) async {
    await getHostAddress();
    String response = "";
    try {
      var url = Uri.https(hostaddress, endpoint);
      var apiresponse = await http.get(url);
      response = apiresponse.body;
    } catch (e) {
      response = e.toString();
    }
    return response;
  }
}

class _ContentPolicyScreenState extends State<ContentPolicyScreen> {
  String text = "";
  final Policy pas = Policy();

  void loadData() async {
    await pas
        .makeGETRequest(endpoint: widget.toLoad.toLowerCase())
        .then((value) => setState(() {
              text = value.toString();
            }));
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.toLoad.contains("-")
            ? widget.toLoad.split("-").join(" ")
            : widget.toLoad),
      ),
      body: text.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(child: Text(text)),
    );
  }
}
