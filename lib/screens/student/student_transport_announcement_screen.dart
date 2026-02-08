import 'package:flutter/material.dart';
import 'package:holy_cross_app/models/transport_announcement.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';

class StudentTransportAnnouncementScreen extends StatefulWidget {
  const StudentTransportAnnouncementScreen({super.key});

  @override
  State<StudentTransportAnnouncementScreen> createState() => _StudentTransportAnnouncementScreenState();
}

class _StudentTransportAnnouncementScreenState extends State<StudentTransportAnnouncementScreen> {
  final ApiClient _apiClient = ApiClient();
  List<TransportAnnouncement> _announcements = [];
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
      await _updateViewStatus();
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
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getTransportAnnouncement(token, _studentId);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _announcements = list.map((e) => TransportAnnouncement.fromJson(e)).toList();
            _error = '';
          });
        } else {
            setState(() {
                _announcements = [];
                _error = data['message'] ?? 'No announcements found';
            });
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
        title: const Text('Transport Announcement'),
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
                              item.vehicleName ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('Trip Name:', item.tripName ?? ''),
                            _buildInfoRow('Place Name:', item.placeName ?? ''),
                            _buildInfoRow('Two Way:', item.isTwoWay == '1' ? 'Yes' : 'No'),
                            const Divider(),
                            Text(
                              item.announcement ?? '',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
