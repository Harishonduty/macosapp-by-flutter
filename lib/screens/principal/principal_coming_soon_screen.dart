import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';

class PrincipalComingSoonScreen extends StatelessWidget {
  final String title;

  const PrincipalComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 100,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              "Work in Progress",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              "This feature is coming soon!",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Go Back", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
