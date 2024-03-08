import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:localhub/api/search_service.dart';
import 'package:localhub/screens/community/community_page.dart';
import 'package:localhub/screens/post/post_page.dart';

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
  final SearchApiService sas = SearchApiService();

  Map<String, dynamic> searchList = {};

  void _loadSearchData(String searchControllerText) {
    // if (searchControllerText.isNotEmpty) {
    _debouncer.run(() async {
      Map<String, dynamic> data =
          await sas.search(searchTerm: searchControllerText.toString());
      setState(() {
        searchList = data['response'];
      });
    });
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadSearchData('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                onChanged: _loadSearchData,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 40),
              buildCommunitySearchResult(
                  'Community', searchList['communityData']),
              const SizedBox(height: 40),
              buildPostSearchResult('Posts', searchList['postData']),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCommunitySearchResult(String title, List<dynamic>? data) {
    if (data == null || data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              data.length,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 15, left: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommunityPage(
                            communityID: data[index]['community_id']),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                data[index]["logo_url"]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(data[index]["community_name"]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPostSearchResult(String title, List<dynamic>? data) {
    if (data == null || data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(data[index]['post_title']),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        PostPage(postID: data[index]['post_id'])));
              },
            );
          },
        ),
      ],
    );
  }
}
