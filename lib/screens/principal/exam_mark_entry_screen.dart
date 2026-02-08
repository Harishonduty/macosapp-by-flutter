import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/exam_subject.dart';
import 'package:holy_cross_app/models/exam_component_data.dart';
import 'package:holy_cross_app/models/student_attendance_data.dart';

class ExamMarkEntryScreen extends StatefulWidget {
  const ExamMarkEntryScreen({super.key});

  @override
  State<ExamMarkEntryScreen> createState() => _ExamMarkEntryScreenState();
}

class _ExamMarkEntryScreenState extends State<ExamMarkEntryScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffClass> _classes = [];
  List<ExamSubject> _subjects = [];
  List<ExamComponentData> _components = [];
  List<StudentAttendanceData> _students = [];

  StaffClass? _selectedClass;
  String? _examId;
  String? _examName;
  ExamSubject? _selectedSubject;
  ExamComponentData? _selectedComponent;

  bool _isLoading = false;
  final Map<String, TextEditingController> _markControllers = {};

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

  Future<void> _fetchExamType(String classId) async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getAdminExamType(token);
      if (response.data['status'] == true) {
        final examData = response.data['result']['objExamCretate'];
        setState(() {
          _examId = examData['EXAM_ID']?.toString();
          _examName = examData['EXAM_NAME']?.toString();
        });
        if (_examId != null) {
          _fetchSubjects(_examId!, classId);
        }
      }
    } catch (e) {
      debugPrint('Error fetching exam type: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSubjects(String examId, String classId) async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getExamSubjectsByClassIdByExamType(token, examId, classId);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _subjects = list.map((e) => ExamSubject.fromJson(e)).toList();
          _selectedSubject = null;
          _components = [];
          _selectedComponent = null;
        });
      }
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchComponents(String subjectId) async {
    if (_selectedClass == null || _examId == null) return;
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getAdminExamComponents(token, _selectedClass!.classId, subjectId, _examId!);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _components = list.map((e) => ExamComponentData.fromJson(e)).toList();
          _selectedComponent = null;
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
      final now = DateTime.now();
      final dateStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
      // Note: Admin seems to use the same endpoint as staff for student list in exam mark entry
      final response = await _apiClient.getClassWiseStudentAttendanceByDate(dateStr, _selectedClass!.classId, token);
      if (response.data['status'] == true) {
        final List list = response.data['result']['lstStudent'] ?? [];
        setState(() {
          _students = list.map((e) => StudentAttendanceData.fromJson(e)).toList();
          _markControllers.clear();
          for (var s in _students) {
            _markControllers[s.studentId!] = TextEditingController();
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
    if (_selectedClass == null || _selectedSubject == null || _selectedComponent == null || _examId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select all filters")));
      return;
    }

    final token = PreferenceService.getString('token');
    final List<Map<String, dynamic>> marksList = [];
    
    for (var s in _students) {
      marksList.add({
        "EXAM_COMP_MARK_ID": "",
        "EXAM_SUB_COMP_ID": _selectedComponent!.examSubCompId,
        "COMPONENT_ID": _selectedComponent!.componentId,
        "EXAM_ID": _examId,
        "CLASS_ID": _selectedClass!.classId,
        "SUBJECT_ID": _selectedSubject!.subjectId,
        "ACADEMIC_YEAR_ID": "2", // Hardcoded in Java as "2"
        "STUDENT_ID": s.studentId,
        "STU_COMP_MARK": _markControllers[s.studentId]!.text,
        "SMSFLAG": "2",
      });
    }

    final data = {
      "json_MARKS": marksList,
      "chTotal": marksList.length.toString(),
    };

    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.insertExamMark(token, data);
      if (response.data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Marks saved successfully")));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Failed to save marks")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error submitting marks")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Mark Entry"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilters(),
          if (_examName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Active Exam: $_examName", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
          Expanded(
            child: _isLoading && _students.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(child: Text("Select all filters to enter marks"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return _buildStudentMarkCard(student);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _students.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _submitMarks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("SUBMIT MARKS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          : null,
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          _buildDropdown<StaffClass>(
            label: "Select Class",
            value: _selectedClass,
            items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c.className))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedClass = val;
                _students = [];
                _subjects = [];
                _selectedSubject = null;
                _components = [];
                _selectedComponent = null;
              });
              if (val != null) _fetchExamType(val.classId);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown<ExamSubject>(
                  label: "Subject",
                  value: _selectedSubject,
                  items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.subjectName ?? ''))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSubject = val;
                      _components = [];
                      _selectedComponent = null;
                      _students = [];
                    });
                    if (val != null && val.subjectId != null) _fetchComponents(val.subjectId!);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown<ExamComponentData>(
                  label: "Component",
                  value: _selectedComponent,
                  items: _components.map((c) => DropdownMenuItem(value: c, child: Text(c.componentName ?? ''))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedComponent = val;
                      _students = [];
                    });
                    if (val != null) _fetchStudents();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildStudentMarkCard(StudentAttendanceData student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Adm No: ${student.admissionNo ?? 'N/A'}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: TextField(
                controller: _markControllers[student.studentId],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: "Mark",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
