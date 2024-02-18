import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localhub/api/comments_service.dart';
import 'package:localhub/api/post_service.dart';
import 'package:localhub/widgets/custom_comment_list_view_builder_widget.dart';
import 'package:localhub/widgets/custom_input_decoration.dart';
import 'package:localhub/widgets/custom_post_card_widget.dart';

class PostPage extends StatefulWidget {
  final int postID;
  final bool? voteState;
  const PostPage({
    super.key,
    required this.postID,
    this.voteState,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late int postID;
  List<Map<String, dynamic>> _journals = [];
  List<Map<String, dynamic>> _commentJournals = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _comment = TextEditingController();
  final PostApiService pas = PostApiService();
  final CommentsApiService cas = CommentsApiService();

  int offset = 0;
  bool _hasMoreData = true;
  final formater = NumberFormat.compact(locale: "en_us", explicitSign: true);

  bool? voteState;

  void _loadData() async {
    final List<Map<String, dynamic>> data =
        await pas.getPostById(postId: postID);

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
    voteState = widget.voteState;
    _loadData();
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
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
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
                    CustomPostCardWidget(
                        journals: _journals,
                        isFromPostPage: true,
                        voteState: voteState),
                    Container(
                      decoration: const BoxDecoration(
                          // color: Color.fromRGBO(81, 81, 81, 0.494),
                          ),
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
                              decoration: InputDecoration(
                                  label: const Text('Comment'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  suffixIcon: InkWell(
                                      onTap: () async {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                        );

                                        await cas.createCommentById(
                                          postID: postID,
                                          commentContent:
                                              _comment.value.text.toString(),
                                        );

                                        setState(() {
                                          _comment.clear();
                                        });

                                        _refreshData();

                                        Navigator.pop(context);
                                      },
                                      overlayColor: MaterialStateProperty.all(
                                          Colors.transparent),
                                      child: const Icon(
                                        FontAwesomeIcons.solidPaperPlane,
                                      ))),
                            ),
                          ),
                          // ElevatedButton(
                          //     onPressed: () async {
                          //       showDialog(
                          //         context: context,
                          //         barrierDismissible: false,
                          //         builder: (BuildContext context) {
                          //           return const Center(
                          //               child: CircularProgressIndicator());
                          //         },
                          //       );

                          //       await cas.createCommentById(
                          //         postID: postID,
                          //         commentContent:
                          //             _comment.value.text.toString(),
                          //       );

                          //       setState(() {
                          //         _comment.clear();
                          //       });

                          //       _refreshData();

                          //       Navigator.pop(context);
                          //     },
                          //     child: const Icon(Icons.send_rounded)),
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
