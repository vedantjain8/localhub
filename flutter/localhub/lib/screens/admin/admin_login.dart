import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:localhub/api/user_service.dart";
import "package:localhub/screens/admin/admin_homepage.dart";
import "package:localhub/widgets/custom_input_decoration.dart";

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool showPass = false;
  final UserApiService uas = UserApiService();

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        );

                        await uas
                            .httpAdminLoginFun(
                                username: _usernameController.text,
                                password: _passwordController.text)
                            .then(
                              (Map<String, dynamic> data) => {
                                Navigator.pop(context),
                                if (data['response'] != null)
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Login successfull"),
                                      ),
                                    ),
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminHomepage(
                                          token: data['response'],
                                        ),
                                      ),
                                    )
                                  }
                                else if (data['error'] != null)
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(data['error']),
                                      ),
                                    ),
                                  }
                                // else
                                //   {
                                //     showDialog(
                                //       context: context,
                                //       builder: (BuildContext context) {
                                //         return AlertDialog(
                                //           title: const Text('Login Failed'),
                                //           content: const Text(
                                //               'Invalid username or password.'),
                                //           actions: [
                                //             TextButton(
                                //               onPressed: () =>
                                //                   Navigator.pop(context),
                                //               child: const Text('OK'),
                                //             ),
                                //           ],
                                //         );
                                //       },
                                //     )
                                //   }
                              },
                            );
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            colorScheme.primary),
                        fixedSize:
                            const MaterialStatePropertyAll(Size(150, 30))),
                    child: Text(
                      "Login",
                      style: TextStyle(color: colorScheme.onSecondary),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
