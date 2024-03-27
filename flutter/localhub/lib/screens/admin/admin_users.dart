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
  String sortBy = "";
  bool order = true;

  void _loadData() async {
    if (!_hasMoreData) {
      return; // No more data to load
    }

    final List<Map<String, dynamic>> data = await aas.getAllUsersList(
      token: widget.token,
      offsetN: offset,
      sortby: sortBy,
      order: order ? "asc" : "desc",
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
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('User ID')),
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Avatar')),
                    DataColumn(label: Text('Created At')),
                    DataColumn(label: Text('Last Login')),
                    DataColumn(label: Text('Country')),
                    DataColumn(label: Text('State')),
                    DataColumn(label: Text('City')),
                    DataColumn(label: Text('Active')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Actions1')),
                    DataColumn(label: Text('Actions2')),
                  ],
                  rows: _journals.map<DataRow>((journal) {
                    return DataRow(cells: [
                      DataCell(Text(journal['user_id'].toString())),
                      DataCell(Text(journal['username'])),
                      DataCell(Text(journal['email'])),
                      DataCell(Text(journal['avatar_url'])),
                      DataCell(Text(journal['created_at'])),
                      DataCell(Text(journal['last_login'])),
                      DataCell(Text(journal['locality_country'])),
                      DataCell(Text(journal['locality_state'])),
                      DataCell(Text(journal['locality_city'])),
                      DataCell(Text(journal['active'].toString())),
                      DataCell(Text(journal['user_role'].toString())),
                      DataCell(ElevatedButton(
                        onPressed: () async {
                          await aas
                              .makeAdmin(
                            targetUserID: journal['user_id'],
                            token: widget.token,
                          )
                              .then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value['response'] ??
                                      value['error'] ??
                                      "Error",
                                ),
                              ),
                            );
                            _refreshData();
                          });
                        },
                        child: Text(
                          journal["user_role"] == 0
                              ? "Make Admin"
                              : "Make User",
                        ),
                      )),
                      DataCell(
                        ElevatedButton(
                          onPressed: () async {
                            await aas
                                .disableAccount(
                              targetUserID: journal['user_id'],
                              token: widget.token,
                            )
                                .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value['response'] ??
                                        value['error'] ??
                                        "Error",
                                  ),
                                ),
                              );
                              _refreshData();
                            });
                          },
                          child: Text(
                            journal["active"] == true ? "Disable" : "Activate",
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
