// todo: theme, hostaddress and submit, main.dart me server down aur update wali screen pe

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/api/version_check.dart';
import 'package:localhub/themes/theme.dart';
import 'package:localhub/widgets/custom_input_decoration.dart';
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
    final uri = Uri.tryParse("https://${_hostAddressController.text}") ?? false;

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
    if (previousHostAddress == _hostAddressController.text) {
      setState(() {
        _submited = false;
      });
      return;
    }
    // save hostaddress to storage
    await prefs.setString('hostaddress', _hostAddressController.text);
    setState(() {
      _submited = false;
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

  @override
  void initState() {
    AppTheme.initialize();
    super.initState();
    _loadHostAddress();
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
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Column(
              children: [
                _section(title: 'Theme Settings', items: [
                  // TODO: fix  this item when error message pops up
                  _sectionItem(
                    child: TextField(
                      controller: _hostAddressController,
                      decoration: CustomInputDecoration.inputDecoration(
                        context: context, label: ("HostAddress"),
                        errorText: _submited ? _errorText : null,
                        // hintText: 'hostaddress',
                      ),
                    ),
                  ),
                  _sectionItem(
                    child: ElevatedButton(
                      onPressed: () {
                        _checkUrl();
                      },
                      child: const Icon(Icons.save_rounded),
                    ),
                  ),
                  _sectionItem(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Theme',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Transform.scale(
                          scale: 1.3,
                          child: Switch(
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
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                  _sectionItem(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Colors',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Row(
                          children: [
                            DropdownButton<Color>(
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({title, final List<Widget>? items}) {
    return Column(
      children: [
        if (title != null) Text(title),
        if (items != null)
          Column(
            children: items,
          )
      ],
    );
  }

  Widget _sectionItem({required child}) {
    return SizedBox(
      width: double.maxFinite,
      height: 70,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: child,
      ),
    );
  }
}
