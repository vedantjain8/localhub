import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localhub/api/community_service.dart';
import 'package:localhub/api/post_service.dart';
import 'package:localhub/api/upload_image_service.dart';
import 'package:localhub/screens/layout/app_layout.dart';
import 'package:localhub/widgets/custom_text_field_input.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postDescriptionController =
      TextEditingController();

  List<String> community = [];
  String selectedCommunity = "";

  late String imageUrl;

  final ImageUploadService ius = ImageUploadService();
  final PostApiService pas = PostApiService();
  final CommunityApiService cas = CommunityApiService();

  XFile? pickedImage;
  final _picker = ImagePicker();

  Future<void> _openGallery() async {
    Navigator.of(context).pop();
    pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {});
    }
  }

  Future<void> _openCamera() async {
    Navigator.of(context).pop();
    pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {});
    }
    // Navigator.pop(context);
  }

  Future<List<String>> _loadCommunityList(String? communityName) async {
    List<String> community = [];
    final List<Map<String, dynamic>> data =
        await cas.getCommunityList(communityName: communityName);

    for (var element in data) {
      community.add(element['community_name'] as String);
    }

    return community;
  }

  @override
  void initState() {
    super.initState();
    _loadCommunityList("");
  }

  @override
  void dispose() {
    super.dispose();
    _postTitleController.dispose();
    _postDescriptionController.dispose();
  }

  Future<Map<String, dynamic>> _createPost() async {
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
    Map<String, dynamic> res = await pas.createNewPost(
      communityName: selectedCommunity,
      postTitle: _postTitleController.text,
      postContent: _postDescriptionController.text,
      imageUrl: imageUrl,
    );
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                await _createPost().then(
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
              child: const Text('Next')),
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
                            IconButton.filled(
                              onPressed: _openGallery,
                              icon: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: FaIcon(FontAwesomeIcons.image),
                              ),
                              tooltip: 'Choose from gallery',
                            ),
                            IconButton.filled(
                              onPressed: _openCamera,
                              icon: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: FaIcon(FontAwesomeIcons.camera),
                              ),
                              tooltip: 'click a image',
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
              CustomTextFieldInput(
                hasPrefix: false,
                textEditingController: _postTitleController,
                textInputType: TextInputType.text,
                prefixIcon: const Icon(Icons.short_text_rounded),
                label: 'Title',
                hintText: '',
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextFieldInput(
                hasPrefix: false,
                textEditingController: _postDescriptionController,
                hintText: '(optional)',
                textInputType: TextInputType.text,
                prefixIcon: const Icon(Icons.notes_rounded),
                maxLines: 10,
                label: 'Description',
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  searchDelay: Duration(seconds: 3),
                  isFilterOnline: true,
                  showSelectedItems: true,
                ),
                asyncItems: (value) {
                  return _loadCommunityList(value);
                },
                clearButtonProps: const ClearButtonProps(
                  isVisible: true,
                ),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Select Community",
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      selectedCommunity = value;
                    }
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              pickedImage == null
                  ? Container()
                  : Image.file(File(pickedImage!.path))
            ],
          ),
        ),
      ),
    );
  }
}
