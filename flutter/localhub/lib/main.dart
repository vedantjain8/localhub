import 'dart:math';
import 'package:flutter/material.dart';
import 'package:localhub/api/version_check.dart';
import 'package:localhub/auth/auth_service.dart';
import 'package:localhub/screens/authscreens/auth_screen.dart';
import 'package:localhub/screens/layout/app_layout.dart';
import 'package:localhub/screens/layout/settings/settings_screen.dart';
import 'package:localhub/themes/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeHostAddress();
  await AppTheme.initialize();
  await checkAppVersion();
  // runApp(MainApp());
}

Future<void> initializeHostAddress() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('hostaddress')) {
    await prefs.setString('hostaddress', "localhub.starlingnet.duckdns.org");
    // await prefs.setString('hostaddress', "localhub-flutter.duckdns.org:3002");
  }
}

_launchURL() async {
  final Uri url = Uri.parse('https://github.com/vedantjain8/localhub/releases');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

final List<String> serverDownText = [
  "Server is down",
  "This server is powered from lemon and two electrodes",
  "Be patient, the server's on a break, enjoying a well-deserved nap.",
];
final _random = Random();

Future<void> checkAppVersion() async {
  final VersionCheckApiService vcas = VersionCheckApiService();
  final String? versionFromApi = await vcas.versionCheck();

  if (versionFromApi == null) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    runApp(ValueListenableBuilder(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, theme, child) {
        return MaterialApp(
          theme: theme,
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/server_offline_logo.png',
                    height: 250,
                  ),
                  Text(
                    serverDownText[_random.nextInt(serverDownText.length)],
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          navigatorKey.currentState!.push(MaterialPageRoute(
                              builder: (context) => const SettingsScreen()));
                        },
                        child: const Icon(Icons.settings),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          checkAppVersion();
                        },
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ));
  } else {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    // String buildNumber = packageInfo.buildNumber;

    // print(versionFromApi); //0.1.0
    // print("=========");
    // print(appName); //localhub
    // print(packageName); //com.example.localhub
    // print(version); //0.1.0
    // print(buildNumber); //1

    if (version != versionFromApi) {
      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();
      runApp(
        ValueListenableBuilder(
          valueListenable: AppTheme.themeNotifier,
          builder: (context, theme, child) {
            return MaterialApp(
              theme: theme,
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: AlertDialog(
                  title: const Text('New Update Available'),
                  content: const Text(
                      'Click update to download the latest release and install it manually.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _launchURL();
                      },
                      child: const Text('Update'),
                    ),
                    TextButton(
                      onPressed: () {
                        navigatorKey.currentState!.push(MaterialPageRoute(
                            builder: (context) => const SettingsScreen()));
                      },
                      child: const Text('Settings'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      runApp(MainApp());
    }
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
