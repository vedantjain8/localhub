import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/api/about_user_service.dart';
import 'package:localhub/api/post_service.dart';
import 'package:localhub/screens/authscreens/register_screen.dart';
import 'package:localhub/widgets/custom_post_card_widget.dart';
import 'package:localhub/widgets/custom_shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _hasMoreData = true;
  int offset = 0;

  List<Map<String, dynamic>> _journals = [];
  Map<String, dynamic> _meJournal = {};

  final PostApiService pas = PostApiService();
  final AboutUserApiService auas = AboutUserApiService();

  void _loadData() async {
    if (!_hasMoreData) {
      return; // No more data to load
    }

    final List<Map<String, dynamic>> data = await pas.getUserPublishedPost(
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

  Future<void> _refreshData() async {
    setState(() {
      _journals = [];
      offset = 0;
      _hasMoreData = true;
    });
    _loadData();
  }

  void _loadMeData() async {
    Map<String, dynamic> data = await auas.aboutUserData();
    setState(() {
      _meJournal = data;
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
    _loadData();
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
          child: _meJournal.isEmpty
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
                              _meJournal["avatar_url"],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _meJournal["username"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30),
                              ),
                              Text(
                                _meJournal["locality_state"] +
                                    ", " +
                                    _meJournal["locality_country"],
                              ),
                              Text(_meJournal["bio"] ?? "")
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
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
                            journals: _journals,
                            hasMoreData: _hasMoreData,
                          ),
                          ListView.builder(
                            itemBuilder: (context, index) => Container(
                              color: index.isOdd
                                  ? colorScheme.primary
                                  : colorScheme.inversePrimary,
                              height: 100,
                            ),
                            itemCount: 5,
                          )
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
