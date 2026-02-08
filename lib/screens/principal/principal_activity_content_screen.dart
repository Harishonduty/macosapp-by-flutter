import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/common_gallery.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/screens/principal/add_admin_content_screen.dart';

class PrincipalActivityContentScreen extends StatefulWidget {
  final AdminContentType contentType;

  const PrincipalActivityContentScreen({super.key, required this.contentType});

  @override
  State<PrincipalActivityContentScreen> createState() => _PrincipalActivityContentScreenState();
}

class _PrincipalActivityContentScreenState extends State<PrincipalActivityContentScreen> {
  final ApiClient _apiClient = ApiClient();
  List<GalleryDateGroup> _groups = [];
  List<StaffClass> _classes = [];
  List<String> _selectedClassIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  String get _screenTitle {
    switch (widget.contentType) {
      case AdminContentType.project:
        return 'Projects';
      case AdminContentType.assignment:
        return 'Assignments';
      default:
        return 'Content';
    }
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentClasses(token);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _classes = list.map((e) => StaffClass.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchContent() async {
    if (_selectedClassIds.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final classIds = _selectedClassIds.join(', ');
      
      late final dynamic response;
      if (widget.contentType == AdminContentType.assignment) {
        response = await _apiClient.getAdminStudentAssignment(token, classIds);
      } else if (widget.contentType == AdminContentType.project) {
        response = await _apiClient.getAdminStudentProject(token, classIds);
      }

      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _groups = list.map((e) => GalleryDateGroup.fromJson(e)).toList();
        });
      } else {
        setState(() => _groups = []);
      }
    } catch (e) {
      debugPrint('Error fetching content: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showClassSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Classes"),
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  children: _classes.map((cls) {
                    final isSelected = _selectedClassIds.contains(cls.classId);
                    return FilterChip(
                      label: Text(cls.className),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            _selectedClassIds.add(cls.classId);
                          } else {
                            _selectedClassIds.remove(cls.classId);
                          }
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.3),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _fetchContent();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text("DONE"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showClassSelectionDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedClassIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Showing results for ${(_classes.where((c) => _selectedClassIds.contains(c.classId)).map((c) => c.className).join(', '))}",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _groups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              _selectedClassIds.isEmpty 
                                  ? "Select a class to view $_screenTitle" 
                                  : "No $_screenTitle found for selected classes",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            if (_selectedClassIds.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: ElevatedButton(
                                  onPressed: _showClassSelectionDialog,
                                  child: const Text("Select Class"),
                                ),
                              ),
                          ],
                        ),
                      )
                    : _buildContentList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAdminContentScreen(contentType: widget.contentType),
            ),
          );
          if (result == true) {
            _fetchContent();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                group.date,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: group.items.length,
              itemBuilder: (context, idx) {
                final item = group.items[idx];
                return _buildContentCard(item);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildContentCard(GalleryItem item) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openContent(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildThumbnail(item),
                  if (item.fileType == '2' || item.fileType == '3')
                    const Center(
                      child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.galleryTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      "By: ${item.staffName}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(GalleryItem item) {
    if (item.fileType == '3') {
      final videoId = _extractYoutubeId(item.path);
      return Image.network(
        'https://img.youtube.com/vi/$videoId/0.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.video_library, color: Colors.grey),
      );
    }
    // For images, we try to use the path. For other files, we might need an icon.
    final ext = item.path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      return Image.network(
        item.path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
      );
    } else {
      return Container(
        color: Colors.grey[200],
        child: Icon(
          item.fileType == '2' ? Icons.video_library : Icons.insert_drive_file,
          color: AppColors.primary,
          size: 40,
        ),
      );
    }
  }

  String _extractYoutubeId(String url) {
    final regExp = RegExp(r"v=([a-zA-Z0-9_-]+)");
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    return '';
  }

  void _openContent(GalleryItem item) {
    // Basic implementation: show title and path
    // In a real app, this would open a viewer for image/video/PDF
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.galleryTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text("Posted by: ${item.staffName}"),
            Text("Date: ${item.entryDate}"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Implement file opening logic
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text("Open Content"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
