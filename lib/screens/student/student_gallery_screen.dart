import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/gallery_date_group.dart';
import 'package:holy_cross_app/models/gallery_item.dart';

class StudentGalleryScreen extends StatefulWidget {
  const StudentGalleryScreen({super.key});

  @override
  State<StudentGalleryScreen> createState() => _StudentGalleryScreenState();
}

class _StudentGalleryScreenState extends State<StudentGalleryScreen> {
  final ApiClient _apiClient = ApiClient();
  List<GalleryDateGroup> _galleryGroups = [];
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
      await _fetchGallery();
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
      await _apiClient.updateGalleryViewStatus(token);
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

  Future<void> _fetchGallery() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getGalleryByStudentId(token, _studentId);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
           final List list = data['result'];
           setState(() {
             _galleryGroups = list.map((e) => GalleryDateGroup.fromJson(e)).toList();
           });
        } else if (data['message'] != null) {
           // Don't set error immediately if just empty, but here structure implies list
           setState(() => _error = data['message']);
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load gallery');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _galleryGroups.isEmpty
                  ? const Center(child: Text('No Images Found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _galleryGroups.length,
                      itemBuilder: (context, index) {
                        final group = _galleryGroups[index];
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
                                    child: _buildGalleryItem(item),
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

  Widget _buildGalleryItem(GalleryItem item) {
    // FileType 1=Image, 2=Video, 3=Youtube?
    // Based on Java code: 1 is image, 2 is video, 3 is youtube.
    bool isImage = item.fileType == '1';
    
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isImage
                ? Image.network(
                    item.path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                  )
                : Container(
                    color: Colors.black12,
                    child: const Icon(Icons.videocam, size: 40, color: Colors.grey),
                  ),
          ),
          if (!isImage)
            const Center(
              child: Icon(Icons.play_circle_outline, size: 40, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
