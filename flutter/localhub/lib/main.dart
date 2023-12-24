import 'package:flutter/material.dart';
import 'package:localhub/auth/auth_service.dart';
import 'package:localhub/screens/auth_screen.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Local Hub",
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Center(
        child: FutureBuilder(
          future: authService.isAuthenticated(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasData && snapshot.data == true) {
              // if logged in then this
              return const AuthScreen();
            } else {
              // if not logged in then this
              return const AuthScreen();
            }
          }),
        ),
      ),
    );
  }
}
