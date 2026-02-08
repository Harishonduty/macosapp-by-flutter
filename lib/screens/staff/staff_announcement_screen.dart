import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_announcement.dart';

import 'package:holy_cross_app/screens/staff/add_staff_announcement_screen.dart';

class StaffAnnouncementScreen extends StatefulWidget {
  const StaffAnnouncementScreen({super.key});

  @override
  State<StaffAnnouncementScreen> createState() => _StaffAnnouncementScreenState();
}

class _StaffAnnouncementScreenState extends State<StaffAnnouncementScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffAnnouncement> _announcements = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStaffAnnouncements(token);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _announcements = list.map((e) => StaffAnnouncement.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
       // setState(() => _error = 'Failed to load announcements');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.announcement, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.date_range, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  'From: ${item.dateFrom}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.date_range, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  'To: ${item.dateTo}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStaffAnnouncementScreen()),
          );
          _fetchAnnouncements();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
