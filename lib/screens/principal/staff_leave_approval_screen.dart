import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';

class StaffLeaveRequest {
  final String leaveId;
  final String staffName;
  final String dateFrom;
  final String dateTo;
  final String reason;
  final String status;
  final String requestDate;

  StaffLeaveRequest({
    required this.leaveId,
    required this.staffName,
    required this.dateFrom,
    required this.dateTo,
    required this.reason,
    required this.status,
    required this.requestDate,
  });

  factory StaffLeaveRequest.fromJson(Map<String, dynamic> json) {
    return StaffLeaveRequest(
      leaveId: json['LEAVE_ID']?.toString() ?? '',
      staffName: json['STAFF_NAME']?.toString() ?? '',
      dateFrom: json['DATE_FROM']?.toString() ?? '',
      dateTo: json['DATE_TO']?.toString() ?? '',
      reason: json['REASON']?.toString() ?? '',
      status: json['STATUS']?.toString() ?? 'Pending',
      requestDate: json['REQUEST_DATE']?.toString() ?? '',
    );
  }
}

class StaffLeaveApprovalScreen extends StatefulWidget {
  const StaffLeaveApprovalScreen({super.key});

  @override
  State<StaffLeaveApprovalScreen> createState() => _StaffLeaveApprovalScreenState();
}

class _StaffLeaveApprovalScreenState extends State<StaffLeaveApprovalScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffLeaveRequest> _requests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequests();
  }

  Future<void> _fetchLeaveRequests() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStaffLeaveRequests(token);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _requests = list.map((e) => StaffLeaveRequest.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching leave requests: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLeaveStatus(String leaveId, String status) async {
    try {
      final token = PreferenceService.getString('token');
      final data = {
        'LEAVE_ID': leaveId,
        'STATUS': status,
      };

      final response = await _apiClient.updateStaffLeaveStatus(token, data);
      if (response.data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Status updated")));
          _fetchLeaveRequests();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Failed to update")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Leave Requests'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No leave requests found'))
              : RefreshIndicator(
                  onRefresh: _fetchLeaveRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      request.staffName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: request.status == 'Approved' 
                                          ? Colors.green.withOpacity(0.2)
                                          : request.status == 'Rejected'
                                              ? Colors.red.withOpacity(0.2)
                                              : Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      request.status,
                                      style: TextStyle(
                                        color: request.status == 'Approved' 
                                            ? Colors.green
                                            : request.status == 'Rejected'
                                                ? Colors.red
                                                : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${request.dateFrom} to ${request.dateTo}', style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Reason: ${request.reason}'),
                              if (request.status == 'Pending') ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _updateLeaveStatus(request.leaveId, 'Rejected'),
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _updateLeaveStatus(request.leaveId, 'Approved'),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Approve'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
