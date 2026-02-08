import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_timetable.dart';

class StaffTimetableScreen extends StatefulWidget {
  const StaffTimetableScreen({super.key});

  @override
  State<StaffTimetableScreen> createState() => _StaffTimetableScreenState();
}

class _StaffTimetableScreenState extends State<StaffTimetableScreen> {
  final ApiClient _apiClient = ApiClient();
  StaffTimetable? _timetable;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStaffTimetable(token);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          setState(() {
            _timetable = StaffTimetable.fromJson(data['result']);
          });
        } else {
           setState(() => _error = data['message'] ?? 'Timetable not found');
        }
      }
    } catch (e) {
       setState(() => _error = 'Failed to load timetable');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Timetable'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _timetable == null || _timetable!.path.isEmpty
              ? Center(child: Text(_error.isNotEmpty ? _error : 'No Timetable Found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                       if(_timetable!.className.isNotEmpty)
                         Padding(
                           padding: const EdgeInsets.only(bottom: 16.0),
                           child: Text(
                             'Class: ${_timetable!.className}',
                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                           ),
                         ),
                       Expanded(
                         child: InteractiveViewer(
                           panEnabled: true,
                           boundaryMargin: const EdgeInsets.all(20),
                           minScale: 0.5,
                           maxScale: 4,
                           child: Image.network(
                             _timetable!.path,
                             loadingBuilder: (context, child, loadingProgress) {
                               if (loadingProgress == null) return child;
                               return const Center(child: CircularProgressIndicator());
                             },
                             errorBuilder: (context, error, stackTrace) {
                               return const Center(
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Icon(Icons.error_outline, size: 48, color: Colors.grey),
                                     SizedBox(height: 8),
                                     Text('Failed to load image'),
                                   ],
                                 ),
                               );
                             },
                           ),
                         ),
                       ),
                    ],
                  ),
                ),
    );
  }
}
