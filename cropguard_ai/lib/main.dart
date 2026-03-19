import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/upload_scan_screen.dart';
import 'screens/analysis_result_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/otp_screen.dart';

void main() {
  runApp(const CropGuardApp());
}

class CropGuardApp extends StatefulWidget {
  const CropGuardApp({super.key});

  static void setBrightness(BuildContext context, Brightness brightness) {
    _CropGuardAppState? state = context.findAncestorStateOfType<_CropGuardAppState>();
    state?.setBrightness(brightness);
  }

  @override
  State<CropGuardApp> createState() => _CropGuardAppState();
}

class _CropGuardAppState extends State<CropGuardApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void setBrightness(Brightness brightness) {
    setState(() {
      _themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cropguard AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/scan': (context) => const UploadScanScreen(),
        '/result': (context) => const AnalysisResultScreen(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
