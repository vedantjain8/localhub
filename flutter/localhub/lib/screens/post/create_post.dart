import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localhub/api/community_service.dart';
import 'package:localhub/api/post_service.dart';
import 'package:localhub/api/upload_image_service.dart';
import 'package:localhub/screens/layout/app_layout.dart';
import 'package:localhub/widgets/custom_input_decoration.dart';

class CreatePost extends StatefulWidget {
  final bool isUpdating;
  final int? postID;
  const CreatePost({
    super.key,
    this.isUpdating = false,
    this.postID,
  });

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postDescriptionController =
      TextEditingController();

  List<String> community = [];
  String selectedCommunity = "";

  final ImageUploadService ius = ImageUploadService();
  final PostApiService pas = PostApiService();
  final CommunityApiService cas = CommunityApiService();

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

  Future<List<String>> _loadCommunityList(String? communityName) async {
    List<String> community = [];
    final List<Map<String, dynamic>> data =
        await cas.getCommunityList(communityName: communityName);

    for (var element in data) {
      community.add(element['community_name'] as String);
    }

    return community;
  }

  Map<String, dynamic> _journals = {};

  void _loadData(int postID) async {
    final List<Map<String, dynamic>> data =
        await pas.getPostById(postId: postID);

    setState(() {
      _journals = data[0];
    });

    _postDescriptionController.text = _journals['post_content'] as String;
    _postTitleController.text = _journals['post_title'] as String;
    pickedImage = _journals['post_image'] != null
        ? XFile(_journals['post_image'] as String)
        : null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isUpdating == true) {
      _loadData(widget.postID!);
    }
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
        imageUrl: imageUrl);
    return res;
  }

  Future<Map<String, dynamic>> _updatePost() async {
    String? imageUrl;
    if (pickedImage!.path == _journals['post_image']) {
      imageUrl = _journals['post_image'];
    } else if (pickedImage != null) {
      Map<String, dynamic>? uploadResult =
          await ius.uploadImageHTTP(File(pickedImage!.path));
      if (uploadResult['status'] != 200) {
        return {"status": 400};
      }
      imageUrl = uploadResult["response"];
    }

    // Create new post
    Map<String, dynamic> res = await pas.updatePost(
      postID: widget.postID!,
      postTitle: _postTitleController.text,
      postContent: _postDescriptionController.text,
      imageUrl: imageUrl,
    );
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isUpdating = widget.isUpdating;
    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdating ? "Update post" : 'Create Post'),
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

                if (widget.isUpdating == false) {
                  await _createPost().then(
                    (Map<String, dynamic> status) => {
                      Navigator.of(context).pop(),
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
                              content: Text(status['error']),
                            ),
                          ),
                        )
                    },
                  );
                }
                if (widget.isUpdating == true) {
                  await _updatePost().then(
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
                              content: Text(status['error']),
                            ),
                          ),
                        )
                    },
                  );
                }
              },
              child: Text(isUpdating ? 'Update' :'Post')),
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
                controller: _postTitleController,
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
                controller: _postDescriptionController,
                decoration: CustomInputDecoration.inputDecoration(
                  context: context,
                  label: 'Description',
                  hintText: '(optional)',
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(
                height: 20,
              ),
              (isUpdating == true)
                  ? Container()
                  : DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        searchFieldProps: TextFieldProps(
                          decoration: CustomInputDecoration.inputDecoration(
                            context: context,
                            label: 'Search',
                            prefixIcon:
                                const Icon(FontAwesomeIcons.magnifyingGlass),
                          ),
                        ),
                        menuProps: MenuProps(
                            backgroundColor: colorScheme.onInverseSurface,
                            borderRadius: BorderRadius.circular(30)),
                        showSearchBox: true,
                        searchDelay: const Duration(seconds: 1),
                        isFilterOnline: true,
                        showSelectedItems: true,
                      ),
                      asyncItems: (value) {
                        return _loadCommunityList(value);
                      },
                      clearButtonProps: const ClearButtonProps(
                        isVisible: true,
                      ),
                      dropdownButtonProps: const DropdownButtonProps(
                          icon: Icon(FontAwesomeIcons.caretDown)),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                            labelText: "Select Community",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20))),
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
                        )
            ],
          ),
        ),
      ),
    );
  }
}
