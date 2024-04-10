import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:localhub/functions/datetimeoperations.dart";
import "package:localhub/screens/layout/agenda/agenda_page.dart";
import "package:localhub/widgets/custom_shimmer.dart";

class AgendaScreen extends StatefulWidget {
  final List<Map<String, dynamic>> agendaList;
  const AgendaScreen({super.key, required this.agendaList});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  List<Map<String, dynamic>> agendaList = [];
  @override
  void initState() {
    super.initState();
    agendaList = widget.agendaList;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return (agendaList.isEmpty)
        ? const SingleChildScrollView(
            child: CustomShimmer(),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemCount: agendaList.length,
            itemBuilder: ((context, index) {
              return InkWell(
                onTap: () {
                  print(agendaList[index]["agenda_id"]);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AgendaPage(
                            agendaID: agendaList[index]["agenda_id"],
                          )));
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: colorScheme.onInverseSurface,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${dateFormat(agendaList[index]["agenda_start_date"])} - ${dateFormat(agendaList[index]["agenda_end_date"])}"),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Column(
                              children: [
                                Visibility(
                                  visible:
                                      agendaList[index]["image_url"] != null &&
                                          agendaList[index]["image_url"]!
                                              .isNotEmpty,
                                  child: SizedBox(
                                    height: 130,
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: agendaList[index]
                                            ["image_url"],
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
                              ],
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    agendaList[index]["agenda_title"],
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    agendaList[index]["agenda_description"],
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    agendaList[index]["locality_city"] +
                                        ", " +
                                        agendaList[index]["locality_state"] +
                                        ", " +
                                        agendaList[index]["locality_country"],
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow
                                        .ellipsis, // Set overflow property
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
  }
}
