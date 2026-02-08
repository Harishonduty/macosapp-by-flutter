import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/leave_request.dart';

class StudentLeaveRequestScreen extends StatefulWidget {
  const StudentLeaveRequestScreen({super.key});

  @override
  State<StudentLeaveRequestScreen> createState() => _StudentLeaveRequestScreenState();
}

class _StudentLeaveRequestScreenState extends State<StudentLeaveRequestScreen> {
  final ApiClient _apiClient = ApiClient();
  List<LeaveRequest> _leaveRequests = [];
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
      await _fetchLeaveRequests();
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

  Future<void> _fetchLeaveRequests() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentLeaveRequests(token, _studentId);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
           final List list = data['result'];
           setState(() {
             _leaveRequests = list.map((e) => LeaveRequest.fromJson(e)).toList();
           });
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load leave requests');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _leaveRequests.isEmpty
                  ? const Center(child: Text('No Leave Requests Found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _leaveRequests.length,
                      itemBuilder: (context, index) {
                        final item = _leaveRequests[index];
                        final isApproved = item.approvalStatus == 'Approved';
                        final isRejected = item.approvalStatus == 'Rejected';
                        final statusColor = isApproved ? Colors.green : (isRejected ? Colors.red : Colors.orange);
                        
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Chip(
                                      label: Text(
                                        item.approvalStatus,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      backgroundColor: statusColor,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text('${item.dateFrom} - ${item.dateTo}'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.className,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement create leave request
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
