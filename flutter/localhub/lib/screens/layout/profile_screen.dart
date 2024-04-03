import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/api/about_user_service.dart';
import 'package:localhub/api/comments_service.dart';
import 'package:localhub/api/post_service.dart';
import 'package:localhub/screens/layout/edit_profile_screen.dart';
import 'package:localhub/widgets/custom_comment_list_view_builder_widget.dart';
import 'package:localhub/widgets/custom_post_card_widget.dart';
import 'package:localhub/widgets/custom_shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool hasMoreDataPosts = true;
  int offsetPosts = 0;

  bool hasMoreDataComments = true;
  int offsetComments = 0;

  List<Map<String, dynamic>> postJournals = [];
  List<Map<String, dynamic>> commentsJournals = [];
  Map<String, dynamic> meJournal = {};

  final PostApiService pas = PostApiService();
  final AboutUserApiService auas = AboutUserApiService();
  final CommentsApiService cas = CommentsApiService();

  void _loadPostData() async {
    if (!hasMoreDataPosts) {
      return; // No more data to load
    }

    final List<Map<String, dynamic>> data = await pas.getUserPublishedPost(
      offsetN: offsetPosts,
    );

    if (data.isEmpty) {
      setState(() {
        hasMoreDataPosts = false;
      });
      return;
    }

    setState(() {
      postJournals = [...postJournals, ...data];
      offsetPosts += 20;
    });

    if (data.length != 20) {
      setState(() {
        hasMoreDataPosts = false;
      });
      return;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      postJournals = [];
      commentsJournals = [];
      offsetPosts = 0;
      offsetComments = 0;
      hasMoreDataPosts = true;
      hasMoreDataComments = true;
    });
    _loadPostData();
    _loadCommentData();
  }

  void _loadCommentData() async {
    if (!hasMoreDataComments) {
      return; // No more data to load
    }

    final List<Map<String, dynamic>> data = await cas.getUserPublishedComments(
      offsetN: offsetComments,
    );

    if (data.isEmpty) {
      setState(() {
        hasMoreDataComments = false;
      });
      return;
    }

    setState(() {
      commentsJournals = [...commentsJournals, ...data];
      offsetComments += 20;
    });

    if (data.length != 20) {
      setState(() {
        hasMoreDataComments = false;
      });
      return;
    }
  }

  void _loadMeData() async {
    Map<String, dynamic> data = await auas.aboutUserData();
    setState(() {
      meJournal = data['response'];
    });
  }

  late TabController _tabController;

  final _tabs = const [
    Tab(text: 'Posts'),
    Tab(text: 'Comments'),
  ];

  @override
  void initState() {
    super.initState();
    _loadPostData();
    _loadCommentData();
    _loadMeData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refreshData(),
        child: SingleChildScrollView(
          child: meJournal.isEmpty
              ? const CustomShimmer()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: CachedNetworkImageProvider(
                              meJournal["avatar_url"],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meJournal["username"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30),
                              ),
                              Text(
                                meJournal["locality_state"] +
                                    ", " +
                                    meJournal["locality_country"],
                              ),
                              Text(meJournal["bio"] ?? "")
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              FontAwesomeIcons.pen,
                              size: 20,
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: colorScheme.onInverseSurface,
                            borderRadius: BorderRadius.circular(30)),
                        child: TabBar(
                          overlayColor: const MaterialStatePropertyAll(
                              Colors.transparent),
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
                          CustomPostCardWidget(
                            journals: postJournals,
                            hasMoreData: hasMoreDataPosts,
                            isFromProfilePage: true,
                          ),
                          commentListViewBuilderWidget(
                              commentJournals: commentsJournals,
                              hasMoreData: hasMoreDataComments,
                              isFromProfilePage: true)
                        ],
                      ),
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
        ),
      ),
    );
  }
}
