import 'package:flutter/material.dart';
import 'package:localhub/screens/authscreens/login_screen.dart';
import 'package:localhub/screens/authscreens/register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    Tab(text: 'Login'),
    Tab(text: 'Register'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: colorScheme.onInverseSurface,
                // Theme.of(context).colorScheme.brightness == Brightness.dark
                //     ? Colors.black
                //     : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: colorScheme.background,
                        borderRadius: BorderRadius.circular(60.0),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        tabs: _tabs,
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
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        LoginScreen(),
                        RegisterScreen(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
