import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/student_exam_details.dart';
import 'package:holy_cross_app/models/exam_subject.dart';
import 'package:holy_cross_app/models/exam_component.dart';
import 'package:holy_cross_app/models/student_attendance_data.dart';
import 'package:holy_cross_app/models/post_exam_mark.dart';
import 'package:intl/intl.dart';

class ExamMarkEntryScreen extends StatefulWidget {
  const ExamMarkEntryScreen({super.key});

  @override
  State<ExamMarkEntryScreen> createState() => _ExamMarkEntryScreenState();
}

class _ExamMarkEntryScreenState extends State<ExamMarkEntryScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffClass> _classes = [];
  List<StudentExamDetails> _exams = [];
  List<ExamSubject> _subjects = [];
  List<ExamComponent> _components = [];
  List<StudentAttendanceData> _students = [];
  
  final Map<String, TextEditingController> _markControllers = {};

  StaffClass? _selectedClass;
  StudentExamDetails? _selectedExam;
  ExamSubject? _selectedSubject;
  ExamComponent? _selectedComponent;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  @override
  void dispose() {
    for (var controller in _markControllers.values) {
      controller.dispose();
    }
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

  Future<void> _fetchSubjects() async {
    if (_selectedExam == null || _selectedClass == null) return;
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getExamSubjects(token, _selectedExam!.examId, _selectedClass!.classId);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _subjects = list.map((e) => ExamSubject.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchComponents() async {
    if (_selectedClass == null || _selectedSubject == null || _selectedExam == null) return;
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getExamComponents(token, _selectedClass!.classId, _selectedSubject!.subjectId ?? '', _selectedExam!.examId);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _components = list.map((e) => ExamComponent.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching components: $e');
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
          for (var s in _students) {
            _markControllers[s.studentId] = TextEditingController();
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitMarks() async {
    if (_selectedClass == null || _selectedExam == null || _selectedSubject == null || _selectedComponent == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select all filters')));
      return;
    }

    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit the marks?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('NO')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('YES')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      
      final postMarks = _students.map((s) {
        return PostExamMark(
          academicYearId: "2", // Hardcoded in Java
          classId: _selectedClass!.classId,
          componentId: _selectedComponent!.componentId,
          examCompMarkId: "",
          examId: _selectedExam!.examId,
          examSubCompId: _selectedComponent!.examSubCompId,
          smsFlag: "2",
          studentId: s.studentId,
          subjectId: _selectedSubject!.subjectId ?? '',
          stuCompMark: _markControllers[s.studentId]?.text ?? "0",
        );
      }).toList();

      final data = PostExamMarkList(marks: postMarks, total: postMarks.length.toString());

      final response = await _apiClient.insertExamMarks(token, data.toJson());
      if (response.data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? 'Marks submitted successfully')));
          Navigator.pop(context);
        }
      } else {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? 'Failed to submit marks')));
      }
    } catch (e) {
      debugPrint('Error submitting marks: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error submitting marks')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Entry'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_students.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isLoading ? null : _submitMarks,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          if (_selectedExam != null)
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Exam: ${_selectedExam!.examName} (${_selectedExam!.dateFrom} - ${_selectedExam!.dateTo})',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(child: Text('Please select all filters to see student list'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text('ID: ${student.studentId}'),
                              trailing: SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _markControllers[student.studentId],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'Mark',
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
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
                _selectedSubject = null;
                _selectedComponent = null;
                _exams = [];
                _subjects = [];
                _components = [];
                _students = [];
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
                _selectedSubject = null;
                _selectedComponent = null;
                _subjects = [];
                _components = [];
                _students = [];
              });
              _fetchSubjects();
            },
          ),
          const SizedBox(height: 12),
          _buildDropdown<ExamSubject>(
            value: _selectedSubject,
            hint: 'Select Subject',
            items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.subjectName ?? ''))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedSubject = val;
                _selectedComponent = null;
                _components = [];
                _students = [];
              });
              _fetchComponents();
            },
          ),
          const SizedBox(height: 12),
          _buildDropdown<ExamComponent>(
            value: _selectedComponent,
            hint: 'Select Component',
            items: _components.map((c) => DropdownMenuItem(value: c, child: Text(c.componentName))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedComponent = val;
                _students = [];
              });
              _fetchStudents();
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
