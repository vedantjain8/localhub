import 'package:flutter/material.dart';
import 'package:localhub/auth/auth_service.dart';
import 'package:localhub/screens/layout/app_layout.dart';
import 'package:localhub/widgets/custom_text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 5),
            CustomTextFieldInput(
              hasPrefix: true,
              isPass: false,
              textEditingController: _usernameController,
              label: "Username",
              textInputType: TextInputType.text,
              prefixIcon: const Icon(Icons.person_rounded),
              hintText: '',
            ),
            const SizedBox(
              height: 30,
            ),
            CustomTextFieldInput(
              hasPrefix: true,
              textEditingController: _passwordController,
              label: "Password",
              textInputType: TextInputType.text,
              prefixIcon: const Icon(Icons.lock_rounded),
              isPass: true,
              hintText: '',
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                authService
                    .login(
                      username: _usernameController.text,
                      password: _passwordController.text,
                    )
                    .then(
                      (String? token) => {
                        Navigator.of(context).pop(),
                        if (token != null)
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Login successfull"),
                              ),
                            ),
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AppLayout()),
                                (route) => false)
                          }
                        else
                          {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Login Failed'),
                                  content: const Text(
                                      'Invalid username or password.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            )
                          }
                      },
                    );
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(colorScheme.primary),
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
