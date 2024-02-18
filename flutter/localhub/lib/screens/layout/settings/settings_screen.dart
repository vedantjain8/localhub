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
            Container(
                width: double.maxFinite,
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
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
                )),
            const Divider(),
            Container(
                width: double.maxFinite,
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Colors',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      PopupMenuButton<Color>(
                        onSelected: (color) async {
                          await AppTheme.selectColor(color);
                        },
                        icon: Icon(
                          FontAwesomeIcons.palette,
                          color: colorScheme.secondary,
                        ),
                        itemBuilder: (context) =>
                            ColorSeed.values.map((colorSeed) {
                          return PopupMenuItem(
                              value: colorSeed.color,
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    color: colorSeed.color,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(colorSeed.label),
                                ],
                              ));
                        }).toList(),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
