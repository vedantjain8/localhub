import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localhub/widgets/text_field_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextFieldInput(
              hasPrefix: true,
              textEditingController: _loginController,
              hintText: "E-Mail",
              textInputType: TextInputType.text,
              prefixIcon: const Icon(Icons.person_rounded),
            ),
            const SizedBox(
              height: 30,
            ),
            TextFieldInput(
              hasPrefix: true,
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
              textEditingController: _passwordController,
              hintText: "Password",
              textInputType: TextInputType.text,
              prefixIcon: const Icon(Icons.lock_rounded),
              isPass: true,
            ),
            const SizedBox(
              height: 30,
            ),
            TextFieldInput(
              hasPrefix: true,
              textEditingController: _passwordController,
              hintText: "Confirm  Password",
              textInputType: TextInputType.text,
              prefixIcon: const Icon(Icons.lock_rounded),
              isPass: true,
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(colorScheme.secondary),
                  fixedSize: const MaterialStatePropertyAll(Size(150, 30))),
              child: Text(
                "Login",
                style: TextStyle(color: colorScheme.onSecondary),
              ),
            )
          ],
        ),
      ),
    );
  }
}
