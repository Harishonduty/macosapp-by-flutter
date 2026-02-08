import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/gallery_date_group.dart';
import 'package:holy_cross_app/models/gallery_item.dart';

class StudentProjectScreen extends StatefulWidget {
  const StudentProjectScreen({super.key});

  @override
  State<StudentProjectScreen> createState() => _StudentProjectScreenState();
}

class _StudentProjectScreenState extends State<StudentProjectScreen> {
  final ApiClient _apiClient = ApiClient();
  List<GalleryDateGroup> _projects = [];
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
      await _fetchProjects();
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
      await _apiClient.updateProjectViewStatus(token);
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

  Future<void> _fetchProjects() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentProject(token, _classId);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _projects = list.map((e) => GalleryDateGroup.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load projects');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _projects.isEmpty
                  ? const Center(child: Text('No Projects Found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _projects.length,
                      itemBuilder: (context, index) {
                        final group = _projects[index];
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
                                    child: _buildProjectItem(item),
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

  Widget _buildProjectItem(GalleryItem item) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading/Opening project is not implemented yet.')),
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
            const Icon(Icons.lightbulb, size: 40, color: Colors.deepPurple),
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
