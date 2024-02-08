import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localhub/api/community_service.dart';
import 'package:localhub/api/community_stats_service.dart';
import 'package:localhub/widgets/custom_post_card_widget.dart';
import 'package:localhub/functions/datetimeoperations.dart';

class CommunityPage extends StatefulWidget {
  final int communityID;
  const CommunityPage({
    super.key,
    required this.communityID,
  });

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late int communityID;
  List<Map<String, dynamic>> _journals = [];
  Map<String, dynamic> _communityData = {};
  Map<String, dynamic> _communityStats = {};
  final ScrollController _scrollController = ScrollController();
  final _appbar = AppBar();
  final CommunityApiService commas = CommunityApiService();
  final CommunityStatsApiService commsas = CommunityStatsApiService();

  int offset = 0;
  bool _hasMoreData = true;
  final formater = NumberFormat.compact(locale: "en_us", explicitSign: true);

  bool? voteState;

  void _loadData() async {
    if (!_hasMoreData) {
      return; // No more data to load
    }

    final List<Map<String, dynamic>> data =
        await commas.getCommunityPost(offset: offset, communityID: communityID);

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

  void _loadCommunityData() async {
    final Map<String, dynamic> data =
        await commas.getCommunityData(communityID: communityID);
    setState(() {
      _communityData = data;
    });
  }

  void _loadCommunityStats() async {
    final Map<String, dynamic> data =
        await commsas.getCommunityStats(communityID: communityID);
    setState(() {
      _communityStats = data;
    });
  }

  @override
  void initState() {
    super.initState();
    communityID = widget.communityID;
    _loadCommunityData();
    _loadCommunityStats();
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
      _communityStats = {};
    });
    _loadData();
    _loadCommunityStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar,
      body: (_journals.isEmpty)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _refreshData(),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (_communityData.isEmpty)
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 65,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: CachedNetworkImageProvider(
                                        _communityData["banner_url"]),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        right: 6.0, bottom: 5.0),
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        // image: NetworkImage(finalPost["logo_url"]),
                                        image: CachedNetworkImageProvider(
                                            _communityData["logo_url"]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Text("c/${_communityData['community_name']}"),
                                ],
                              ),
                              (_communityStats.isEmpty)
                                  ? const SizedBox.shrink()
                                  : Text(formater.format(
                                      _communityStats['subscriber_count'])),
                              Text(_communityData['community_description']),
                              Text(timeAgo(_communityData['created_at'])),
                            ],
                          ),
                    CustomPostCardWidget(
                      journals: _journals,
                      isFromSubPage: true,
                      hasMoreData: _hasMoreData,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
