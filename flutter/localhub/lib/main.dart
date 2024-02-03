import 'package:flutter/material.dart';
import 'package:localhub/api/version_check.dart';
import 'package:localhub/auth/auth_service.dart';
import 'package:localhub/screens/authscreens/auth_screen.dart';
import 'package:localhub/screens/layout/app_layout.dart';
import 'package:localhub/themes/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
    // await prefs.setString('hostaddress', "192.168.29.16:3002");
    await prefs.setString('hostaddress', "o8oqubodf2.starling-tet.ts.net");
  }
}

_launchURL() async {
  final Uri url = Uri.parse(
      'https://drive.google.com/file/d/1Ky1rEFHGjvREMkXouabS3-DjXlEH0K3U/view?usp=drive_link');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

Future<void> checkAppVersion() async {
  final VersionCheckApiService vcas = VersionCheckApiService();
  final String? versionFromApi = await vcas.versionCheck();

  if (versionFromApi == null) {
    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text("server is down"),
          ),
        ),
      ),
    );
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
      runApp(MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: AlertDialog(
            title: const Text('New Update Available'),
            content: const Text(
                'New Update is available to download. Click update to download and install manually.'),
            actions: [
              TextButton(
                onPressed: () {
                  _launchURL();

                  // Navigator.pop(navigatorKey.currentContext!);
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ));
    } else {
      runApp(MainApp());
    }
  }
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
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
