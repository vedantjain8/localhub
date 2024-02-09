import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localhub/api/post_service.dart';
import 'package:localhub/api/upload_image_service.dart';
import 'package:localhub/widgets/custom_text_field_input.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  TextEditingController _postTitleController = TextEditingController();
  TextEditingController _postDescriptionController = TextEditingController();
  late String imageUrl;

  final ImageUploadService ius = ImageUploadService();
  final PostApiService pas = PostApiService();

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

  @override
  void dispose() {
    super.dispose();
    _postTitleController.dispose();
    _postDescriptionController.dispose();
  }

  void _createPost() async {
    if (pickedImage != null) {
      Map<String, dynamic> imageUrl =
          await ius.uploadImageHTTP(File(pickedImage!.path));

      pas.createNewPost(
        communityName: "global",
        postTitle: _postTitleController.text,
        postContent: _postDescriptionController.text,
        imageUrl: imageUrl["link"],
      );
    }

    pas.createNewPost(
      communityName: "global",
      postTitle: _postTitleController.text,
      postContent: _postDescriptionController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                _createPost();

                Navigator.of(context).pop();
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
