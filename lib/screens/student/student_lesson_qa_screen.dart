import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/gallery_date_group.dart';
import 'package:holy_cross_app/models/gallery_item.dart';

class StudentLessonQaScreen extends StatefulWidget {
  const StudentLessonQaScreen({super.key});

  @override
  State<StudentLessonQaScreen> createState() => _StudentLessonQaScreenState();
}

class _StudentLessonQaScreenState extends State<StudentLessonQaScreen> {
  final ApiClient _apiClient = ApiClient();
  List<GalleryDateGroup> _lessons = [];
  bool _isLoading = true;
  String _error = '';
  String _classId = '';
  String _studentName = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _fetchStudentDetails();
    if (_classId.isNotEmpty) {
      await _updateViewStatus();
      await _fetchLessons();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Class ID not found';
      });
    }
  }

  Future<void> _updateViewStatus() async {
    try {
      final token = PreferenceService.getString('token');
      // Using assignment view status as per Java activity logic
      await _apiClient.updateAssignmentViewStatus(token);
    } catch (_) {}
  }

  Future<void> _fetchStudentDetails() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentDetails(token);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          if (list.isNotEmpty) {
            _classId = list[0]['CLASS_ID']?.toString() ?? '';
            _studentName = list[0]['FIRST_NAME']?.toString() ?? '';
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching student details: $e');
    }
  }

  Future<void> _fetchLessons() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentLessonQa(token, _classId);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _lessons = list.map((e) => GalleryDateGroup.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load lessons');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Q&A'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _lessons.isEmpty
                  ? const Center(child: Text('No Lessons Found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _lessons.length,
                      itemBuilder: (context, index) {
                        final group = _lessons[index];
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
                                    child: _buildLessonItem(item),
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

  Widget _buildLessonItem(GalleryItem item) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading/Opening lesson is not implemented yet.')),
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
            const Icon(Icons.quiz, size: 40, color: Colors.blueAccent),
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
