import 'package:flutter/material.dart';
import 'package:localhub/api/admin_service.dart';

class AdminReportPage extends StatefulWidget {
  final String token;
  const AdminReportPage({super.key, required this.token});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService aas = AdminService();

  int offsetPosts = 0;
  bool _hasMoreDataPosts = true;
  List<Map<String, dynamic>> _journalsPosts = [];
  final ScrollController _scrollControllerPosts = ScrollController();

  int offsetComments = 0;
  bool _hasMoreDataComments = true;
  List<Map<String, dynamic>> _journalsComments = [];
  final ScrollController _scrollControllerComments = ScrollController();

  void _loadReportedPostsData() async {
    if (!_hasMoreDataPosts) {
      return; // No more data to load
    }

    final List<Map<String, dynamic>> data = await aas.getReportedPosts(
      token: widget.token,
      offsetN: offsetPosts,
    );

    if (data.isEmpty) {
      setState(() {
        _hasMoreDataPosts = false;
      });
      return;
    }

    setState(() {
      _journalsPosts = [..._journalsPosts, ...data];
      offsetPosts += 20;
    });

    if (data.length != 20) {
      setState(() {
        _hasMoreDataPosts = false;
      });
      return;
    }
  }

  void _loadReportedCommentsData() async {
    if (!_hasMoreDataComments) {
      return; // No more data to load
    }

    final List<Map<String, dynamic>> data = await aas.getReportedComments(
      token: widget.token,
      offsetN: offsetComments,
    );

    if (data.isEmpty) {
      setState(() {
        _hasMoreDataComments = false;
      });
      return;
    }

    setState(() {
      _journalsComments = [..._journalsComments, ...data];
      offsetComments += 20;
    });

    if (data.length != 20) {
      setState(() {
        _hasMoreDataComments = false;
      });
      return;
    }
  }

  final _tabs = const [
    Tab(text: 'Posts'),
    Tab(text: 'Comments'),
  ];

  @override
  void initState() {
    super.initState();
    _loadReportedPostsData();
    _loadReportedCommentsData();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollControllerPosts.addListener(() {
      if (_scrollControllerPosts.position.pixels ==
          _scrollControllerPosts.position.maxScrollExtent) {
        _loadReportedPostsData();
      }
    });
    _scrollControllerComments.addListener(() {
      if (_scrollControllerComments.position.pixels ==
          _scrollControllerComments.position.maxScrollExtent) {
        _loadReportedCommentsData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Report Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: colorScheme.onInverseSurface,
                    borderRadius: BorderRadius.circular(30)),
                child: TabBar(
                  overlayColor:
                      const MaterialStatePropertyAll(Colors.transparent),
                  tabs: _tabs,
                  controller: _tabController,
                  unselectedLabelColor: colorScheme.primary,
                  labelColor: colorScheme.background,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(80.0),
                    color: colorScheme.primary,
                  ),
                  dividerColor: Colors.transparent,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _journalsPosts.isNotEmpty
                      ? ListView.builder(itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_journalsPosts[index]['post_title']),
                            subtitle: Text(
                                "Post ID: ${_journalsPosts[index]['post_id']} at ${_journalsPosts[index]['report_time']}"),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // TODO: add post delete button functionality
                              },
                              child: Text(
                                  _journalsPosts[index]['active'] == true
                                      ? "Delete"
                                      : "Restore"),
                            ),
                          );
                        })
                      : const Center(child: CircularProgressIndicator()),
                  _journalsComments.isNotEmpty
                      ? ListView.builder(itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_journalsComments[index]['post_title']),
                            subtitle: Text(
                                "Comment ID: ${_journalsComments[index]['comment_id']} at ${_journalsComments[index]['report_time']}"),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // TODO: add post delete button functionality
                              },
                              child: Text(
                                  _journalsComments[index]['active'] == true
                                      ? "Delete"
                                      : "Restore"),
                            ),
                          );
                        })
                      : const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}
