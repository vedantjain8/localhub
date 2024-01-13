import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final bool isLightMode;
  final String hintText;
  final TextInputType textInputType;
  final int maxlines;
  final bool hasPrefix;
  final Icon prefixIcon;

  TextFieldInput({
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
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  bool showPass = false;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(
        color: colorScheme.onSurfaceVariant,
      ),
    );
    return TextField(
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
          ),
          border: inputBorder,
          focusedBorder: inputBorder,
          prefixIcon: widget.hasPrefix ? widget.prefixIcon : null,
          suffixIcon: widget.isPass
              ? InkWell(
                  onTap: () {
                    setState(() {
                      showPass = !showPass;
                    });
                  },
                  child: showPass
                      ? const Icon(Icons.visibility_off_rounded)
                      : const Icon(Icons.visibility_rounded),
                )
              : null),
      style:
          TextStyle(height: 1, color: Theme.of(context).colorScheme.onSurface),
      obscureText: widget.isPass && !showPass,
    );
  }
}
