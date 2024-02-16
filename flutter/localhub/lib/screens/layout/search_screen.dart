import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:localhub/api/community_service.dart';
import 'package:localhub/screens/community/community_page.dart';

class Debouncer {
  Debouncer({required this.milliseconds});
  final int milliseconds;
  Timer? _timer;
  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchController _searchController = SearchController();
  final _debouncer = Debouncer(milliseconds: 500);
  final CommunityApiService cas = CommunityApiService();

  List<Map<String, dynamic>> searchList = [];

  void _loadSearchData(String searchControllerText) {
    if (searchControllerText.isNotEmpty) {
      _debouncer.run(() async {
        List<Map<String, dynamic>> data =
            await cas.getCommunityList(communityName: searchControllerText);
        setState(() {
          searchList = data;
        });
        print(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 10, right: 10),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (String value) {
                _loadSearchData(value);
              },
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchList.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommunityPage(
                            communityID: searchList[index]['community_id']),
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        height: 33,
                        width: 33,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              searchList[index]['logo_url'],
                            ),
                          ),
                        ),
                      ),
                      title: Text(searchList[index]['community_name']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
