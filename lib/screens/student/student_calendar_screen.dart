import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';

class StudentCalendarScreen extends StatelessWidget {
  const StudentCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (value) {},
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'No events available yet.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
