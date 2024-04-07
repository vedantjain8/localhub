import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:localhub/api/agenda_service.dart';
import 'package:localhub/api/upload_image_service.dart';
import 'package:localhub/widgets/custom_input_decoration.dart';

class CreateAgenda extends StatefulWidget {
  final bool isUpdating;
  final int? postID;
  const CreateAgenda({
    super.key,
    this.isUpdating = false,
    this.postID,
  });

  @override
  State<CreateAgenda> createState() => _CreateAgendaState();
}

class _CreateAgendaState extends State<CreateAgenda> {
  final TextEditingController _agendaTitleController = TextEditingController();
  final TextEditingController _agendaDescriptionController =
      TextEditingController();
  String? countryName;
  String? stateName;
  String? cityName;

  late bool locationSelected = true;

  late final DateTime _agendaStartDate;
  late final DateTime _agendaEndDate;
  late String _selectedDateText = "Select Date";

  final ImageUploadService ius = ImageUploadService();
  final AgendaApiService aas = AgendaApiService();

  XFile? pickedImage;
  final _picker = ImagePicker();

  Future<void> _openGallery() async {
    Navigator.of(context).pop();
    pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: pickedImage!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x4,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Banner Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        )
      ],
    );
    if (croppedImage != null) {
      pickedImage = XFile(croppedImage.path);
      setState(() {});
    }
  }

  Future<void> _openCamera() async {
    Navigator.of(context).pop();
    pickedImage = await _picker.pickImage(source: ImageSource.camera);
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: pickedImage!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x4,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Banner Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        )
      ],
    );
    if (croppedImage != null) {
      pickedImage = XFile(croppedImage.path);
      setState(() {});
    }
  }

  Map<String, dynamic> _journals = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _agendaTitleController.dispose();
    _agendaDescriptionController.dispose();
  }

  Future<Map<String, dynamic>> _createAgenda() async {
    // Upload image if pickedImage is not null
    String? imageUrl;
    if (pickedImage != null) {
      Map<String, dynamic>? uploadResult =
          await ius.uploadImageHTTP(File(pickedImage!.path));
      if (uploadResult['status'] != 200) {
        return {"status": 400};
      }
      imageUrl = uploadResult["response"];
    }

    // Create new post
    Map<String, dynamic> res = await aas.createAgenda(
        agendaTitle: _agendaTitleController.text,
        agendaDescription: _agendaDescriptionController.text,
        imageUrl: imageUrl,
        localityCity: cityName.toString(),
        localityState: stateName.toString(),
        localityCountry: countryName.toString(),
        agendaStartDate: _agendaStartDate,
        agendaEndDate: _agendaEndDate);
    return res;
  }

  void _showDateTimeRangePicker() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );

    if (result != null) {
      // Rebuild the UI
      setState(() {
        final selectedDateRange = result;
        _agendaStartDate = selectedDateRange.start;
        _agendaEndDate = selectedDateRange.end;
        _selectedDateText =
            '${DateFormat('dd/MM').format(_agendaStartDate)} to ${DateFormat('dd/MM').format(_agendaEndDate)}';
        print(selectedDateRange);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isUpdating = widget.isUpdating;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Agenda'),
        actions: [
          ElevatedButton(onPressed: _createAgenda, child: const Text('Post')),
          const SizedBox(width: 15)
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: pickedImage != null
          ? null
          : FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton.filled(
                                  onPressed: _openGallery,
                                  icon: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: FaIcon(FontAwesomeIcons.image),
                                  ),
                                  tooltip: 'Choose from gallery',
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text('Choose from gallery')
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton.filled(
                                  onPressed: _openCamera,
                                  icon: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: FaIcon(FontAwesomeIcons.camera),
                                  ),
                                  tooltip: 'click a image',
                                ),
                                const SizedBox(height: 10),
                                const Text('Choose from camera'),
                              ],
                            ),
                          ],
                        ),
                      );
                    });
              },
              shape: const CircleBorder(),
              child: const FaIcon(FontAwesomeIcons.upload),
            ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
                controller: _agendaTitleController,
                decoration: CustomInputDecoration.inputDecoration(
                  context: context,
                  label: 'Title',
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
                maxLines: 20,
                minLines: 1,
                controller: _agendaDescriptionController,
                decoration: CustomInputDecoration.inputDecoration(
                  context: context,
                  label: 'Description',
                  hintText: '(optional)',
                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: SizedBox(
                          height: 250, // Adjust the height as needed
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 30, right: 20, left: 20),
                              child: CSCPicker(
                                layout: Layout.vertical,
                                flagState: CountryFlag.DISABLE,
                                dropdownDecoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    width: 0.7,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                disabledDropdownDecoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    width: 0.7,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                onCountryChanged: (value) {
                                  setState(() {
                                    countryName = value;
                                  });
                                },
                                onStateChanged: (value) {
                                  setState(() {
                                    stateName = value;
                                  });
                                },
                                onCityChanged: (value) {
                                  setState(() {
                                    cityName = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Done'),
                          )
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  height: 65,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: locationSelected == true
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.error,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 13),
                      Icon(
                        FontAwesomeIcons.earthAmericas,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          countryName != null &&
                                  stateName != null &&
                                  cityName != null
                              ? '$countryName, $stateName, $cityName'
                              : 'Select Country, State, City',
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: locationSelected == true
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.error,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _showDateTimeRangePicker,
                    child: Text(_selectedDateText),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              pickedImage == null
                  ? Container()
                  : (isUpdating)
                      ? (_journals["post_image"].isEmpty)
                          ? Container()
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                fit: BoxFit.fitWidth,
                                imageUrl: _journals["post_image"]!,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
                                  child: CircularProgressIndicator(
                                      value: downloadProgress.progress),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Stack(
                            children: [
                              Image.file(
                                File(pickedImage!.path),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton.filledTonal(
                                  onPressed: () {
                                    setState(() {
                                      pickedImage = null;
                                    });
                                  },
                                  icon: const Icon(
                                    FontAwesomeIcons.minus,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
