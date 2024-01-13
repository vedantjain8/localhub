import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localhub/widgets/text_field_input.dart';

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
  String? countryName;
  String? stateName;
  String? cityName;
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
              textEditingController: _usernameController,
              hintText: "Username",
              textInputType: TextInputType.text,
              prefixIcon: const Icon(Icons.person_rounded),
            ),
            const SizedBox(
              height: 30,
            ),
            TextFieldInput(
              hasPrefix: true,
              textEditingController: _emailController,
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
              textEditingController: _confirmPasswordController,
              hintText: "Confirm  Password",
              textInputType: TextInputType.text,
              prefixIcon: const Icon(Icons.lock_rounded),
              isPass: true,
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
                height: 56,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 13),
                    Icon(
                      Icons.public_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 7),
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
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(colorScheme.primary),
                fixedSize: MaterialStateProperty.all(const Size(150, 30)),
              ),
              child: Text(
                "Login",
                style: TextStyle(color: colorScheme.onSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
