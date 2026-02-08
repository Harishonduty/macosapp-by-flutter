import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/student_exam_details.dart';
import 'package:holy_cross_app/models/student_attendance_data.dart';
import 'package:holy_cross_app/models/staff_exam_mark.dart';
import 'package:holy_cross_app/screens/staff/exam_mark_entry_screen.dart';
import 'package:intl/intl.dart';

class ExamMarkListScreen extends StatefulWidget {
  const ExamMarkListScreen({super.key});

  @override
  State<ExamMarkListScreen> createState() => _ExamMarkListScreenState();
}

class _ExamMarkListScreenState extends State<ExamMarkListScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffClass> _classes = [];
  List<StudentExamDetails> _exams = [];
  List<StudentAttendanceData> _students = [];
  List<StaffExamMark> _marks = [];

  StaffClass? _selectedClass;
  StudentExamDetails? _selectedExam;
  StudentAttendanceData? _selectedStudent;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
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

  Future<void> _fetchExams() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getExamTypes(token);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _exams = list.map((e) => StudentExamDetails.fromJson(e['objExamCretate'])).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching exams: $e');
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

  Future<void> _fetchMarks() async {
    if (_selectedClass == null || _selectedExam == null || _selectedStudent == null) return;
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      
      String acYear = '';
      try {
        final examDate = DateFormat('M/d/yyyy h:mm:ss a').parse(_selectedExam!.dateFrom);
        acYear = DateFormat('yyyy').format(examDate);
      } catch (e) {
        acYear = DateTime.now().year.toString();
      }

      final params = {
        'STUDENT_ID': _selectedStudent!.studentId,
        'EXAM_ID': _selectedExam!.examId,
        'CLASS_ID': _selectedClass!.classId,
        'AC_YEAR': acYear,
      };

      final response = await _apiClient.getStaffStudentMarks(token, params);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _marks = list.map((e) => StaffExamMark.fromJson(e)).toList();
        });
      } else {
        setState(() => _marks = []);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? 'No marks found')));
      }
    } catch (e) {
      debugPrint('Error fetching marks: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Marks'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _marks.isEmpty
                    ? const Center(child: Text('Select filters to view marks'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _marks.length,
                        itemBuilder: (context, index) {
                          final item = _marks[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              title: Text(item.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item.componentName),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Marks: ${item.mark}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                                  ),
                                  Text(
                                    item.result,
                                    style: TextStyle(
                                      color: item.result.toLowerCase() == 'pass' ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamMarkEntryScreen()));
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          _buildDropdown<StaffClass>(
            value: _selectedClass,
            hint: 'Select Class',
            items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c.className))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedClass = val;
                _selectedExam = null;
                _selectedStudent = null;
                _exams = [];
                _students = [];
                _marks = [];
              });
              _fetchExams();
            },
          ),
          const SizedBox(height: 12),
          _buildDropdown<StudentExamDetails>(
            value: _selectedExam,
            hint: 'Select Exam',
            items: _exams.map((e) => DropdownMenuItem(value: e, child: Text(e.examName))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedExam = val;
                _selectedStudent = null;
                _students = [];
                _marks = [];
              });
              _fetchStudents();
            },
          ),
          const SizedBox(height: 12),
          _buildDropdown<StudentAttendanceData>(
            value: _selectedStudent,
            hint: 'Select Student',
            items: _students.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedStudent = val;
                _marks = [];
              });
              _fetchMarks();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
