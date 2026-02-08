import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/staff_info_data.dart';
import 'package:holy_cross_app/models/admin_timetable_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

enum TimetableMode { classWise, staffWise }

class PrincipalTimetableScreen extends StatefulWidget {
  final TimetableMode mode;

  const PrincipalTimetableScreen({super.key, required this.mode});

  @override
  State<PrincipalTimetableScreen> createState() => _PrincipalTimetableScreenState();
}

class _PrincipalTimetableScreenState extends State<PrincipalTimetableScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffClass> _classes = [];
  List<StaffInfoData> _staffList = [];
  bool _isLoading = false;
  String? _selectedId;
  String? _selectedName;
  String? _timetableUrl;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      if (widget.mode == TimetableMode.classWise) {
        final response = await _apiClient.getPrincipalClasses(token);
        if (response.data['status'] == true) {
          final List list = response.data['result'] ?? [];
          setState(() {
            _classes = list.map((e) => StaffClass.fromJson(e)).toList();
          });
        }
      } else {
        final response = await _apiClient.getPrincipalStaffProfile(token);
        if (response.data['status'] == true) {
          final List list = response.data['result']?['lstofStaffInfo'] ?? [];
          setState(() {
            _staffList = list.map((e) => StaffInfoData.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTimetable(String id) async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = widget.mode == TimetableMode.classWise
          ? await _apiClient.getAdminClassTimetable(token, id)
          : await _apiClient.getAdminStaffTimetable(token, id);

      final adminResponse = AdminTimetableResponse.fromJson(response.data);
      if (adminResponse.status && adminResponse.result != null) {
        setState(() {
          _timetableUrl = adminResponse.result!.path;
        });
      } else {
        setState(() => _timetableUrl = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(adminResponse.message.isNotEmpty ? adminResponse.message : 'Timetable not found')),
        );
      }
    } catch (e) {
      debugPrint('Error fetching timetable: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == TimetableMode.classWise ? "Class Timetable" : "Staff Timetable"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _timetableUrl != null
                    ? _buildTimetable()
                    : const Center(child: Text("Select an option to view timetable")),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showSelectionDialog(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedName ?? (widget.mode == TimetableMode.classWise ? "Select Class" : "Select Staff"),
                style: TextStyle(
                  color: _selectedName != null ? Colors.black : Colors.grey,
                  fontSize: 16,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.mode == TimetableMode.classWise ? "Select Class" : "Select Staff"),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: widget.mode == TimetableMode.classWise
                ? ListView.separated(
                    itemCount: _classes.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = _classes[index];
                      return ListTile(
                        title: Text("${item.className} - ${item.sectionName}"),
                        onTap: () {
                          setState(() {
                            _selectedId = item.classId;
                            _selectedName = "${item.className} - ${item.sectionName}";
                          });
                          Navigator.pop(context);
                          _fetchTimetable(item.classId);
                        },
                      );
                    },
                  )
                : ListView.separated(
                    itemCount: _staffList.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = _staffList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: item.imagePath != null
                              ? CachedNetworkImageProvider(item.imagePath!)
                              : null,
                          child: item.imagePath == null ? const Icon(Icons.person) : null,
                        ),
                        title: Text(item.name ?? 'No Name'),
                        subtitle: Text(item.designation ?? ''),
                        onTap: () {
                          setState(() {
                            _selectedId = item.staffId;
                            _selectedName = item.name;
                          });
                          Navigator.pop(context);
                          _fetchTimetable(item.staffId!);
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTimetable() {
    return PhotoView(
      imageProvider: CachedNetworkImageProvider(_timetableUrl!),
      loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Failed to load timetable image"),
          ],
        ),
      ),
    );
  }
}
