import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localhub/api/report_service.dart';
import 'package:localhub/functions/datetimeoperations.dart';

final ReportApiService ras = ReportApiService();

void showPopUpMenuAtTap(
    {required BuildContext context,
    required TapDownDetails details,
    int? commentID}) {
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(
      details.globalPosition.dx,
      details.globalPosition.dy,
      details.globalPosition.dx,
      details.globalPosition.dy,
    ),
    items: [
      const PopupMenuItem<String>(value: '1', child: Text('Report')),
      // const PopupMenuItem<String>(value: '1', child: Text('Report')),
    ],
    elevation: 8.0,
  ).then((value) {
    if (value == null) return;

    if (value == "1") {
      ras.reportComment(commentID: commentID!);
    }
    // else if(value == "2"){
    //   //code here
    // }
  });
}

Widget commentListViewBuilderWidget({
  required List<Map<String, dynamic>> commentJournals,
  required bool hasMoreData,
}) {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: commentJournals.length + 1,
    itemBuilder: (context, index) {
      if (index == commentJournals.length) {
        if (hasMoreData == false) {
          return const Center(
            child: Text("You are all caught up bro! CHILL 😮‍💨"),
          );
        }
        return const CupertinoActivityIndicator();
      }
      return Container(
        margin: const EdgeInsets.only(left: 6.0, right: 6.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 6.0, bottom: 5.0),
                      height: 33,
                      width: 33,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            commentJournals[index]["avatar_url"],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(
                        "${commentJournals[index]['username']} · ${timeAgo(commentJournals[index]["created_at"])}"),
                  ],
                ),
                Text(commentJournals[index]["comment_content"].toString()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTapDown: (details) {
                        showPopUpMenuAtTap(
                            context: context,
                            details: details,
                            commentID: commentJournals[index]['comment_id']);
                      },
                      child: const Icon(Icons.more_vert_rounded),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
