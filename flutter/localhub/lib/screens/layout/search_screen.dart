import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/api/search_service.dart';
import 'package:localhub/screens/community/community_page.dart';
import 'package:localhub/screens/post/post_page.dart';
import 'package:localhub/widgets/custom_input_decoration.dart';
import 'package:localhub/widgets/custom_post_card_widget.dart';

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
          padding: const EdgeInsets.only(top: 50.0, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  InkWell(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    child: const Icon(FontAwesomeIcons.arrowLeft),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                        controller: _searchController,
                        onChanged: (String value) {
                          _loadSearchData(value);
                        },
                        decoration: CustomInputDecoration.inputDecoration(
                          hintText: '',
                          label: 'Search',
                          prefixIcon: const Icon(
                            FontAwesomeIcons.magnifyingGlass,
                          ),
                          context: context,
                        )),
                  ),
                ],
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                data[index]["logo_url"]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text("c/" + data[index]["community_name"]),
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
    final colorScheme = Theme.of(context).colorScheme;

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
              data.length,
              (index) => ListTile(
                    title: Text(
                      data[index]['post_title'],
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              PostPage(postID: data[index]['post_id'])));
                    },
                  )),
        ),
      ],
    );
  }
}
