import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/api/about_user_service.dart';
import 'package:localhub/screens/layout/agenda_screen.dart';
import 'package:localhub/screens/community/create_community.dart';
// import 'package:localhub/screens/posts/create_post.dart';
import 'package:localhub/screens/layout/explore_screen.dart';
import 'package:localhub/screens/layout/home_screen.dart';
import 'package:localhub/screens/layout/profile_screen.dart';
import 'package:localhub/screens/layout/search_screen.dart';
import 'package:localhub/screens/post/create_post.dart';
import 'package:localhub/themes/theme.dart';
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

  Widget _endDrawerItem(icon, text) {
    return ListTile(
      leading: SizedBox(
        height: 20,
        width: 20,
        child: FaIcon(icon),
      ),
      title: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    // Build the UI using the fetched data
    return Scaffold(
      extendBody: true,
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
                    Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              _meJournal["avatar_url"],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        'u/${_meJournal["username"]}',
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(
                      height: 40.0,
                    ),

                    // myprofile
                    InkWell(
                      onTap: () {
                        scaffoldKey.currentState!.closeEndDrawer();
                        _selectedTab(3);
                        customBottomAppBarKey.currentState?.updateIndex(3);
                      },
                      child: _endDrawerItem(
                          FontAwesomeIcons.solidUser, 'My Account'),
                    ),

                    // create a subreddit
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const CreateCommunity()));
                      },
                      child: _endDrawerItem(
                          FontAwesomeIcons.usersLine, 'Create Community'),
                    ),

                    // history
                    InkWell(
                      onTap: () {
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => const HistoryPage()));
                      },
                      child: _endDrawerItem(
                        FontAwesomeIcons.clockRotateLeft,
                        'History',
                      ),
                    ),

                    // settings
                    InkWell(
                      onTap: () {
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (context) => const UserSettingsPage()));
                      },
                      child: _endDrawerItem(FontAwesomeIcons.gear, 'Settings'),
                    ),
                    IconButton(
                      onPressed: () async {
                        await AppTheme.toggleBrightness();
                      },
                      icon: AppTheme.themeNotifier.value.brightness ==
                              Brightness.dark
                          ? const Icon(Icons.light_mode_outlined)
                          : const Icon(Icons.dark_mode_rounded),
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
                      color: colorScheme.onInverseSurface,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          _meJournal["avatar_url"],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
          const SizedBox(width: 13),
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
        key: customBottomAppBarKey,
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
