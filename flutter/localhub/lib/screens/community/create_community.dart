import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localhub/api/community_service.dart';
import 'package:localhub/api/upload_image_service.dart';
import 'package:localhub/screens/layout/app_layout.dart';
import 'package:localhub/widgets/custom_input_decoration.dart';

class CreateCommunity extends StatefulWidget {
  const CreateCommunity({super.key});

  @override
  State<CreateCommunity> createState() => _CreateCommunityState();
}

class _CreateCommunityState extends State<CreateCommunity> {
  final TextEditingController _communityNameController =
      TextEditingController();
  final TextEditingController _communityDescriptionController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late bool isLogoPicked = true;

  final ImageUploadService ius = ImageUploadService();
  final CommunityApiService cas = CommunityApiService();

  XFile? pickedLogo;
  XFile? pickedBanner;
  final _picker = ImagePicker();

  Future<void> _openGallery({required int forImage}) async {
    // 0 for logo
    // 1 for banner
    if (forImage == 0) {
      pickedLogo = await _picker.pickImage(source: ImageSource.gallery);
      CroppedFile? croppedLogo = await ImageCropper().cropImage(
        sourcePath: pickedLogo!.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Logo Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
          )
        ],
      );
      if (croppedLogo != null) {
        pickedLogo = XFile(croppedLogo.path);
        setState(() {});
      }
    } else if (forImage == 1) {
      pickedBanner = await _picker.pickImage(source: ImageSource.gallery);
      CroppedFile? croppedBanner = await ImageCropper().cropImage(
        sourcePath: pickedBanner!.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 1),
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
      if (croppedBanner != null) {
        pickedBanner = XFile(croppedBanner.path);
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _communityNameController.dispose();
    _communityDescriptionController.dispose();
  }

  Future<Map<String, dynamic>> _createCommunity() async {
    String logoUrl = "";
    String? bannerUrl;
    if (pickedLogo != null) {
      Map<String, dynamic> uploadLogoResult =
          await ius.uploadImageHTTP(File(pickedLogo!.path));
      logoUrl = uploadLogoResult["response"];
    }

    if (pickedBanner != null) {
      Map<String, dynamic>? uploadBannerResult =
          await ius.uploadImageHTTP(File(pickedBanner!.path));
      bannerUrl = uploadBannerResult["response"];
    }

    // Create new community
    Map<String, dynamic> res = await cas.createCommunity(
      communityName: _communityNameController.text,
      communityDescription: _communityDescriptionController.text,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
    );

    return res;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new community"),
        actions: [
          ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  if (pickedLogo == null) {
                    setState(() {
                      isLogoPicked = false;
                    });
                  }
                } else if (_formKey.currentState!.validate()) {
                  _createCommunity().then(
                    (Map<String, dynamic> status) => {
                      if (status['status'] != null)
                        {
                          if (status['status'] == 200)
                            {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(status['response']),
                                ),
                              ),
                              Navigator.of(context).pop(),
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AppLayout()),
                                  (route) => false),
                            }
                          else
                            (
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(status['response']),
                                ),
                              ),
                            )
                        }
                      else
                        (
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(status.toString()),
                            ),
                          ),
                        )
                    },
                  );
                }
              },
              child: const Text("Create"))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    InkWell(
                      onTap: () {
                          _openGallery(forImage: 1);
                      },
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      child: AspectRatio(
                        aspectRatio: 4 / 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: colorScheme.primaryContainer,
                          ),
                          child: pickedBanner == null
                              ? const Icon(FontAwesomeIcons.plus)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(pickedBanner!.path),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 70, left: 20),
                      child: Row(
                        children: [
                          CircleAvatar(
                              radius: 50,
                              backgroundColor: colorScheme.background,
                              child: InkWell(
                                onTap: () {
                                  _openGallery(forImage: 0);
                                },
                                overlayColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                child: pickedLogo == null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: isLogoPicked
                                              ? null
                                              : Border.all(
                                                  color: colorScheme.error),
                                          color: colorScheme.primaryContainer,
                                        ),
                                        width: 80,
                                        height: 80,
                                        child:
                                            const Icon(FontAwesomeIcons.plus),
                                      )
                                    : SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.file(
                                            File(pickedLogo!.path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                              )),
                          Visibility(
                            visible: !isLogoPicked,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  'Select a Logo',
                                  style: TextStyle(color: colorScheme.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Community Name';
                    } else if (!RegExp(r"^[a-zA-Z0-9_]*$").hasMatch(value)) {
                      return 'Enter valid Community Name';
                    }
                    return null;
                  },
                  controller: _communityNameController,
                  decoration: CustomInputDecoration.inputDecoration(
                      context: context, label: 'Community Name', hintText: ''),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  maxLines: 20,
                  minLines: 1,
                  controller: _communityDescriptionController,
                  decoration: CustomInputDecoration.inputDecoration(
                    context: context,
                    label: 'Community Description',
                    hintText: '(optional)',
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
