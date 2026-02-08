import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/student_attendance_data.dart';
import 'package:holy_cross_app/models/staff_remarks.dart';
import 'package:intl/intl.dart';

class AddStudentRemarksScreen extends StatefulWidget {
  const AddStudentRemarksScreen({super.key});

  @override
  State<AddStudentRemarksScreen> createState() => _AddStudentRemarksScreenState();
}

class _AddStudentRemarksScreenState extends State<AddStudentRemarksScreen> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  
  List<StaffClass> _classes = [];
  List<StudentAttendanceData> _students = [];
  List<RemarksType> _remarkTypes = [];

  StaffClass? _selectedClass;
  StudentAttendanceData? _selectedStudent;
  RemarksType? _selectedRemarkType;
  
  final _remarkController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
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

  Future<void> _fetchStudents() async {
    if (_selectedClass == null) return;
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
      final response = await _apiClient.getClassWiseStudentAttendance(token, today, _selectedClass!.classId);
      if (response.data['status'] == true) {
        final List list = response.data['result']['lstStudent'] ?? [];
        setState(() {
          _students = list.map((e) => StudentAttendanceData.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRemarkTypes() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getRemarksTypes(token);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _remarkTypes = list.map((e) => RemarksType.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching remark types: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRemark() async {
    if (!_formKey.currentState!.validate() || _selectedClass == null || _selectedStudent == null || _selectedRemarkType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      
      final remarkData = {
        'STUDENT_ID': _selectedStudent!.studentId,
        'SUBJECT_ID': '4', // Hardcoded in Java
        'REMARK': _remarkController.text.trim(),
        'REMARK_TYPE': _selectedRemarkType!.id,
        'ENTRY_ID': '',
        'ENTRY_DATE': '',
        'ACADEMIC_YEAR_ID': '2', // Hardcoded in Java
      };

      final response = await _apiClient.insertStudentRemarks(token, [remarkData]);
      if (response.data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'Remark added successfully'))
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'Failed to add remark'))
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding remark'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give Student Remark'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDropdown<StaffClass>(
                value: _selectedClass,
                label: 'Select Class',
                items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c.className))).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedClass = val;
                    _selectedStudent = null;
                    _students = [];
                  });
                  _fetchStudents();
                  if (_remarkTypes.isEmpty) _fetchRemarkTypes();
                },
              ),
              const SizedBox(height: 20),
              _buildDropdown<StudentAttendanceData>(
                value: _selectedStudent,
                label: 'Select Student',
                items: _students.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (val) {
                  setState(() => _selectedStudent = val);
                },
              ),
              const SizedBox(height: 20),
              _buildDropdown<RemarksType>(
                value: _selectedRemarkType,
                label: 'Remark Type',
                items: _remarkTypes.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
                onChanged: (val) {
                  setState(() => _selectedRemarkType = val);
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _remarkController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Remark / Reason',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter remark' : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRemark,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SUBMIT REMARK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items,
      onChanged: onChanged,
      validator: (val) => val == null ? 'Selection required' : null,
    );
  }
}
