import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localhub/auth/auth_service.dart';
import 'package:localhub/screens/layout/app_layout.dart';
import 'package:localhub/widgets/custom_input_decoration.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late bool showPass = false;
  late bool showConfirmPass = false;

  String? countryName;
  String? stateName;
  String? cityName;

  final AuthService authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  late bool locationSelected = true;
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  void _locationSelected() {
    if (countryName == null || stateName == null || cityName == null) {
      setState(() {
        locationSelected = false;
      });
    } else {
      setState(() {
        locationSelected = true;
      });
    }
  }

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
                    return 'Please enter Username';
                  } else if (value.length < 4 || value.length > 15) {
                    return 'Username shoulg be 4-15 characters long';
                  } else if (!RegExp(r"^[a-zA-Z0-9_]*$").hasMatch(value)) {
                    return 'Enter valid Username';
                  }
                  return null;
                },
                controller: _usernameController,
                decoration: CustomInputDecoration.inputDecoration(
                    context: context,
                    label: 'Username',
                    prefixIcon: const Icon(FontAwesomeIcons.solidUser)),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter E-mail';
                  } else if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value)) {
                    return 'Enter valid E-mail';
                  }
                  return null;
                },
                controller: _emailController,
                decoration: CustomInputDecoration.inputDecoration(
                    context: context,
                    label: 'Email',
                    prefixIcon: const Icon(FontAwesomeIcons.solidEnvelope)),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Correct Password';
                  } else if (value.length < 8) {
                    return 'Password should be atleast 8 characters';
                  } else if (value.length > 32) {
                    return 'Password should be atmost 32 characters';
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
                  } else if (value != _passwordController.text) {
                    return 'Password do not match';
                  }
                  return null;
                },
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                    label: const Text('Confirm Password'),
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
                          showConfirmPass = !showConfirmPass;
                        });
                      },
                      child: showConfirmPass
                          ? const Icon(FontAwesomeIcons.solidEye)
                          : const Icon(FontAwesomeIcons.solidEyeSlash),
                    )),
                obscureText: !showConfirmPass,
              ),
              const SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: SizedBox(
                          height: 250, // Adjust the height as needed
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 30, right: 20, left: 20),
                              child: CSCPicker(
                                layout: Layout.vertical,
                                flagState: CountryFlag.DISABLE,
                                dropdownDecoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    width: 0.7,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                disabledDropdownDecoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    width: 0.7,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                onCountryChanged: (value) {
                                  setState(() {
                                    countryName = value;
                                  });
                                },
                                onStateChanged: (value) {
                                  setState(() {
                                    stateName = value;
                                  });
                                },
                                onCityChanged: (value) {
                                  setState(() {
                                    cityName = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Done'),
                          )
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  height: 65,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: locationSelected == true
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.error,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 13),
                      Icon(
                        FontAwesomeIcons.earthAmericas,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          countryName != null &&
                                  stateName != null &&
                                  cityName != null
                              ? '$countryName, $stateName, $cityName'
                              : 'Select Country, State, City',
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: locationSelected == true
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.error,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() == false ||
                      countryName == null ||
                      stateName == null ||
                      cityName == null) {
                    _locationSelected();
                  }
                  if (_formKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Center(child: CircularProgressIndicator());
                      },
                    );

                    authService
                        .register(
                          username: _usernameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          localityCountry: countryName!,
                          localityState: stateName!,
                          localityCity: cityName!,
                        )
                        .then(
                          (String? token) => {
                            Navigator.of(context).pop(),
                            if (token != null)
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Register Successfull"),
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
                                      title: const Text('Registration Failed'),
                                      content: const Text(
                                          'An error occurred during registration.'),
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
                      MaterialStateProperty.all<Color>(colorScheme.primary),
                  fixedSize: MaterialStateProperty.all(const Size(150, 30)),
                ),
                child: Text(
                  "Register",
                  style: TextStyle(color: colorScheme.onSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
