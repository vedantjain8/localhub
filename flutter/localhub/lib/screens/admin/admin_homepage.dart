import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:localhub/api/admin_service.dart";
import "package:localhub/functions/datetimeoperations.dart";
import "package:localhub/screens/admin/admin_report_page.dart";
import "package:localhub/screens/admin/admin_users.dart";
import "package:localhub/screens/community/community_page.dart";
import "package:localhub/screens/post/post_page.dart";

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
      _adminStatsJournal = data['response'];
    });
  }

  @override
  void initState() {
    _loadAdminStatsData();
    super.initState();
  }

  Future<void> _onRefresh() async {
    _loadAdminStatsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Homepage"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.exit_to_app_rounded)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Admin Dashboard"),
            ),
            ListTile(
              title: const Text("Users"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AdminUsersPage(
                      token: widget.token,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Reports"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        AdminReportPage(token: widget.token)));
              },
            )
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: (_adminStatsJournal.isEmpty)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Users Overview',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DashboardCard(
                      title: 'Total Users',
                      value:
                          "${_adminStatsJournal['user']['active_users']} / ${_adminStatsJournal['user']['total_users']}",
                    ),
                    DashboardCard(
                      title: 'Total Admins',
                      value:
                          _adminStatsJournal['user']['total_admins'].toString(),
                    ),
                    DashboardCard(
                      title: 'Total Public Users',
                      value: _adminStatsJournal['user']['total_public_users']
                          .toString(),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Community Overview',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DashboardCard(
                      title: 'Total Active Communities',
                      value:
                          "${_adminStatsJournal['community']['total_active_communities']}",
                    ),
                    DashboardCard(
                      title: 'Total Communities',
                      value:
                          "${_adminStatsJournal['community']['total_communities']}",
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Popular Communities',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _adminStatsJournal['popularCommunity'].length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final community =
                            _adminStatsJournal['popularCommunity'];
                        return ListTile(
                          leading: Container(
                            height: 33,
                            width: 33,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    community[index]['logo_url']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(community[index]['community_name']),
                          subtitle: Text(
                              'Subscribers: ${community[index]['subscriber_count']}'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CommunityPage(
                                  communityID: community[index]['community_id'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Posts Overview',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DashboardCard(
                      title: 'Active Posts',
                      value:
                          "${_adminStatsJournal['post']['total_active_posts']}/${_adminStatsJournal['post']['total_posts']}",
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Popular Posts',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _adminStatsJournal['popularPost'].length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final post = _adminStatsJournal['popularPost'][index];
                        return ListTile(
                          title: Text(post['post_title']),
                          subtitle: Text(
                            '${post['total_views']} views • ${post['total_comments']} comments • ${post['total_votes']} votes',
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostPage(postID: post['post_id']),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Admin Logs',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(
                            label: Text('Event'),
                          ),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Created At')),
                        ],
                        rows:
                            _adminStatsJournal['adminLogs'].map<DataRow>((log) {
                          return DataRow(
                            cells: [
                              DataCell(Text(log['log_event'])),
                              DataCell(Text(log['log_description'])),
                              DataCell(Text(
                                  "${log['created_at']} \n ${timeAgo(log['created_at'].toString())}Ago")),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const DashboardCard({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
