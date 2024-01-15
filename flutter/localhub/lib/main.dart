import 'package:flutter/material.dart';
import 'package:localhub/auth/auth_service.dart';
import 'package:localhub/screens/authscreens/auth_screen.dart';
import 'package:localhub/screens/layout/app_layout.dart';
import 'package:localhub/themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeHostAddress();
  await AppTheme.initialize();
  runApp(MainApp());
}

Future<void> initializeHostAddress() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('hostaddress')) {
    await prefs.setString('hostaddress', "192.168.29.16:3001");
  }
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, theme, child) {
        return MaterialApp(
          title: "Local Hub",
          theme: theme,
          debugShowCheckedModeBanner: false,
          home: Center(
            child: FutureBuilder(
              future: authService.isAuthenticated(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasData && snapshot.data == true) {
                  return const AppLayout();
                } else {
                  return const AuthScreen();
                }
              }),
            ),
          ),
        );
      },
    );
  }
}
