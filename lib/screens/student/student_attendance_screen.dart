import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/attendance_list.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final ApiClient _apiClient = ApiClient();
  List<AttendanceList> _attendanceList = [];
  bool _isLoading = true;
  String _error = '';
  String _studentId = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _fetchStudentId();
    if (_studentId.isNotEmpty) {
      await _fetchAttendance();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Student ID not found';
      });
    }
  }

  Future<void> _fetchStudentId() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentDetails(token);
      if (response.statusCode == 200 && response.data != null) {
         final data = response.data;
         if (data['status'] == true && data['result'] != null) {
           final List list = data['result'];
           if (list.isNotEmpty) {
             _studentId = list[0]['STUDENT_ID']?.toString() ?? '';
           }
         }
      }
    } catch (e) {
      debugPrint('Error fetching student ID: $e');
    }
  }

  Future<void> _fetchAttendance() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentAttendance(token, _studentId);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
           final resultData = data['result'];
           if (resultData['SupStuAbsentLists'] != null) {
             final List list = resultData['SupStuAbsentLists'];
             setState(() {
               _attendanceList = list.map((e) => AttendanceList.fromJson(e)).toList();
             });
           }
        } else if (data['message'] != null) {
           setState(() => _error = data['message']);
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load attendance');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _attendanceList.isEmpty
                  ? const Center(child: Text('No Absent Records Found'))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Total Days Absent: ${_attendanceList.length}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _attendanceList.length,
                            itemBuilder: (context, index) {
                              final item = _attendanceList[index];
                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                    child: const Icon(Icons.close, color: Colors.red),
                                  ),
                                  title: Text(item.date),
                                  subtitle: Text('${item.sessionType} - ${item.remarks}'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
