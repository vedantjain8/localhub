import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/screens/layout/community_screen.dart';
import 'package:localhub/screens/posts/create_post.dart';
import 'package:localhub/screens/layout/explore_screen.dart';
import 'package:localhub/screens/layout/home_screen.dart';
import 'package:localhub/screens/layout/profile_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigator.of(context)
            //     .push(MaterialPageRoute(builder: (context) => const CreatePost()));
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
            CommunityScreen(),
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
        ));
  }
}
