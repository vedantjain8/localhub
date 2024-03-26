import 'package:flutter/material.dart';
import 'package:localhub/api/admin_service.dart';

class AdminUsersPage extends StatefulWidget {
  final String token;
  const AdminUsersPage({super.key, required this.token});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  int offset = 0;
  bool _hasMoreData = true;

  List<Map<String, dynamic>> _journals = [];
  final ScrollController _scrollController = ScrollController();

  final AdminService aas = AdminService();

  void _loadData() async {
    if (!_hasMoreData) {
      return; // No more data to load
    }

    final List<Map<String, dynamic>> data = await aas.getAllUsersList(
      token: widget.token,
      offsetN: offset,
    );

    if (data.isEmpty) {
      setState(() {
        _hasMoreData = false;
      });
      return;
    }

    setState(() {
      _journals = [..._journals, ...data];
      offset += 20;
    });

    if (data.length != 20) {
      setState(() {
        _hasMoreData = false;
      });
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadData();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _journals = [];
      offset = 0;
      _hasMoreData = true;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Users Page"),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(),
        child: _journals.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _journals.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Text(_journals[index]["user_id"].toString()),
                      Text(_journals[index]["username"]),
                      Text(_journals[index]["email"]),
                      Text(_journals[index]["avatar_url"]),
                      Text(_journals[index]["created_at"]),
                      Text(_journals[index]["last_login"]),
                      Text(_journals[index]["locality_country"]),
                      Text(_journals[index]["locality_state"]),
                      Text(_journals[index]["locality_city"]),
                      Text(_journals[index]["active"].toString()),
                      Text(_journals[index]["user_role"].toString()),
                      ElevatedButton(
                        onPressed: () async {
                          await aas
                              .makeAdmin(
                                  targetUserID: _journals[index]["user_id"],
                                  token: widget.token)
                              .then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(value['response'] ??
                                    value['error'] ??
                                    "error"),
                              ),
                            );
                            _refreshData();
                          });
                        },
                        child: Text(_journals[index]["user_role"] == 0
                            ? "make admin"
                            : "make user"),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            await aas
                                .disableAccount(
                                    targetUserID: _journals[index]["user_id"],
                                    token: widget.token)
                                .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value['response'] ??
                                      value['error'] ??
                                      "error"),
                                ),
                              );
                              _refreshData();
                            });
                          },
                          child: Text(_journals[index]["active"] == true
                              ? "disable"
                              : "activate")),
                      const SizedBox(
                        height: 80,
                      )
                    ],
                  );
                },
              ),
      ),
    );
  }
}
