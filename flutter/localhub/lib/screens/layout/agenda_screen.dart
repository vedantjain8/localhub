import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";

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
    // TODO: implement initState
    super.initState();
    agendaList = widget.agendaList;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: agendaList.length,
      itemBuilder: ((context, index) {
        return Container(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Visibility(
                visible: agendaList[index]["image_url"] != null &&
                    agendaList[index]["image_url"]!.isNotEmpty,
                child: Container(
                  width: double.maxFinite,
                  constraints: const BoxConstraints(
                    maxHeight: 500,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      fit: BoxFit.fitWidth,
                      imageUrl: agendaList[index]["image_url"],
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
              Text(agendaList[index]["agenda_title"]),
              Text(agendaList[index]["agenda_description"]),
              Text(agendaList[index]["locality_city"]),
              Text(agendaList[index]["locality_state"]),
              Text(agendaList[index]["locality_country"]),
            ],
          ),
        );
      }),
    );
  }
}
