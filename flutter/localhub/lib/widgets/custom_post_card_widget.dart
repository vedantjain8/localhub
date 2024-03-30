import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/api/community_stats_service.dart';
import 'package:localhub/api/post_service.dart';
import 'package:localhub/api/posts_stats_service.dart';
import 'package:localhub/api/report_service.dart';
import 'package:localhub/functions/datetimeoperations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:localhub/screens/community/community_page.dart';
import 'package:localhub/screens/post/create_post.dart';
import 'package:localhub/screens/post/post_page.dart';
import 'package:localhub/widgets/custom_shimmer.dart';

class CustomPostCardWidget extends StatefulWidget {
  final List<Map<String, dynamic>> journals;
  final bool? hasMoreData;
  final bool isFromPostPage;
  final bool isFromSubPage;
  final bool isFromProfilePage;
  final bool? voteState;
  const CustomPostCardWidget({
    super.key,
    required this.journals,
    this.hasMoreData,
    this.isFromPostPage = false,
    this.isFromSubPage = false,
    this.isFromProfilePage = false,
    this.voteState,
  });

  @override
  State<CustomPostCardWidget> createState() => _CustomPostCardWidgetState();
}

class _CustomPostCardWidgetState extends State<CustomPostCardWidget> {
  Map<int, bool> voteStateMap = {};

  final PostStatsApiService pass = PostStatsApiService();
  final PostApiService pas = PostApiService();
  final ReportApiService ras = ReportApiService();
  final CommunityStatsApiService csas = CommunityStatsApiService();
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> _loadStats(int postID) async {
    final Map<String, dynamic> data = await pass.getPostStats(postID: postID);
    return data['response'];
  }

  @override
  void initState() {
    super.initState();
  }

  Map<int, Map<String, dynamic>> postStatsMap =
      {}; //stores the actual post stats value
  Set<int> postsWithLoadedStats = <int>{}; // Track posts with loaded stats

  Future<void> _loadStatsLazily(int postID) async {
    if (!postsWithLoadedStats.contains(postID)) {
      // Mark this post as having loaded stats to avoid unnecessary calls
      postsWithLoadedStats.add(postID);

      // Fetch post stats
      Map<String, dynamic> stats = await _loadStats(postID);

      // Update post stats map
      setState(() {
        postStatsMap[postID] = stats;
      });
    }
  }

  void showPopUpMenuAtTap({
    required BuildContext context,
    required TapDownDetails details,
    required int postID,
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
        if (widget.isFromProfilePage)
          const PopupMenuItem<String>(value: '2', child: Text('Update')),
        if (widget.isFromProfilePage)
          const PopupMenuItem<String>(value: '3', child: Text('Delete')),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == null) return;

      if (value == "1") {
        ras.reportPost(postID: postID).then(
              (value) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value['response'].toString()),
                ),
              ),
            );
      } else if (value == "2") {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreatePost(
              isUpdating: true,
              postID: postID,
            ),
          ),
        );
      } else if (value == "3") {
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
                    pas.deletePostById(postId: postID);
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

  Future<bool> checkCommunityJoinStatus({required communityID}) async {
    String? value = await storage.read(key: "is-$communityID-joined");
    if (value != null) {
      return bool.parse(value);
    } else {
    final status =
        await csas.checkCommunityJoinStatus(communityID: communityID);

    await storage.write(
        key: "is-$communityID-joined",
        value: status['response']['exists'].toString());
    return (status['response']['exists']);
    }
  }

  void _joinORleaveCommunity(
      {required int communityID, required bool isJoined}) async {
    if (isJoined == true) {
      await csas.leaveCommuntiy(communityID: communityID);
      await storage.write(
          key: "is-$communityID-joined", value: false.toString());
      setState(() {});
    } else if (isJoined == false) {
      // todo join community function
      await csas.joinCommuntiy(communityID: communityID);
      await storage.write(
          key: "is-$communityID-joined", value: true.toString());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // return buildPostCardWidget(context, widget.journals, widget.hasMoreData);
    final formater = NumberFormat.compact(locale: "en_us", explicitSign: true);
    final colorScheme = Theme.of(context).colorScheme;
    List<Map<String, dynamic>> journals = widget.journals;
    bool? hasMoreData = widget.hasMoreData;
    bool? isFromPostPage = widget.isFromPostPage;
    bool? isFromSubPage = widget.isFromSubPage;

    return (journals.isEmpty)
        ? (hasMoreData ?? true)
            ? const CustomShimmer()
            : const Center(child: Text("No more data to load"))
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: isFromPostPage ? journals.length : journals.length + 1,
            itemBuilder: (context, index) {
              if (!isFromPostPage) {
                if (index == journals.length) {
                  if (hasMoreData == false) {
                    return const Center(
                      child: Text("No more data to load"),
                    );
                  }
                  return const CupertinoActivityIndicator();
                }
              }

              final finalPost = journals[index];
              final postID = finalPost['post_id'];
              final communityID = finalPost['community_id'];

              _loadStatsLazily(postID);

              Map<String, dynamic> stats = postStatsMap[postID] ?? {};

              // Extract like count and comment count from stats
              int totalVotes = stats['total_votes'] ?? 0;
              if (isFromPostPage) {
                if (widget.voteState == true) {
                  totalVotes += 1;
                } else if (widget.voteState == false) {
                  totalVotes -= 1;
                }
              }
              int totalComments = stats['total_comments'] ?? 0;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: colorScheme.onInverseSurface,
                  ),
                  width: double.maxFinite,
                  child: InkWell(
                    onTap: () {
                      if (!isFromPostPage) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PostPage(
                              postID: postID,
                              voteState: voteStateMap[postID],
                            ),
                          ),
                        );
                      }
                    },
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // community name
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, left: 10.0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (!isFromSubPage) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => CommunityPage(
                                            communityID:
                                                finalPost["community_id"],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      // const SizedBox(width: 10),
                                      Container(
                                        height: 33,
                                        width: 33,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                finalPost["logo_url"]),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        finalPost["community_name"],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(timeAgo(finalPost["created_at"])),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    FutureBuilder(
                                        future: checkCommunityJoinStatus(
                                            communityID: communityID),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            // Return a loading indicator while the future is being fetched
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            // Handle any errors that occur during the future execution
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            // If the future has successfully resolved, show the join button based on the boolean value
                                            final bool isJoined =
                                                snapshot.data!;
                                            return ElevatedButton(
                                              onPressed: () {
                                                _joinORleaveCommunity(
                                                    communityID: communityID,
                                                    isJoined: isJoined);
                                              },
                                              child: Text(
                                                  isJoined ? 'Leave' : 'Join'),
                                            );
                                          }
                                        }),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 30,
                                      child: GestureDetector(
                                        onTapDown: (details) {
                                          showPopUpMenuAtTap(
                                              context: context,
                                              details: details,
                                              postID: journals[index]
                                                  ['post_id']);
                                        },
                                        child: const FaIcon(
                                            FontAwesomeIcons.ellipsisVertical),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Title
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  finalPost["post_title"],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                                // if finalPost["post_description"] is not empty
                                isFromPostPage
                                    ? MarkdownBody(
                                        data: finalPost["post_content"]
                                            .toString(),
                                      )
                                    : Column(
                                        children: [
                                          Visibility(
                                            visible:
                                                finalPost["short_content"] !=
                                                    null,
                                            child: Text(
                                                finalPost["short_content"]!),
                                          ),
                                          SizedBox(
                                              height:
                                                  finalPost["short_content"]!
                                                          .isNotEmpty
                                                      ? 7
                                                      : 0),
                                        ],
                                      ),
                                // if imgUrl is not empty
                                Visibility(
                                  visible: finalPost["post_image"] != null &&
                                      finalPost["post_image"]!.isNotEmpty,
                                  child: Container(
                                    width: double.maxFinite,
                                    constraints: const BoxConstraints(
                                      maxHeight: 500,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fitWidth,
                                        imageUrl: finalPost["post_image"]!,
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
                                SizedBox(
                                    height: finalPost["post_image"]!.isNotEmpty
                                        ? 7
                                        : 0),
                                // Bottom Icons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (!voteStateMap
                                                      .containsKey(postID) &&
                                                  widget.voteState == null) {
                                                voteStateMap[postID] = true;
                                                postStatsMap[postID]![
                                                    'total_votes'] += 1;
                                              }
                                            });
                                            pass.sendVote(
                                                postID: postID, upvote: true);
                                          },
                                          icon: FaIcon(
                                            voteStateMap[postID] == true ||
                                                    widget.voteState == true
                                                ? FontAwesomeIcons.solidThumbsUp
                                                : FontAwesomeIcons.thumbsUp,
                                          ),
                                          color: colorScheme.secondary,
                                        ),
                                        Text(
                                          formater.format(totalVotes),
                                          style: TextStyle(
                                              color: colorScheme.secondary),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (!voteStateMap
                                                      .containsKey(postID) &&
                                                  widget.voteState == null) {
                                                voteStateMap[postID] = false;
                                                postStatsMap[postID]![
                                                    'total_votes'] -= 1;
                                              }
                                            });
                                            pass.sendVote(
                                                postID: postID, upvote: false);
                                          },
                                          icon: FaIcon(
                                            voteStateMap[postID] == false ||
                                                    widget.voteState == false
                                                ? FontAwesomeIcons
                                                    .solidThumbsDown
                                                : FontAwesomeIcons.thumbsDown,
                                          ),
                                          color: colorScheme.secondary,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: FaIcon(
                                            FontAwesomeIcons.message,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                        Text(
                                          formater.format(totalComments),
                                          style: TextStyle(
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: FaIcon(
                                            color: colorScheme.secondary,
                                            FontAwesomeIcons.shareFromSquare,
                                          ),
                                        ),
                                        Text(
                                          'Send',
                                          style: TextStyle(
                                            color: colorScheme.secondary,
                                          ),
                                        ),
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
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
  }
}
