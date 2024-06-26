import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/auth/auth_service.dart';
import 'package:localhub/screens/layout/app_layout.dart';
import 'package:localhub/widgets/custom_input_decoration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool showPass = false;

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 5),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  } else if (value.length < 4 || value.length > 15) {
                    return 'Enter valid Username';
                  }
                  return null;
                },
                controller: _usernameController,
                decoration: CustomInputDecoration.inputDecoration(
                    context: context,
                    label: 'Username',
                    prefixIcon: const Icon(FontAwesomeIcons.solidUser)),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Correct Password';
                  } else if (value.length < 8) {
                    return 'Password length should be atleast 8 characters';
                  } else if (value.length > 32) {
                    return 'Password length should be atmost 32 characters';
                  }
                  return null;
                },
                controller: _passwordController,
                decoration: InputDecoration(
                    label: const Text('Password'),
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    prefixIcon: const Icon(FontAwesomeIcons.lock),
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          showPass = !showPass;
                        });
                      },
                      child: showPass
                          ? const Icon(FontAwesomeIcons.solidEye)
                          : const Icon(FontAwesomeIcons.solidEyeSlash),
                    )),
                obscureText: !showPass,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
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
                                        builder: (context) =>
                                            const AppLayout()),
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
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              }
                          },
                        );
                  }
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
      ),
    );
  }
}
