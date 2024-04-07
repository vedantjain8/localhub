import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:localhub/api/agenda_service.dart";
import "package:localhub/functions/datetimeoperations.dart";
import "package:localhub/widgets/custom_shimmer.dart";

class AgendaPage extends StatefulWidget {
  const AgendaPage({
    super.key,
    required this.agendaID,
  });
  final int agendaID;

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final AgendaApiService aas = AgendaApiService();
  List<Map<String, dynamic>> _journals = [];

  void _loadData() async {
    int agendaID = widget.agendaID;
    print("agendaID: $agendaID");

    final List<Map<String, dynamic>> data =
        await aas.getAgendaById(agendaId: agendaID);
    print("data: $data");

    setState(() {
      _journals = data;
    });
    // finalagenda = _journals[agendaID];
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: (_journals.isEmpty)
          ? const SingleChildScrollView(
              child: CustomShimmer(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: colorScheme.onInverseSurface,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "${dateFormat(_journals[0]["agenda_start_date"])} - ${dateFormat(_journals[0]["agenda_end_date"])}"),
                      const SizedBox(height: 10),
                      Text(
                        _journals[0]["agenda_title"],
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 10),
                      Visibility(
                          visible: _journals[0]["agenda_description"] != null &&
                              _journals[0]["agenda_description"]!.isNotEmpty,
                          child: MarkdownBody(
                            data: _journals[0]["agenda_description"],
                          )
                          // Text(
                          //   _journals[0]["agenda_description"],
                          //   style: Theme.of(context).textTheme.titleMedium,
                          // ),
                          ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            _journals[0]["locality_city"] + ", ",
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            _journals[0]["locality_state"] + ", ",
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            _journals[0]["locality_country"],
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Visibility(
                        visible: _journals[0]["image_url"] != null &&
                            _journals[0]["image_url"]!.isNotEmpty,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: _journals[0]["image_url"],
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
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
