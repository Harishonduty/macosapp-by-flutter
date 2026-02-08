import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/time_table.dart';

class StudentTimeTableScreen extends StatefulWidget {
  const StudentTimeTableScreen({super.key});

  @override
  State<StudentTimeTableScreen> createState() => _StudentTimeTableScreenState();
}

class _StudentTimeTableScreenState extends State<StudentTimeTableScreen> {
  final ApiClient _apiClient = ApiClient();
  List<TimeTable> _timeTable = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchTimeTable();
  }

  Future<void> _fetchTimeTable() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentTimeTable(token);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['status'] == true && data['result'] != null) {
           final List<dynamic> list = data['result'];
           setState(() {
             _timeTable = list.map((e) => TimeTable.fromJson(e)).toList();
           });
        } else if (data is Map && data['message'] != null) {
           setState(() => _error = data['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to load timetable: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Table'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _timeTable.isEmpty
                  ? const Center(child: Text('No Timetable Found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _timeTable.length,
                      itemBuilder: (context, index) {
                        final item = _timeTable[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.day} - ${item.hour}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(item.className),
                                  ],
                                ),
                                const Divider(),
                                Text(
                                  item.subjectName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Staff ID: ${item.staffId}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
