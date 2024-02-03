import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static const String _brightness = 'brightness';
  static const String _color = 'color';
  static ValueNotifier<ThemeData> themeNotifier = ValueNotifier(ThemeData());

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColor = prefs.getString(_color);
    final savedBrightness = prefs.getString(_brightness);

    final theme = ThemeData(
      colorSchemeSeed: savedColor != null
          ? Color(int.parse(savedColor))
          : ColorSeed.values[0].color,
      brightness:
          savedBrightness == 'dark' ? Brightness.dark : Brightness.light,
    );
    themeNotifier.value = theme;
  }

  static Future<void> updateTheme(Color color, Brightness brightness) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_color, color.value.toString());
    await prefs.setString(
        _brightness, brightness == Brightness.dark ? 'dark' : 'light');

    final updatedTheme = ThemeData(
      colorSchemeSeed: color,
      brightness: brightness,
    );
    themeNotifier.value = updatedTheme;
  }

  static Future<void> selectColor(Color color) async {
    final Brightness currentBrightness = themeNotifier.value.brightness;
    await updateTheme(color, currentBrightness);
  }

  static Future<void> toggleBrightness() async {
    final prefs = await SharedPreferences.getInstance();
    final currentSeedColor = prefs.getString(_color);
    final currentBrightness = themeNotifier.value.brightness;
    final newBrightness = currentBrightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    final color = currentSeedColor != null
        ? Color(int.parse(currentSeedColor))
        : ColorSeed.values[0].color;

    await updateTheme(color, newBrightness);

  }
}

enum ColorSeed {
  blue('Blue', Colors.blue),
  indigo('Indigo', Colors.indigo),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.orange),
  deepOrange('Deep Orange', Colors.deepOrange),
  pink('Pink', Colors.pink);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}
