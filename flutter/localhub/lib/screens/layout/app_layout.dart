import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/api/about_user_service.dart';
import 'package:localhub/screens/layout/agenda_screen.dart';
// import 'package:localhub/screens/posts/create_post.dart';
import 'package:localhub/screens/layout/explore_screen.dart';
import 'package:localhub/screens/layout/home_screen.dart';
import 'package:localhub/screens/layout/profile_screen.dart';
import 'package:localhub/screens/layout/search_screen.dart';
import 'package:localhub/screens/layout/create_post.dart';
import 'package:localhub/widgets/custom_bottom_app_bar.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final PageController _pageController = PageController(initialPage: 0);
  void _selectedTab(int index) {
    _pageController.jumpToPage(index);
  }

  final AboutUserApiService auas = AboutUserApiService();
  Map<String, dynamic> _meJournal = {};

  void _loadMeData() async {
    Map<String, dynamic> data = await auas.aboutUserData();
    setState(() {
      _meJournal = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMeData();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    // Build the UI using the fetched data
    return Scaffold(
      key: scaffoldKey,
      endDrawer: (_meJournal.isEmpty)
          ? const Drawer()
          : Drawer(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 50.0,
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 6.0, bottom: 5.0),
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            _meJournal["avatar_url"],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'u/${_meJournal["username"]}',
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 40.0,
                    ),

                    // myprofile
                    InkWell(
                      onTap: () {
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => const MyProfilePage()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: const Row(
                          children: [
                            Icon(Icons.person),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "My Profile",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // create a subreddit
                    InkWell(
                      onTap: () {
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => const CreateNewSubreddit()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: const Row(
                          children: [
                            Icon(Icons.groups_rounded),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Create a Community",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // history
                    InkWell(
                      onTap: () {
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => const HistoryPage()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: const Row(
                          children: [
                            Icon(Icons.history_rounded),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "History",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // settings
                    InkWell(
                      onTap: () {
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => const UserSettingsPage()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: const Row(
                          children: [
                            Icon(Icons.settings_rounded),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Settings",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      appBar: AppBar(
        // title: title,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SearchScreen()));
            },
            icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
          ),
          (_meJournal.isEmpty)
              ? const SizedBox.shrink()
              : InkWell(
                  onTap: () {
                    scaffoldKey.currentState!.openEndDrawer();
                  },
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  child: Container(
                    height: 33,
                    width: 33,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          _meJournal["avatar_url"],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreatePost()));
        },
        shape: const CircleBorder(),
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: const [
          HomeScreen(),
          ExploreScreen(),
          AgendaScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onTabSelected: (index) {
          _selectedTab(index);
        },
        items: [
          CustomAppBarItem(icon: FontAwesomeIcons.house),
          CustomAppBarItem(icon: FontAwesomeIcons.solidCompass),
          CustomAppBarItem(icon: FontAwesomeIcons.usersLine),
          CustomAppBarItem(icon: FontAwesomeIcons.solidCircleUser),
        ],
      ),
    );
  }
}
