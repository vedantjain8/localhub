import 'package:flutter/material.dart';

class CustomTextFieldInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final bool isLightMode;
  final String hintText;
  final String label;
  final TextInputType textInputType;
  final int maxLines;
  final bool hasPrefix;
  final Icon prefixIcon;

  const CustomTextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    this.maxLines = 1,
    this.hasPrefix = false,
    this.isLightMode = false,
    this.hintText = '',
    required this.label,
    required this.textInputType,
    required this.prefixIcon,
  });

  @override
  State<CustomTextFieldInput> createState() => _CustomTextFieldInputState();
}

class _CustomTextFieldInputState extends State<CustomTextFieldInput> {
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
      minLines: 1,
      maxLines: widget.maxLines,
      controller: widget.textEditingController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: widget.hintText,
          label: Text(widget.label),
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
