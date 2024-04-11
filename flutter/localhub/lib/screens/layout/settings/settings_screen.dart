import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/api/version_check.dart';
import 'package:localhub/screens/layout/legal_screen.dart';
import 'package:localhub/themes/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDark = AppTheme.themeNotifier.value.brightness == Brightness.dark;
  TextEditingController _hostAddressController = TextEditingController();
  late String previousHostAddress;
  String? version;

  void _loadHostAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final String hostAddress = prefs.getString('hostaddress')!;
    previousHostAddress = hostAddress;
    setState(() {
      _hostAddressController = TextEditingController(text: hostAddress);
    });
  }

  bool _submited = false;
  String _errorText = "";

  Future<String> clearURL({required String url}) async {
    if (url.startsWith("https://")) {
      url = url.substring(8);
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  void _checkUrl() async {
    // validation
    if (_hostAddressController.text.isEmpty) {
      setState(() {
        _submited = true;
        _errorText = "Enter a valid url";
      });
      return;
    }

    // parse URL to URI
    final uri =
        Uri.tryParse("https://${clearURL(url: _hostAddressController.text)}") ??
            false;

    // URI validation
    if (uri == false) {
      setState(() {
        _submited = true;
        _errorText = "Enter a valid url";
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // skip save if same host address
    clearURL(url: _hostAddressController.text).then((value) async {
      if (previousHostAddress == value) {
        setState(() {
          _submited = false;
        });
        return;
      }
      // save hostaddress to storage
      await prefs.setString('hostaddress', value);
      setState(() {
        _submited = false;
      });
    });

    // check for api server status
    final VersionCheckApiService vcas = VersionCheckApiService();
    final String? versionFromApi = await vcas.versionCheck();

    // api server return status validation
    if (versionFromApi == null || versionFromApi.isEmpty) {
      setState(() {
        _submited = true;
        _errorText = "Host is down or not responding";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Server returned with response: ${versionFromApi.toString()}"),
        ),
      );
      return;
    } else if (versionFromApi.toString().contains("Failed")) {
      setState(() {
        _submited = true;
        _errorText = "Check the hostaddress";
        // undo the hostaddress change || fallback to previous hostaddress
        // _hostAddressController =
        //     TextEditingController(text: previousHostAddress);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Server returned with response: ${versionFromApi.toString()}"),
        ),
      );
      return;
    }
  }

  void _loadAppDetails() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
  }

  @override
  void initState() {
    AppTheme.initialize();
    super.initState();
    _loadHostAddress();
    _loadAppDetails();
  }

  @override
  void dispose() {
    _hostAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(
                  title: 'App Settings',
                  items: [
                    const SizedBox(
                      height: 10,
                    ),
                    _sectionItem(
                      height: _submited ? 100 : 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'HostAddress',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _hostAddressController,
                              decoration: InputDecoration(
                                  // label: const Text("HostAddress"),
                                  errorText: _submited ? _errorText : null,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  suffix: IconButton(
                                      onPressed: () {
                                        _checkUrl();
                                      },
                                      icon: const Icon(
                                          FontAwesomeIcons.solidFloppyDisk)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _sectionItem(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Theme',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Switch(
                            trackOutlineColor: MaterialStatePropertyAll(
                                colorScheme.secondaryContainer),
                            inactiveTrackColor: colorScheme.secondaryContainer,
                            activeTrackColor: colorScheme.secondaryContainer,
                            thumbColor:
                                MaterialStatePropertyAll(colorScheme.secondary),
                            value: isDark,
                            onChanged: (value) async {
                              setState(() {
                                isDark = !isDark;
                              });
                              await AppTheme.toggleBrightness();
                            },
                            thumbIcon: MaterialStatePropertyAll(
                              isDark
                                  ? Icon(
                                      FontAwesomeIcons.solidSun,
                                      color: colorScheme.onInverseSurface,
                                    )
                                  : Icon(
                                      FontAwesomeIcons.solidMoon,
                                      color: colorScheme.onInverseSurface,
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // const Divider(),
                    _sectionItem(
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Colors',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: colorScheme.outlineVariant,
                                      width: 1),
                                ),
                                child: DropdownButton<Color>(
                                  padding: const EdgeInsets.all(10),
                                  borderRadius: BorderRadius.circular(20),
                                  underline: Container(),
                                  value: AppTheme.currentColorSeed.color,
                                  icon: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      FontAwesomeIcons.angleDown,
                                      color: colorScheme.secondary,
                                    ),
                                  ),
                                  items: ColorSeed.values.map((colorSeed) {
                                    return DropdownMenuItem(
                                      value: colorSeed.color,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 10,
                                            backgroundColor: colorSeed.color,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(colorSeed.label),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (color) {
                                    AppTheme.selectColor(color!);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _section(
                  title: "About",
                  items: [
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ContentPolicyScreen(
                            toLoad: 'Content-Policy',
                          ), //pass the endpoint name case does not matters
                        ),
                      ),
                      child: _sectionItem(
                        child: Text(
                          'Content Policy',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        height: 50,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ContentPolicyScreen(
                            toLoad: 'Privacy-Policy',
                          ), //pass the endpoint name case does not matters
                        ),
                      ),
                      child: _sectionItem(
                        child: Text(
                          'Privacy Policy',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        height: 50,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ContentPolicyScreen(
                            toLoad: 'User-Agreement',
                          ), //pass the endpoint name case does not matters
                        ),
                      ),
                      child: _sectionItem(
                        child: Text(
                          'User Agreement',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        height: 50,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ContentPolicyScreen(
                            toLoad: 'Acknowledgement',
                          ), //pass the endpoint name case does not matters
                        ),
                      ),
                      child: _sectionItem(
                        child: Text(
                          'Acknowledgements',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        height: 50,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const Spacer(),
            Text("Version: $version"),
          ],
        ),
      ),
    );
  }

  Widget _section({String? title, final List<Widget>? items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          if (items != null)
            Column(
              children: items,
            ),
          const Divider()
        ],
      ),
    );
  }

  Widget _sectionItem({required child, required double height}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: double.maxFinite,
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: child,
        ),
      ),
    );
  }
}
