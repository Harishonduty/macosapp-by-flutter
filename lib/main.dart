import 'package:flutter/material.dart';
import 'package:holy_cross_app/screens/splash_screen.dart';
import 'package:holy_cross_app/theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JOSEPHITES',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.white,
      ),
      home: const SplashScreen(),
    );
  }
}
