import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
import 'dart:io';

enum AdminContentType { gallery, project, assignment }

class AddAdminContentScreen extends StatefulWidget {
  final AdminContentType contentType;
  const AddAdminContentScreen({super.key, required this.contentType});

  @override
  State<AddAdminContentScreen> createState() => _AddAdminContentScreenState();
}

class _AddAdminContentScreenState extends State<AddAdminContentScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  
  List<StaffClass> _classes = [];
  List<String> _selectedClassIds = [];
  String _fileType = '1'; // 1: Image, 2: Video, 3: YouTube URL
  File? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  String get _screenTitle {
    switch (widget.contentType) {
      case AdminContentType.gallery:
        return 'Add Gallery';
      case AdminContentType.project:
        return 'Add Project';
      case AdminContentType.assignment:
        return 'Add Assignment';
    }
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentClasses(token);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        _classes = list.map((e) => StaffClass.fromJson(e)).toList();
      }
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching classes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    /*
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
    */
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image selection disabled - package not available")));
  }

  Future<void> _pickVideo() async {
    /*
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
    */
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video selection disabled - package not available")));
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a title")));
      return;
    }
    if (_selectedClassIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one class")));
      return;
    }
    if (_fileType == '3' && _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter YouTube URL")));
      return;
    }
    if ((_fileType == '1' || _fileType == '2') && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a file")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final classIds = _selectedClassIds.join(', ');

      late final response;
      switch (widget.contentType) {
        case AdminContentType.gallery:
          response = await _apiClient.insertAdminGallery(
            token,
            title: _titleController.text.trim(),
            classIds: classIds,
            fileType: _fileType,
            filePath: _selectedFile?.path,
            youtubeUrl: _urlController.text.trim(),
          );
          break;
        case AdminContentType.project:
          response = await _apiClient.insertAdminProject(
            token,
            title: _titleController.text.trim(),
            classIds: classIds,
            fileType: _fileType,
            filePath: _selectedFile?.path,
            youtubeUrl: _urlController.text.trim(),
          );
          break;
        case AdminContentType.assignment:
          response = await _apiClient.insertAdminAssignment(
            token,
            title: _titleController.text.trim(),
            classIds: classIds,
            fileType: _fileType,
            filePath: _selectedFile?.path,
            youtubeUrl: _urlController.text.trim(),
          );
          break;
      }

      if (response.data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Saved successfully")));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Failed to save")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _classes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Select Classes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _classes.map((cls) {
                      final isSelected = _selectedClassIds.contains(cls.classId);
                      return FilterChip(
                        label: Text(cls.className),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
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
                  const SizedBox(height: 16),
                  const Text("File Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  RadioListTile<String>(
                    title: const Text("Image"),
                    value: '1',
                    groupValue: _fileType,
                    onChanged: (val) => setState(() {
                      _fileType = val!;
                      _selectedFile = null;
                    }),
                  ),
                  RadioListTile<String>(
                    title: const Text("Video"),
                    value: '2',
                    groupValue: _fileType,
                    onChanged: (val) => setState(() {
                      _fileType = val!;
                      _selectedFile = null;
                    }),
                  ),
                  RadioListTile<String>(
                    title: const Text("YouTube URL"),
                    value: '3',
                    groupValue: _fileType,
                    onChanged: (val) => setState(() {
                      _fileType = val!;
                      _selectedFile = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  if (_fileType == '1') ...[
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: Text(_selectedFile == null ? "Select Image" : "Image Selected"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_selectedFile != null) ...[
                      const SizedBox(height: 8),
                      Image.file(_selectedFile!, height: 150, fit: BoxFit.cover),
                    ],
                  ],
                  if (_fileType == '2') ...[
                    ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.video_library),
                      label: Text(_selectedFile == null ? "Select Video" : "Video Selected: ${_selectedFile!.path.split('/').last}"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                  if (_fileType == '3') ...[
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: "YouTube URL",
                        hintText: "https://www.youtube.com/watch?v=...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text("SUBMIT", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
