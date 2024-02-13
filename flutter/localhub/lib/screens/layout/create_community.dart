// ++++++++++++++++++++++++++
// TODO:
// - UI
// - logo image is required field, also add validation for that
// ++++++++++++++++++++++++++

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localhub/api/community_service.dart';
import 'package:localhub/api/upload_image_service.dart';
import 'package:localhub/screens/layout/app_layout.dart';
import 'package:localhub/widgets/custom_text_field_input.dart';

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
      if (pickedLogo != null) {
        setState(() {});
      }
    } else if (forImage == 1) {
      pickedBanner = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedBanner != null) {
        setState(() {});
      }
    }
  }

  Future<void> _openCamera({required int forImage}) async {
    // 0 for logo
    // 1 for banner
    if (forImage == 0) {
      pickedLogo = await _picker.pickImage(source: ImageSource.camera);
      if (pickedLogo != null) {
        setState(() {});
      }
    } else if (forImage == 1) {
      pickedBanner = await _picker.pickImage(source: ImageSource.camera);
      if (pickedBanner != null) {
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
      logoUrl = uploadLogoResult["link"];
    }

    if (pickedBanner != null) {
      Map<String, dynamic>? uploadBannerResult =
          await ius.uploadImageHTTP(File(pickedBanner!.path));
      bannerUrl = uploadBannerResult["link"];
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new community"),
        actions: [
          ElevatedButton(
              onPressed: () {
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
                          const SnackBar(
                            content: Text("some error"),
                          ),
                        ),
                      )
                  },
                );
              },
              child: const Text("Next"))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFieldInput(
                textEditingController: _communityNameController,
                label: "Community Name",
                textInputType: TextInputType.text,
                prefixIcon: const Icon(Icons.groups_rounded),
                hasPrefix: false,
                hintText: "",
              ),
              CustomTextFieldInput(
                textEditingController: _communityDescriptionController,
                label: "Community Description",
                textInputType: TextInputType.text,
                prefixIcon: const Icon(Icons.groups_rounded),
                hasPrefix: false,
                hintText: "",
              ),
              ElevatedButton(
                  onPressed: () {
                    _openGallery(forImage: 0);
                  },
                  child: const Text("select logo")),
              ElevatedButton(
                  onPressed: () {
                    _openGallery(forImage: 1);
                  },
                  child: const Text("select banner")),
              pickedLogo == null
                  ? Container()
                  : Image.file(File(pickedLogo!.path)),
              pickedBanner == null
                  ? Container()
                  : Image.file(File(pickedBanner!.path))
            ],
          ),
        ),
      ),
    );
  }
}
