import "package:flutter/material.dart";
import "package:localhub/api/admin_service.dart";
import "package:localhub/screens/admin/admin_report_page.dart";
import "package:localhub/screens/admin/admin_users.dart";

class AdminHomepage extends StatefulWidget {
  final String token;
  const AdminHomepage({super.key, required this.token});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  Map<String, dynamic> _adminStatsJournal = {};
  final AdminService admin = AdminService();

  void _loadAdminStatsData() async {
    Map<String, dynamic> data = await admin.adminStatsData(token: widget.token);

    setState(() {
      _adminStatsJournal = data;
    });
  }

  @override
  void initState() {
    _loadAdminStatsData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Homepage"),
      ),
      body: SingleChildScrollView(
        child: (_adminStatsJournal.isEmpty)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AdminUsersPage(
                              token: widget.token,
                            ),
                          ),
                        );
                      },
                      child: const Text("users page")),
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AdminReportPage(
                              token: widget.token,
                            ),
                          ),
                        );
                      },
                      child: const Text("report page")),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text("Users:"),
                  const Text("Total Users:"),
                  Text(
                      "${_adminStatsJournal['user']['active_users']} / ${_adminStatsJournal['user']['total_users']}"),
                  const Text("Total admins:"),
                  Text(_adminStatsJournal['user']['total_admins']),
                  const Text("Total public users:"),
                  Text(_adminStatsJournal['user']['total_public_users']),
                  const Text("Total Users:"),
                  Text(_adminStatsJournal['user']['total_public_users']),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text("Community:"),
                  Text(
                      " ${_adminStatsJournal['community']['total_active_communities']}/${_adminStatsJournal['community']['total_communities']}"),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text("popular communties:"),
                  ListView.builder(
                    itemCount: _adminStatsJournal['popularCommunity'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Text(_adminStatsJournal['popularCommunity'][index]
                              ["community_name"] +
                          _adminStatsJournal['popularCommunity'][index]
                                  ["subscriber_count"]
                              .toString());
                    },
                  ),
                  const Text("Active Posts:"),
                  Text(
                      "${_adminStatsJournal['post']['total_active_posts']}/${_adminStatsJournal['post']['total_posts']}"),
                  const SizedBox(
                    height: 40,
                  ),
                  ListView.builder(
                    itemCount: _adminStatsJournal['popularPost'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Text(
                          "${_adminStatsJournal['popularPost'][index]["post_title"]} Post title ${_adminStatsJournal['popularPost'][index]["total_views"]}views ${_adminStatsJournal['popularPost'][index]["total_comments"]}comments ${_adminStatsJournal['popularPost'][index]["total_votes"]}votes");
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ListView.builder(
                    itemCount: _adminStatsJournal['adminLogs'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Text(
                          "${_adminStatsJournal['adminLogs'][index]["log_event"]} \n ${_adminStatsJournal['adminLogs'][index]["log_description"]} \n ${_adminStatsJournal['adminLogs'][index]["created_at"]}");
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(_adminStatsJournal['reportPost'].toString()),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(_adminStatsJournal['reportComment'].toString()),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(_adminStatsJournal.toString()),
                ],
              ),
      ),
    );
  }
}
