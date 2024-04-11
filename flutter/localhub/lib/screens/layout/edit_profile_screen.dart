import "package:cached_network_image/cached_network_image.dart";
import "package:csc_picker/csc_picker.dart";
import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";
import "package:localhub/api/about_user_service.dart";
import "package:localhub/api/upload_image_service.dart";
import "package:localhub/widgets/custom_input_decoration.dart";
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AboutUserApiService auas = AboutUserApiService();
  final ImageUploadService ius = ImageUploadService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Map<String, dynamic> meJournal = {};

  String? countryName;
  String? stateName;
  String? cityName;
  late bool locationSelected = true;

  XFile? pickedImage;
  final _picker = ImagePicker();

  void _loadMeData() async {
    Map<String, dynamic> data = await auas.aboutUserData();
    if (mounted) {
      setState(() {
        meJournal = data['response'];
      });
      _usernameController.text = meJournal['username'] as String;
      _bioController.text = meJournal['bio'] as String;
      countryName = meJournal['locality_country'];
      stateName = meJournal['locality_state'];
      cityName = meJournal['locality_city'];
    }
  }

  Future<void> _openGallery() async {
    Navigator.of(context).pop();
    pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: pickedImage!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
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
        CropAspectRatioPreset.square,
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

  Future<Map<String, dynamic>> _updateProfile(
      {required String password}) async {
    String? imageUrl;
    if (pickedImage?.path != null) {
      if (pickedImage!.path == meJournal['avatar_url']) {
        imageUrl = meJournal['avatar_url'];
      } else if (pickedImage != null) {
        Map<String, dynamic>? uploadResult =
            await ius.uploadImageHTTP(File(pickedImage!.path));
        if (uploadResult['status'] != 200) {
          return {"status": 400};
        }
        imageUrl = uploadResult["response"];
      }
    } else {
      imageUrl = meJournal['avatar_url'];
    }

    Map<String, dynamic> res = await auas.updateUser(
      password: password,
      username: _usernameController.text.toString() ==
              meJournal['username'].toString()
          ? null
          : _usernameController.text,
      bio: _bioController.text,
      avatarurl: imageUrl,
      localitycity: cityName,
      localitystate: stateName,
      localitycountry: countryName,
    );
    return res;
  }

  @override
  void initState() {
    _loadMeData();

    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: meJournal.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(3.0),
              child: Column(
                children: [
                  CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.background,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton.filled(
                                            onPressed: _openGallery,
                                            icon: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: FaIcon(
                                                  FontAwesomeIcons.image),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton.filled(
                                            onPressed: _openCamera,
                                            icon: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: FaIcon(
                                                  FontAwesomeIcons.camera),
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
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                        child: pickedImage == null
                            ? CircleAvatar(
                                radius: 45,
                                backgroundImage: CachedNetworkImageProvider(
                                  meJournal["avatar_url"],
                                ),
                              )
                            : SizedBox(
                                width: 80,
                                height: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.file(
                                    File(pickedImage!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      )),
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
                    controller: _usernameController,
                    decoration: CustomInputDecoration.inputDecoration(
                      context: context,
                      label: 'Username',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _bioController,
                    decoration: CustomInputDecoration.inputDecoration(
                      context: context,
                      label: 'Bio',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
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
                                    currentCity:
                                        meJournal['locality_city'] ?? '',
                                    currentState:
                                        meJournal['locality_state'] ?? '',
                                    currentCountry:
                                        meJournal['locality_country'] ?? '',
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
                              '$countryName, $stateName, $cityName',
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
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Enter Password'),
                            content: TextFormField(
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                              controller: _passwordController,
                              decoration: CustomInputDecoration.inputDecoration(
                                context: context,
                                label: 'Password',
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  _updateProfile(
                                          password: _passwordController.text)
                                      .then((value) {
                                    Navigator.pop(context);
                                    if (value['error'] != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(value['error']),
                                        ),
                                      );
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(value['response']),
                                      ),
                                    );
                                  });
                                },
                                child: const Text('Submit'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text("Update profile"),
                  ),
                ],
              ),
            ),
    );
  }
}
