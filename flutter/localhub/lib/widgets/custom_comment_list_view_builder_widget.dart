import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localhub/api/comments_service.dart';
import 'package:localhub/api/report_service.dart';
import 'package:localhub/functions/datetimeoperations.dart';

final ReportApiService ras = ReportApiService();
final CommentsApiService cas = CommentsApiService();

void showPopUpMenuAtTap({
  required BuildContext context,
  required TapDownDetails details,
  required int commentID,
  required int postID,
  required bool isFromProfilePage,
}) {
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
      if (isFromProfilePage)
        const PopupMenuItem<String>(value: '2', child: Text('Delete')),
      // const PopupMenuItem<String>(value: '1', child: Text('Report')),
    ],
    elevation: 8.0,
  ).then((value) {
    if (value == null) return;

    if (value == "1") {
      ras.reportComment(commentID: commentID).then(
              (value) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value['response'].toString()),
                ),
              ),
            );
    } else if (value == "2") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete this post?'),
            content: const Text(
                'This action cannot be undone. Are you sure you want to delete this post?'),
            actions: [
              TextButton(
                onPressed: () {
                  cas.deleteCommentById(postId: postID, commentId: commentID);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Delete'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  });
}

Widget commentListViewBuilderWidget({
  required List<Map<String, dynamic>> commentJournals,
  required bool hasMoreData,
  bool isFromProfilePage = false,
}) {
  return (commentJournals.isEmpty)
      ? (hasMoreData)
          ? const CupertinoActivityIndicator()
          : const Center(child: Text("No more data to load"))
      : ListView.builder(
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
                            margin:
                                const EdgeInsets.only(right: 6.0, bottom: 5.0),
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
                      Text(
                          commentJournals[index]["comment_content"].toString()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTapDown: (details) {
                              showPopUpMenuAtTap(
                                  context: context,
                                  details: details,
                                  commentID: commentJournals[index]
                                      ['comment_id'],
                                  postID: commentJournals[index]['post_id'],
                                  isFromProfilePage: isFromProfilePage);
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
