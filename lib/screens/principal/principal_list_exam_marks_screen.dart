import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/student_exam_details.dart';
import 'package:holy_cross_app/models/student_attendance_data.dart';
import 'package:holy_cross_app/models/exam_marks.dart';
import 'package:holy_cross_app/screens/principal/exam_mark_entry_screen.dart';

class PrincipalListExamMarksScreen extends StatefulWidget {
  const PrincipalListExamMarksScreen({super.key});

  @override
  State<PrincipalListExamMarksScreen> createState() => _PrincipalListExamMarksScreenState();
}

class _PrincipalListExamMarksScreenState extends State<PrincipalListExamMarksScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffClass> _classes = [];
  List<StudentExamDetails> _exams = [];
  List<StudentAttendanceData> _students = [];
  List<ExamMarks> _marks = [];
  List<ExamMarks> _filteredMarks = [];

  StaffClass? _selectedClass;
  StudentExamDetails? _selectedExam;
  StudentAttendanceData? _selectedStudent;

  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

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
      final response = await _apiClient.getStudentExamDetails(token);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _exams = list.map((e) => StudentExamDetails.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching exams: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStudents(String classId) async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final now = DateTime.now();
      final dateStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
      final response = await _apiClient.getClassWiseStudentAttendanceByDate(dateStr, classId, token);
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
    if (_selectedStudent == null || _selectedExam == null || _selectedClass == null) return;

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      
      // Parse year from exam date string e.g. "M/d/yyyy h:mm:ss a"
      String acYear = DateTime.now().year.toString();
      try {
        if (_selectedExam!.dateFrom.isNotEmpty) {
           acYear = _selectedExam!.dateFrom.split(' ').first.split('/').last;
        }
      } catch (e) {
        debugPrint('Error parsing year: $e');
      }

      final data = {
        "STUDENT_ID": _selectedStudent!.studentId,
        "EXAM_ID": _selectedExam!.examId,
        "CLASS_ID": _selectedClass!.classId,
        "AC_YEAR": acYear,
      };

      final response = await _apiClient.getStudentMarksByStudentWise(token, data);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _marks = list.map((e) => ExamMarks.fromJson(e)).toList();
          _filteredMarks = _marks;
        });
      }
    } catch (e) {
      debugPrint('Error fetching marks: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredMarks = _marks.where((m) {
        final subject = m.subjectName.toLowerCase();
        return subject.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Exam Marks"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilters(),
          if (_marks.isNotEmpty) _buildSearchBar(),
          Expanded(
            child: _isLoading && _marks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _marks.isEmpty
                    ? const Center(child: Text("Select Class, Exam, and Student to view marks"))
                    : _buildMarksList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExamMarkEntryScreen()),
          );
          if (result == true) {
            _fetchMarks();
          }
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
            label: "Select Class",
            value: _selectedClass,
            items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c.className))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedClass = val;
                _selectedExam = null;
                _selectedStudent = null;
                _marks = [];
                _students = [];
              });
              if (val != null) _fetchExams();
            },
          ),
          const SizedBox(height: 12),
          _buildDropdown<StudentExamDetails>(
            label: "Select Exam",
            value: _selectedExam,
            items: _exams.map((e) => DropdownMenuItem(value: e, child: Text(e.examName))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedExam = val;
                _selectedStudent = null;
                _students = [];
                _marks = [];
              });
              if (val != null && _selectedClass != null) _fetchStudents(_selectedClass!.classId);
            },
          ),
          const SizedBox(height: 12),
          _buildDropdown<StudentAttendanceData>(
            label: "Select Student",
            value: _selectedStudent,
            items: _students.map((s) => DropdownMenuItem(value: s, child: Text(s.name ?? ''))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedStudent = val;
                _marks = [];
              });
              if (val != null) _fetchMarks();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSearch,
        decoration: InputDecoration(
          hintText: "Search by subject...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildMarksList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredMarks.length,
      itemBuilder: (context, index) {
        final mark = _filteredMarks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            title: Text(mark.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Exam Type: ${mark.examType}"),
            trailing: SizedBox(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    mark.mark,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mark.result.toLowerCase() == 'pass' ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(mark.result, style: TextStyle(fontSize: 12, color: mark.result.toLowerCase() == 'pass' ? Colors.green : Colors.red)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
