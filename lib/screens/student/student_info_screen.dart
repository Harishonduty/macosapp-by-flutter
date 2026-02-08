import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/student_details.dart';

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StudentDetails> _students = [];
  bool _isLoading = true;
  String _error = '';
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentDetails(token);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
           final List list = data['result'];
           setState(() {
             _students = list.map((e) => StudentDetails.fromJson(e)).toList();
           });
        } else if (data['message'] != null) {
           setState(() => _error = data['message']);
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load student details');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentPage < _students.length - 1) {
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Info'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _students.isEmpty
                  ? const Center(child: Text('No Student Details Found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildProfileHeader(_students[_currentPage]),
                          const SizedBox(height: 20),
                          _buildDetailsTable(_students[_currentPage]),
                        ],
                      ),
                    ),
      floatingActionButton: _students.length > 1
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentPage > 0)
                  FloatingActionButton(
                    heroTag: 'prev',
                    onPressed: _prevPage,
                    child: const Icon(Icons.navigate_before),
                  ),
                const SizedBox(width: 16),
                if (_currentPage < _students.length - 1)
                  FloatingActionButton(
                    heroTag: 'next',
                    onPressed: _nextPage,
                    child: const Icon(Icons.navigate_next),
                  ),
              ],
            )
          : null,
    );
  }

  Widget _buildProfileHeader(StudentDetails student) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: student.photoPath.isNotEmpty ? NetworkImage(student.photoPath) : null,
          child: student.photoPath.isEmpty
              ? const Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          student.firstName, // Assuming full name is in first name or composed
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        Text(
          '${student.className} | ${student.admissionNo}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDetailsTable(StudentDetails student) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow('Admission No', student.admissionNo),
            _buildDetailRow('Class Name', student.className),
            _buildDetailRow('Roll Number', student.rollNumber),
            _buildDetailRow('DOB', student.dob),
            _buildDetailRow('Blood Group', student.bloodGroupId),
            _buildDetailRow('Gender', student.genderName),
            _buildDetailRow('Father Name', student.fatherName),
            _buildDetailRow('Mother Name', student.motherName),
            _buildDetailRow('Father Mobile', student.fatherMobile),
            _buildDetailRow('Mother Mobile', student.motherMobile),
            _buildDetailRow('EMIS No', student.emisNo),
            _buildDetailRow('PEN No', student.penNo),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Address', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ),
            ),
            Text(student.permanentAddress, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
