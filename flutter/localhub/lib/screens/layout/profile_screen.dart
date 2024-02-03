import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/screens/authscreens/register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    Tab(text: 'Posts'),
    Tab(text: 'Comments'),
    Tab(text: 'About'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              leading: const Icon(Icons.arrow_back),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const FaIcon(
                    FontAwesomeIcons.sliders,
                  ),
                ),
              ],
              expandedHeight: 250,
              floating: false,
              snap: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 50, bottom: 15),
                title: const Text(
                  'username',
                ),
                background: ShaderMask(
                  shaderCallback: (rect) {
                    return const RadialGradient(
                      radius: 1.5,
                      center: Alignment.center,
                      colors: [
                        Colors.black,
                        Colors.transparent,
                      ],
                    ).createShader(rect);
                    // return const LinearGradient(
                    //     begin: Alignment.topLeft,
                    //     end: Alignment.bottomRight,
                    //     colors: [
                    //       Colors.black,
                    //       Colors.transparent,
                    //     ]).createShader(
                    //     Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.network(
                    // 'https://source.unsplash.com/random',
                    'https://images.unsplash.com/photo-1487700160041-babef9c3cb55?q=80&w=1152&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          decoration: const BoxDecoration(
              // color: colorScheme.onInverseSurface,
              ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: colorScheme.background,
                  borderRadius: BorderRadius.circular(60.0),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: _tabs,
                  unselectedLabelColor: colorScheme.primary,
                  // labelColor: colorScheme.background,
                  indicatorSize: TabBarIndicatorSize.tab,
                  // indicatorColor: Colors.transparent,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ListView.builder(
                      itemBuilder: (context, index) => Container(
                        color: index.isOdd
                            ? colorScheme.primary
                            : colorScheme.secondary,
                        height: 100,
                      ),
                      itemCount: 15,
                    ),
                    const RegisterScreen(),
                    const RegisterScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
