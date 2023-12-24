import 'package:flutter/material.dart';
import 'package:localhub/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          TextFieldInput(
            hasPrefix: true, // displays prefix icon
            textEditingController: _loginController,
            hintText: "E-Mail",
            textInputType: TextInputType.text,
            prefixIcon: const Icon(Icons.email_rounded),
          ),
          const SizedBox(
            height: 30,
          ),
          TextFieldInput(
            hasPrefix: true,
            textEditingController: _loginController,
            hintText: "Password",
            textInputType: TextInputType.text,
            prefixIcon: const Icon(Icons.lock_rounded),
          ),
        ],
      ),
    );
  }
}
