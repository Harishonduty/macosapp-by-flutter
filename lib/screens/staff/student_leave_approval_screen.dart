import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/student_leave_request.dart';
import 'package:holy_cross_app/models/update_leave_status.dart';

class StudentLeaveApprovalScreen extends StatefulWidget {
  const StudentLeaveApprovalScreen({super.key});

  @override
  State<StudentLeaveApprovalScreen> createState() => _StudentLeaveApprovalScreenState();
}

class _StudentLeaveApprovalScreenState extends State<StudentLeaveApprovalScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StudentLeaveRequest> _requests = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentLeaveRequestsForApproval(token);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result']['lstOfStudents'] ?? [];
          setState(() {
            _requests = list.map((e) => StudentLeaveRequest.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
       // setState(() => _error = 'Failed to load requests');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(StudentLeaveRequest request, String statusId, String statusName) async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final updateData = UpdateLeaveStatus(
        requestId: request.requestId,
        name: request.name,
        className: request.className,
        dateFrom: request.dateFrom,
        dateTo: request.dateTo,
        classId: request.classId,
        statusId: statusId,
        status: statusName,
      );

      final response = await _apiClient.updateStudentLeaveStatus(token, updateData.toJson());
      if (response.data['status'] == true) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? 'Status updated')));
         }
         _fetchRequests();
      } else {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? 'Failed to update')));
         }
      }
    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error updating status')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Approvals'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(child: Text(_error.isNotEmpty ? _error : 'No Pending Requests'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final item = _requests[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.name, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(item.status),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.status,
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                             Text(
                              item.className,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                            ),
                             const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('From', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text(item.dateFrom, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('To', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text(item.dateTo, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('Reason:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(item.reason, style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 16),
                            if(item.status.toLowerCase() == 'pending')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _updateStatus(item, '3', 'Rejected'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('REJECT'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _updateStatus(item, '2', 'Approved'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('APPROVE'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
