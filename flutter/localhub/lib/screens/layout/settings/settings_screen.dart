// todo: theme, hostaddress and submit, main.dart me server down aur update wali screen pe

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/themes/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDark = AppTheme.themeNotifier.value.brightness == Brightness.dark;

  @override
  void initState() {
    AppTheme.initialize();
    super.initState();
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
    return Container(
      width: double.maxFinite,
      height: 70,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: child,
      ),
    );
  }
}
