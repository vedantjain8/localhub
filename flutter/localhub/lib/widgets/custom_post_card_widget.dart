import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/api/posts_stats_service.dart';
import 'package:localhub/functions/datetimeoperations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:localhub/screens/post/post_page.dart';

class CustomPostCardWidget extends StatefulWidget {
  final List<Map<String, dynamic>> journals;
  final bool hasMoreData;
  const CustomPostCardWidget(
      {super.key, required this.journals, required this.hasMoreData});

  @override
  State<CustomPostCardWidget> createState() => _CustomPostCardWidgetState();
}

class _CustomPostCardWidgetState extends State<CustomPostCardWidget> {
  bool pressedLike = false;
  bool pressedDislike = false;

  final PostStatsApiService pass = PostStatsApiService();

  Future<Map<String, dynamic>> _loadStats(int postID) async {
    final Map<String, dynamic> data = await pass.getPostStats(postID: postID);
    return data;
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

  @override
  Widget build(BuildContext context) {
    // return buildPostCardWidget(context, widget.journals, widget.hasMoreData);
    final formater = NumberFormat.compact(locale: "en_us", explicitSign: true);
    final colorScheme = Theme.of(context).colorScheme;
    List<Map<String, dynamic>> journals = widget.journals;
    bool hasMoreData = widget.hasMoreData;

    return (journals.isEmpty)
        ? const Center(child: Text("NO DATA FOUND"))
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: journals.length + 1,
            itemBuilder: (context, index) {
              if (index == journals.length) {
                if (hasMoreData == false) {
                  return const Center(
                    child: Text("No more data to load"),
                  );
                }
                return const CupertinoActivityIndicator();
              }

              final finalPost = journals[index];
              final postID = finalPost['post_id'];

              _loadStatsLazily(postID);

              Map<String, dynamic> stats = postStatsMap[postID] ?? {};

              // Extract like count and comment count from stats
              int totalVotes = stats['total_votes'] ?? 0;
              int totalComments = stats['total_comments'] ?? 0;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorScheme.background,
                ),
                width: double.maxFinite,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PostPage(postID: finalPost['post_id']),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  right: 6.0, bottom: 5.0),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(timeAgo(finalPost["created_at"])),
                            const Spacer(),
                            IconButton(
                                onPressed: () {},
                                icon: const FaIcon(
                                    FontAwesomeIcons.ellipsisVertical))
                          ],
                        ),
                        // Title
                        Text(
                          finalPost["post_title"],
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                        Visibility(
                          visible: finalPost["short_content"] != null,
                          child: Text(finalPost["short_content"]!),
                        ),
                        SizedBox(
                            height:
                                finalPost["short_content"]!.isNotEmpty ? 5 : 0),
                        Visibility(
                          visible: finalPost["post_image"] != null &&
                              finalPost["post_image"]!.isNotEmpty,
                          child: Container(
                            width: double.maxFinite,
                            constraints: const BoxConstraints(
                              maxHeight: 200,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                fit: BoxFit.fitWidth,
                                imageUrl: finalPost["post_image"]!,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
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
                            height:
                                finalPost["post_image"]!.isNotEmpty ? 7 : 0),
                        // Bottom Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    pass.sendVote(
                                        postID: finalPost['post_id'],
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
                                Text(formater.format(totalVotes)),
                                IconButton(
                                  onPressed: () {
                                    pass.sendVote(
                                        postID: finalPost['post_id'],
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
                                Text(formater.format(totalComments)),
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
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Divider(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
  }
}
