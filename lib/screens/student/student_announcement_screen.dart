import 'package:flutter/material.dart';
import 'package:holy_cross_app/models/announcement.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';

class StudentAnnouncementScreen extends StatefulWidget {
  const StudentAnnouncementScreen({super.key});

  @override
  State<StudentAnnouncementScreen> createState() => _StudentAnnouncementScreenState();
}

class _StudentAnnouncementScreenState extends State<StudentAnnouncementScreen> {
  final ApiClient _apiClient = ApiClient();
  List<Announcement> _announcements = [];
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
      await _updateViewStatus(); // Call view status update
      await _fetchAnnouncements();
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
      await _apiClient.updateAnnouncementViewStatus(token);
    } catch (_) {}
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

  Future<void> _fetchAnnouncements() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getAnnouncement(token, _studentId);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _announcements = list.map((e) => Announcement.fromJson(e)).toList();
          });
        } else {
            setState(() => _error = data['message'] ?? 'No announcements found');
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load announcements');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
              ? Center(child: Text(_error.isNotEmpty ? _error : 'No Announcements Found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _announcements.length,
                  itemBuilder: (context, index) {
                    final item = _announcements[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.announcement,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            ),
                            const SizedBox(height: 8),
                            if (item.dateFrom.isNotEmpty)
                              Text('Date: ${item.dateFrom}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
