import 'package:flutter/material.dart';

class CustomInputDecoration {
  static InputDecoration inputDecoration({
    String hintText = '',
    String label = '',
    String? errorText,
    prefixIcon,
    required context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(
        color: colorScheme.onSurfaceVariant,
      ),
    );

    return InputDecoration(
      hintText: hintText,
      label: Text(label),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
      ),
      border: inputBorder,
      focusedBorder: inputBorder,
      prefixIcon: prefixIcon,
      errorText: errorText,
      // prefixIcon: Icon(hasPrefix == false ? null : prefixIcon),
    );
  }
}
