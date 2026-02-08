import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/exam_time_table.dart';
import 'package:holy_cross_app/models/student_exam_details.dart';

class StudentExamTimeTableScreen extends StatefulWidget {
  const StudentExamTimeTableScreen({super.key});

  @override
  State<StudentExamTimeTableScreen> createState() => _StudentExamTimeTableScreenState();
}

class _StudentExamTimeTableScreenState extends State<StudentExamTimeTableScreen> {
  final ApiClient _apiClient = ApiClient();
  
  List<StudentExamDetails> _exams = [];
  List<ExamTimeTable> _examTimeTable = [];
  
  StudentExamDetails? _selectedExam;
  String _studentId = '';
  
  bool _isLoadingExams = true;
  bool _isLoadingTimeTable = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _fetchStudentId();
    await _fetchExams();
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

  Future<void> _fetchExams() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentExamDetailsList(token);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
         if (data['status'] == true && data['result'] != null) {
           final List list = data['result'];
           setState(() {
             _exams = list.map((e) => StudentExamDetails.fromJson(e)).toList();
             _isLoadingExams = false;
           });
         } else {
            setState(() {
              _isLoadingExams = false;
              if (data['message'] != null) _error = data['message'];
            });
         }
      }
    } catch (e) {
      setState(() {
        _isLoadingExams = false;
        _error = 'Failed to load exams';
      });
    }
  }

  Future<void> _fetchExamTimeTable(String examId) async {
    setState(() {
      _isLoadingTimeTable = true;
      _examTimeTable = [];
    });

    try {
      final token = PreferenceService.getString('token');
      // If studentId is missing, try to fetch it again or warn? 
      // Assuming _studentId is set.
      final response = await _apiClient.getExamTimeTable(token, examId, _studentId);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
         if (data['status'] == true && data['result'] != null) {
           final List list = data['result'];
           setState(() {
             _examTimeTable = list.map((e) => ExamTimeTable.fromJson(e)).toList();
           });
         } else {
            // No timetable found or error
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'No timetable found')));
         }
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load timetable')));
    } finally {
      setState(() => _isLoadingTimeTable = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Timetable'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_isLoadingExams)
            const LinearProgressIndicator()
          else if (_error.isNotEmpty)
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text(_error, style: const TextStyle(color: Colors.red)),
             )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<StudentExamDetails>(
                decoration: const InputDecoration(
                  labelText: 'Select Exam',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedExam,
                items: _exams.map((exam) {
                  return DropdownMenuItem(
                    value: exam,
                    child: Text(exam.examName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedExam = val);
                    _fetchExamTimeTable(val.examId);
                  }
                },
              ),
            ),
          
          Expanded(
            child: _isLoadingTimeTable
                ? const Center(child: CircularProgressIndicator())
                : _examTimeTable.isEmpty
                    ? const Center(child: Text('Select an exam to view timetable'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _examTimeTable.length,
                        itemBuilder: (context, index) {
                          final item = _examTimeTable[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Text(item.day.substring(0, 1)), // First letter of day
                              ),
                              title: Text(item.subjectName),
                              subtitle: Text('${item.date} (${item.startTime} - ${item.endTime})'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
