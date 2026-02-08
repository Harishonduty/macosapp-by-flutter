import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/gallery_date_group.dart';
import 'package:holy_cross_app/models/gallery_item.dart';

class StudentAssignmentReportScreen extends StatefulWidget {
  const StudentAssignmentReportScreen({super.key});

  @override
  State<StudentAssignmentReportScreen> createState() => _StudentAssignmentReportScreenState();
}

class _StudentAssignmentReportScreenState extends State<StudentAssignmentReportScreen> {
  final ApiClient _apiClient = ApiClient();
  List<GalleryDateGroup> _reportGroups = [];
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
      // Note: No view status update for report in Java code, or maybe I missed it?
      // Java code shows updateAssignmentViewStatus but it might be for assignment, not report.
      // Checking Java: updateAssignmentViewStatus() is called in StudentAssignmentReportActivity.java too.
      await _updateViewStatus();
      await _fetchReports();
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
      // Reusing assignment view status update as per Java Activity
      await _apiClient.updateAssignmentViewStatus(token);
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

  Future<void> _fetchReports() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentAssignmentReport(token, _studentId);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
           final List list = data['result'];
           setState(() {
             _reportGroups = list.map((e) => GalleryDateGroup.fromJson(e)).toList();
           });
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load assignment reports');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Report'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _reportGroups.isEmpty
                  ? const Center(child: Text('No Reports Found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reportGroups.length,
                      itemBuilder: (context, index) {
                        final group = _reportGroups[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                group.date,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: group.images.length,
                                itemBuilder: (context, imgIndex) {
                                  final item = group.images[imgIndex];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: _buildReportItem(item),
                                  );
                                },
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
    );
  }

  Widget _buildReportItem(GalleryItem item) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening ${item.galleryTitle} is not implemented yet.')),
        );
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 40, color: Colors.green),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                item.galleryTitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
