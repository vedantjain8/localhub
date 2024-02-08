import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

// TextEditingController _searchController = TextEditingController();
SearchController _searchController = SearchController();

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> temp = [
    {
      "community_id": 1,
      "community_name": "global",
      "community_description": "This is for testing purpose only",
      "creator_user_id": 12,
      "created_at": "2024-01-16T01:04:41.379Z",
      "banner_url":
          "https://styles.redditmedia.com/t5_2qh1q/styles/bannerBackgroundImage_zu4dcceuoupa1.png?width=4000&s=1d78b8e2353a730077a6cf1ad344ae0cb79df3b1",
      "logo_url":
          "https://styles.redditmedia.com/t5_2qh1q/styles/communityIcon_9ggb2zkszbf91.png?width=256&s=395857a1bb50dec0de550b38cecfd322283c58ad",
      "active": true
    },
    {
      "community_id": 1,
      "community_name": "global29",
      "community_description": "This is for testing purpose only",
      "creator_user_id": 12,
      "created_at": "2024-01-16T01:04:41.379Z",
      "banner_url":
          "https://styles.redditmedia.com/t5_2qh1q/styles/bannerBackgroundImage_zu4dcceuoupa1.png?width=4000&s=1d78b8e2353a730077a6cf1ad344ae0cb79df3b1",
      "logo_url":
          "https://styles.redditmedia.com/t5_2qh1q/styles/communityIcon_9ggb2zkszbf91.png?width=256&s=395857a1bb50dec0de550b38cecfd322283c58ad",
      "active": true
    },
    {
      "community_id": 1,
      "community_name": "halooo",
      "community_description": "This is for testing purpose only",
      "creator_user_id": 12,
      "created_at": "2024-01-16T01:04:41.379Z",
      "banner_url":
          "https://styles.redditmedia.com/t5_2qh1q/styles/bannerBackgroundImage_zu4dcceuoupa1.png?width=4000&s=1d78b8e2353a730077a6cf1ad344ae0cb79df3b1",
      "logo_url":
          "https://styles.redditmedia.com/t5_2qh1q/styles/communityIcon_9ggb2zkszbf91.png?width=256&s=395857a1bb50dec0de550b38cecfd322283c58ad",
      "active": true
    },
    {
      "community_id": 1,
      "community_name": "tatti",
      "community_description": "This is for testing purpose only",
      "creator_user_id": 12,
      "created_at": "2024-01-16T01:04:41.379Z",
      "banner_url":
          "https://styles.redditmedia.com/t5_2qh1q/styles/bannerBackgroundImage_zu4dcceuoupa1.png?width=4000&s=1d78b8e2353a730077a6cf1ad344ae0cb79df3b1",
      "logo_url":
          "https://styles.redditmedia.com/t5_2qh1q/styles/communityIcon_9ggb2zkszbf91.png?width=256&s=395857a1bb50dec0de550b38cecfd322283c58ad",
      "active": true
    },
  ];
  Iterable<Widget> getSuggestions(List<Map<String, dynamic>> temp) sync* {
    for (var item in temp) {
      yield ListTile(
        leading: Container(
          height: 33,
          width: 33,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                item['logo_url'],
              ),
            ),
          ),
        ),
        title: Text(item['community_name']),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 10, right: 10),
        child: SearchAnchor.bar(
          isFullScreen: false,
          barHintText: 'Search',
          barLeading: InkWell(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          suggestionsBuilder:
              (BuildContext context, SearchController controller) {
            return getSuggestions(temp);
          },
        ),
      ),
    );
  }
}



// ====================================================

            //   Column(
            //     children: [
            //       Row(
            //         children: [
            //           // IconButton(
            //           //   onPressed: () {
            //           //   // Navigator.of(context).pop();
            //           // // },
            //           //   // icon: const Icon(Icons.arrow_back),
            //           // ),
            //           Expanded(
            //               child: SearchAnchor(
            //             isFullScreen: false,
            //             searchController: _searchController,
            //             builder: (BuildContext context, SearchController controller) {
            //               return SearchBar(
            //                 onTap: () {
            //                   // _searchController.openView();
            //                 },
            //                 controller: _searchController,
            //               );
            //               // return SizedBox(
            //               //   height: 60,
            //               //   width: double.maxFinite,
            //               //   child: TextField(
            //               //       onTap: () {
            //               //         _searchController.openView();
            //               //       },
            //               //       onChanged: (value) {},
            //               //       autofocus: true,
            //               //       textInputAction: TextInputAction.search,
            //               //       decoration: InputDecoration(
            //               //         hintText: 'Search',
            //               //         filled: true,
            //               //         fillColor: colorScheme.onInverseSurface,
            //               //         border: OutlineInputBorder(
            //               //           borderRadius: BorderRadius.circular(20.0),
            //               //           borderSide: BorderSide.none,
            //               //         ),
            //               //       )),
            //               // );
            //             },
            //             viewConstraints: const BoxConstraints(
            //                 maxWidth: double.maxFinite, minWidth: double.maxFinite),
            //             suggestionsBuilder:
            //                 (BuildContext context, SearchController controller) {
            //               if (_searchController.text.isEmpty) {
            //                 return [];
            //               } else {
            //                 return List.generate(temp.length, (index) {
            //                   print(temp[index]['community_name']);
            //                   return ListTile(
            //                     leading: Container(
            //                       height: 33,
            //                       width: 33,
            //                       decoration: BoxDecoration(
            //                         shape: BoxShape.circle,
            //                         image: DecorationImage(
            //                           image: CachedNetworkImageProvider(
            //                             temp[index]['logo_url'],
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                     title: Text(
            //                       temp[index]['community_name'],
            //                     ),
            //                   );
            //                 });
            //               }
            //             },
            //           ))
            //         ],
            //       ),
            //     ],
            //   ),
            // ),