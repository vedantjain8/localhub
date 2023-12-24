import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final bool isLightMode;
  final String hintText;
  final TextInputType textInputType;
  final int maxlines;
  final bool hasPrefix;
  final Icon prefixIcon;
  const TextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    this.maxlines = 1,
    this.hasPrefix = false,
    this.isLightMode = false,
    required this.hintText,
    required this.textInputType,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: hasPrefix
          ? TextField(
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 4, color: Colors.blue),
                ),
                prefixIcon: prefixIcon,
              ),
            )
          : TextField(
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: null,
              ),
            ),
    );
  }
}
