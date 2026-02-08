import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/notification_model.dart';

class StudentNotificationScreen extends StatefulWidget {
  const StudentNotificationScreen({super.key});

  @override
  State<StudentNotificationScreen> createState() => _StudentNotificationScreenState();
}

class _StudentNotificationScreenState extends State<StudentNotificationScreen> {
  final ApiClient _apiClient = ApiClient();
  List<NotificationModel> _notifications = [];
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
      // Update view status and fetch notifications
      await _updateViewStatus();
      await _fetchNotifications();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Student ID not found';
      });
    }
  }

  Future<void> _updateViewStatus() async {
    try {
      final token = PreferenceService.getString('token');
      await _apiClient.updateNotificationViewStatus(token);
    } catch (_) {
      // Ignore
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

  Future<void> _fetchNotifications() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getNotificationDetails(token, _studentId);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
           final List list = data['result'];
           setState(() {
             _notifications = list.map((e) => NotificationModel.fromJson(e)).toList();
           });
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load notifications');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _notifications.isEmpty
                  ? const Center(child: Text('No Notifications Found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.notifications, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.messageType,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    Text(
                                      item.dateTime,
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Text(item.message),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
