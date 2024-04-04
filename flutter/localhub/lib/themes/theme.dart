import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static String fontFamily = 'Montserrat';
  static const String _brightness = 'brightness';
  static const String _color = 'color';
  static const String _colorSeed = 'colorSeed'; // New variable for color seed
  static ValueNotifier<ThemeData> themeNotifier = ValueNotifier(ThemeData());
  static ColorSeed currentColorSeed = ColorSeed.values[0];

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColor = prefs.getString(_color);
    final savedBrightness = prefs.getString(_brightness);
    final savedColorSeed = prefs.getString(_colorSeed);

    currentColorSeed = savedColorSeed != null
        ? ColorSeed.values.firstWhere((seed) => seed.label == savedColorSeed)
        : ColorSeed.values[0];

    final theme = ThemeData(
      fontFamily: fontFamily,
      colorSchemeSeed: savedColor != null
          ? Color(int.parse(savedColor))
          : currentColorSeed.color,
      brightness:
          savedBrightness == 'light' ? Brightness.light : Brightness.dark,
    );
    themeNotifier.value = theme;
  }

  static Future<void> updateTheme(Color color, Brightness brightness) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_color, color.value.toString());
    await prefs.setString(
        _brightness, brightness == Brightness.dark ? 'dark' : 'light');
    await prefs.setString(_colorSeed, currentColorSeed.label);

    final updatedTheme = ThemeData(
      colorSchemeSeed: color,
      brightness: brightness,
      fontFamily: fontFamily,
    );
    themeNotifier.value = updatedTheme;
  }

  static Future<void> selectColor(Color color) async {
    final Brightness currentBrightness = themeNotifier.value.brightness;
    currentColorSeed =
        ColorSeed.values.firstWhere((seed) => seed.color == color);
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
        : currentColorSeed.color;

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
