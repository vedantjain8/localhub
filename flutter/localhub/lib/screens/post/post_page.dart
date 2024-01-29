import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localhub/api/comments/comments_service.dart';
import 'package:localhub/api/post_service.dart';
import 'package:localhub/api/posts_stats_service.dart';
import 'package:localhub/functions/datetimeoperations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:localhub/widgets/custom_comment_list_view_builder_widget.dart';

class PostPage extends StatefulWidget {
  final int postID;
  const PostPage({super.key, required this.postID});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late int postID;
  Map<String, dynamic> _journals = {};
  List<Map<String, dynamic>> _commentJournals = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _comment = TextEditingController();
  final PostApiService pas = PostApiService();
  final PostStatsApiService pass = PostStatsApiService();
  final CommentsApiService cas = CommentsApiService();

  int offset = 0;
  bool _hasMoreData = true;
  final formater = NumberFormat.compact(locale: "en_us", explicitSign: true);

  int votes = 0;
  int comments = 0;
  int views = 0;
  bool pressedDislike = false;
  bool pressedLike = false;

  void _loadData() async {
    final Map<String, dynamic> data = await pas.getPostById(postId: postID);

    setState(() {
      _journals = data;
    });
  }

  void _loadComment() async {
    if (!_hasMoreData) {
      return;
    }

    final List<Map<String, dynamic>> data =
        await cas.getComments(postId: postID, offsetN: offset);

    if (data.isEmpty) {
      setState(() {
        _hasMoreData = false;
      });
      return;
    }

    setState(() {
      _commentJournals = [..._commentJournals, ...data];
      offset += 10;
    });

    if (data.length != 10) {
      setState(() {
        _hasMoreData = false;
      });
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    postID = widget.postID;
    _loadData();
    _loadStats();
    _loadComment();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadComment();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _commentJournals = [];
      offset = 0;
      _hasMoreData = true;
    });
    _loadComment();
    _loadStats();
  }

  void _loadStats() async {
    final Map<String, dynamic> data = await pass.getPostStats(postID: postID);

    setState(() {
      votes = data['total_votes'] ?? 0;
      comments = data['total_comments'] ?? 0;
      views = data['total_views'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("POST PAGE"),
      ),
      body: (_journals.isEmpty)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _refreshData(),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) => SubredditHomePage(
                              //         subredditId: _journals
                              //             ["subreddit_id"]),
                              //   ),
                              // );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              right: 12.0, bottom: 5.0),
                                          height: 33,
                                          width: 33,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  _journals["logo_url"]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                                'r/${_journals["community_name"]}'),
                                            Text(
                                                'u/${_journals["post_username"]} · ${timeAgo(_journals["created_at"])}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // snapshot.data ?? false
                                //     ? Row(
                                //         children: [
                                //           ElevatedButton(
                                //             onPressed: () async {
                                //               await joinSubreddit(
                                //                   subid: _journals
                                //                       ["subreddit_id"]);
                                //             },
                                //             child: const Text("Join"),
                                //           ),
                                //           IconButton(
                                //               onPressed: () {},
                                //               icon: const Icon(
                                //                   Icons.more_vert_rounded))
                                //         ],
                                //       )
                                //     : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          Text(
                            _journals["post_title"],
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w500),
                          ),
                          Visibility(
                            visible: _journals["post_image"] != null &&
                                _journals["post_image"]!.isNotEmpty,
                            child: Container(
                              width: double.maxFinite,
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  fit: BoxFit.fitWidth,
                                  imageUrl: _journals["post_image"]!,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          MarkdownBody(
                            data: _journals["post_content"].toString(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      pass.sendVote(
                                          postID: _journals['post_id'],
                                          upvote: true);
                                      // setState(() {
                                      //   postStatsMap[postID]!['total_votes'] += 1;
                                      // });
                                    },
                                    icon: pressedLike
                                        ? const FaIcon(
                                            FontAwesomeIcons.solidThumbsUp,
                                          )
                                        : const FaIcon(
                                            FontAwesomeIcons.thumbsUp,
                                          ),
                                  ),
                                  Text(formater.format(votes)),
                                  IconButton(
                                    onPressed: () {
                                      pass.sendVote(
                                          postID: _journals["post_id"],
                                          upvote: false);
                                    },
                                    icon: pressedDislike
                                        ? const FaIcon(
                                            FontAwesomeIcons.solidThumbsDown,
                                          )
                                        : const FaIcon(
                                            FontAwesomeIcons.thumbsDown,
                                          ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const FaIcon(
                                      FontAwesomeIcons.message,
                                    ),
                                  ),
                                  Text(formater.format(comments)),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const FaIcon(
                                      FontAwesomeIcons.paperPlane,
                                    ),
                                  ),
                                  const Text('Send'),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 2.0),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(81, 81, 81, 0.494)),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 3,
                              scrollPadding: const EdgeInsets.all(4.0),
                              controller: _comment,
                              decoration:
                                  const InputDecoration(hintText: "Comment"),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                await cas.createCommentById(
                                  postID: postID,
                                  commentContent:
                                      _comment.value.text.toString(),
                                );
                                setState(() {
                                  _comment.clear();
                                });

                                _refreshData();
                              },
                              child: const Icon(Icons.send_rounded)),
                        ],
                      ),
                    ),
                    commentListViewBuilderWidget(
                        commentJournals: _commentJournals,
                        hasMoreData: _hasMoreData),
                  ],
                ),
              ),
            ),
    );
  }
}
