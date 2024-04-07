import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/api/about_user_service.dart';
import 'package:localhub/api/agenda_service.dart';
import 'package:localhub/auth/auth_service.dart';
import 'package:localhub/screens/admin/admin_login.dart';
import 'package:localhub/screens/authscreens/login_screen.dart';
import 'package:localhub/screens/layout/agenda_screen.dart';
import 'package:localhub/screens/community/create_community.dart';
import 'package:localhub/screens/layout/explore_screen.dart';
import 'package:localhub/screens/layout/home_screen.dart';
import 'package:localhub/screens/layout/profile_screen.dart';
import 'package:localhub/screens/layout/search_screen.dart';
import 'package:localhub/screens/layout/settings/settings_screen.dart';
import 'package:localhub/screens/layout/agenda/create_agenda.dart';
import 'package:localhub/screens/post/create_post.dart';
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
  final AgendaApiService aas = AgendaApiService();

  List<Map<String, dynamic>> agendaList = [];
  Map<String, dynamic> _meJournal = {};

  void _loadMeData() async {
    Map<String, dynamic> data = await auas.aboutUserData();
    setState(() {
      _meJournal = data['response'];
    });

    // if (_meJournal['active']==false){TODO: implement this}
  }

  void _loadAgendaList() async {
    List<Map<String, dynamic>> data = await aas.getAgendaList();
    setState(() {
      agendaList = data;
    });
  }

  @override
  void initState() {
    _loadMeData();
    _loadAgendaList();
    super.initState();
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
                    // InkWell(
                    //   onTap: () {
                    //     // Navigator.of(context).push(MaterialPageRoute(
                    //     //     builder: (context) => const HistoryPage()));
                    //   },
                    //   child: _endDrawerItem(
                    //     FontAwesomeIcons.clockRotateLeft,
                    //     'History',
                    //   ),
                    // ),

                    // settings
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SettingsScreen()));
                      },
                      child: _endDrawerItem(FontAwesomeIcons.gear, 'Settings'),
                    ),

                    // logout
                    InkWell(
                      onLongPress: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AdminLoginPage()));
                      },
                      onTap: () {
                        AuthService().logout().then((value) =>
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (route) => false));
                      },
                      child: _endDrawerItem(
                        FontAwesomeIcons.doorOpen,
                        'logout',
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
          const SizedBox(width: 13),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filled(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const CreatePost()));
                            },
                            icon: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: FaIcon(FontAwesomeIcons.solidPenToSquare),
                            ),
                            tooltip: 'Post',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Create Post')
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filled(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const CreateAgenda()));
                            },
                            icon: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: FaIcon(FontAwesomeIcons.solidCalendarPlus),
                            ),
                            tooltip: 'click a image',
                          ),
                          const SizedBox(height: 10),
                          const Text('Create Agenda'),
                        ],
                      ),
                    ],
                  ),
                );
              });
        },
        shape: const CircleBorder(),
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          const HomeScreen(),
          const ExploreScreen(),
          AgendaScreen(agendaList: agendaList),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(
        // key: customBottomAppBarKey,
        onTabSelected: (index) {
          _selectedTab(index);
        },
        items: [
          CustomAppBarItem(icon: FontAwesomeIcons.house),
          CustomAppBarItem(icon: FontAwesomeIcons.solidCompass),
          CustomAppBarItem(icon: FontAwesomeIcons.solidCalendarDays),
          CustomAppBarItem(icon: FontAwesomeIcons.solidCircleUser),
        ],
      ),
    );
  }
}
