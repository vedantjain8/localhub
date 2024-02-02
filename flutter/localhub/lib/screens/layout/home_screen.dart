import 'package:flutter/material.dart';
import 'package:localhub/api/post_service.dart';
import 'package:localhub/themes/theme.dart';
import 'package:localhub/widgets/custom_post_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int offset = 0;
  bool _hasMoreData = true;

  List<Map<String, dynamic>> _journals = [];
  final ScrollController _scrollController = ScrollController();

  final PostApiService pas = PostApiService();

  void _loadData() async {
    if (!_hasMoreData) {
      return; // No more data to load
    }

    final List<Map<String, dynamic>> data = await pas.getHomePost(
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


  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadData();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _journals = [];
      offset = 0;
      _hasMoreData = true;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Home Screen'),
          // actions: [
          //   PopupMenuButton<Color>(
          //     onSelected: (color) async {
          //       await AppTheme.selectColor(color);
          //     },
          //     itemBuilder: (context) => ColorSeed.values.map((colorSeed) {
          //       return PopupMenuItem(
          //         value: colorSeed.color,
          //         child: Row(
          //           children: [
          //             Container(
          //               width: 24,
          //               height: 24,
          //               color: colorSeed.color,
          //             ),
          //             const SizedBox(width: 10),
          //             Text(colorSeed.label),
          //           ],
          //         ),
          //       );
          //     }).toList(),
          //   ),
          //   IconButton(
          //     onPressed: () async {
          //       await AppTheme.toggleBrightness();
          //     },
          //     icon: AppTheme.themeNotifier.value.brightness == Brightness.dark
          //         ? const Icon(Icons.light_mode_outlined)
          //         : const Icon(Icons.dark_mode_rounded),
          //   ),
          // ],
      // ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              CustomPostCardWidget(
                  journals: _journals, hasMoreData: _hasMoreData),
            ],
          ),
        ),
      ),
    );
  }
}
