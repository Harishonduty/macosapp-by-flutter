import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/common_gallery.dart';

class GalleryScreen extends StatefulWidget {
  final String? classId; // Optional classId for filtering (used by students)
  const GalleryScreen({super.key, this.classId});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ApiClient _apiClient = ApiClient();
  List<GalleryDateGroup> _groups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchGallery();
  }

  Future<void> _fetchGallery() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getGallery(token, widget.classId ?? '');
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _groups = list.map((e) => GalleryDateGroup.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching gallery: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Gallery'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? const Center(child: Text('No images found in gallery'))
              : ListView.builder(
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
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: group.items.length,
                          itemBuilder: (context, idx) {
                            final item = group.items[idx];
                            return GestureDetector(
                              onTap: () => _openGalleryItem(item),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _buildThumbnail(item),
                                    if (item.fileType == '2' || item.fileType == '3')
                                      const Center(
                                        child: Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _buildThumbnail(GalleryItem item) {
    if (item.fileType == '3') {
      // YouTube thumbnail
      final videoId = _extractYoutubeId(item.path);
      return Image.network(
        'https://img.youtube.com/vi/$videoId/0.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.video_library, color: Colors.grey),
      );
    }
    return Image.network(
      item.path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
    );
  }

  String _extractYoutubeId(String url) {
    final regExp = RegExp(r"v=([a-zA-Z0-9_-]+)");
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    return '';
  }

  void _openGalleryItem(GalleryItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: item.fileType == '1' 
                ? Image.network(item.path)
                : const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Video playback not implemented'),
                      ),
                    ),
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
