import 'package:flutter/material.dart';
import 'package:localhub/api/post_service.dart';
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

    final List<Map<String, dynamic>> data = await pas.getUserJoinedPost(
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
    return RefreshIndicator(
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
    );
  }
}
