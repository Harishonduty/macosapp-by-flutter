import 'package:flutter/material.dart';
import 'package:holy_cross_app/models/van_info.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';

class StudentVanInfoScreen extends StatefulWidget {
  const StudentVanInfoScreen({super.key});

  @override
  State<StudentVanInfoScreen> createState() => _StudentVanInfoScreenState();
}

class _StudentVanInfoScreenState extends State<StudentVanInfoScreen> {
  final ApiClient _apiClient = ApiClient();
  List<VanInfo> _vanInfos = [];
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
      await _fetchVanInfo();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Student ID not found';
      });
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

  Future<void> _fetchVanInfo() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getVanInfoByStudentId(token, _studentId);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _vanInfos = list.map((e) => VanInfo.fromJson(e)).toList();
          });
        } else {
            setState(() => _error = data['message'] ?? 'No van info found');
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load van info');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vanInfos.isEmpty
              ? Center(child: Text(_error.isNotEmpty ? _error : 'No Passenger Details Found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vanInfos.length,
                  itemBuilder: (context, index) {
                    final item = _vanInfos[index];
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
                            if (item.firstName?.isNotEmpty ?? false)
                                _buildInfoRow('Student:', item.firstName ?? ''),
                             _buildInfoRow('Place:', item.placeName ?? ''),
                             _buildInfoRow('Distance:', item.distance ?? ''),
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
