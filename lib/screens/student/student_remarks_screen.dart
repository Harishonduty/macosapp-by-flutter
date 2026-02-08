import 'package:flutter/material.dart';
import 'package:holy_cross_app/models/student_remark.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';

class StudentRemarksScreen extends StatefulWidget {
  const StudentRemarksScreen({super.key});

  @override
  State<StudentRemarksScreen> createState() => _StudentRemarksScreenState();
}

class _StudentRemarksScreenState extends State<StudentRemarksScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StudentRemark> _remarks = [];
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
      await _fetchRemarks();
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

  Future<void> _fetchRemarks() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentRemarks(token, _studentId);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _remarks = list.map((e) => StudentRemark.fromJson(e)).toList();
          });
        } else {
            setState(() => _error = data['message'] ?? 'No remarks found');
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load remarks');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remarks'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _remarks.isEmpty
              ? Center(child: Text(_error.isNotEmpty ? _error : 'No Remarks Found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _remarks.length,
                  itemBuilder: (context, index) {
                    final item = _remarks[index];
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
                              children: [
                                Expanded(
                                  child: Text(
                                    item.subjectName.isNotEmpty ? item.subjectName : 'General',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                  ),
                                ),
                                Text(
                                  item.entryDate,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                            if (item.staffName.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text('By: ${item.staffName}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                                ),
                            const Divider(),
                            Text(
                              item.remark,
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
