import "package:flutter/material.dart";
import "package:localhub/api/admin_service.dart";

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  Map<String, dynamic> _adminStatsJournal = {};
  final AdminService admin = AdminService();

  void _loadAdminStatsData() async {
    Map<String, dynamic> data = await admin.adminStatsData();

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
      body: SingleChildScrollView(
        child: (_adminStatsJournal.isEmpty)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
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
                  Text("popular communties:"),
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
                  Text("Active Posts:"),
                  Text(
                      "${_adminStatsJournal['post']['total_active_posts']}/${_adminStatsJournal['post']['total_posts']}"),
                  const SizedBox(
                    height: 40,
                  ),
                  ListView.builder(
                    itemCount: _adminStatsJournal['popularPost'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        child: Text(
                            "${_adminStatsJournal['popularPost'][index]["post_title"]} Post title ${_adminStatsJournal['popularPost'][index]["total_views"]}views ${_adminStatsJournal['popularPost'][index]["total_comments"]}comments ${_adminStatsJournal['popularPost'][index]["total_votes"]}votes"),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ListView.builder(
                    itemCount: _adminStatsJournal['adminLogs'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        child: Text(
                            "${_adminStatsJournal['adminLogs'][index]["log_event"]} \n ${_adminStatsJournal['adminLogs'][index]["log_description"]} \n ${_adminStatsJournal['adminLogs'][index]["created_at"]}"),
                      );
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
