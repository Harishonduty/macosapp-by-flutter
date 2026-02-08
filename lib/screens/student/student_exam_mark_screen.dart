import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/exam_marks.dart';
import 'package:holy_cross_app/models/student_exam_details.dart';

class StudentExamMarkScreen extends StatefulWidget {
  const StudentExamMarkScreen({super.key});

  @override
  State<StudentExamMarkScreen> createState() => _StudentExamMarkScreenState();
}

class _StudentExamMarkScreenState extends State<StudentExamMarkScreen> {
  final ApiClient _apiClient = ApiClient();
  
  List<StudentExamDetails> _exams = [];
  List<ExamMarks> _examMarks = [];
  
  StudentExamDetails? _selectedExam;
  String _studentId = '';
  
  bool _isLoadingExams = true;
  bool _isLoadingMarks = false;
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

  Future<void> _fetchExamMarks(String examId) async {
    setState(() {
      _isLoadingMarks = true;
      _examMarks = [];
    });

    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getExamMarks(token, _studentId, examId);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
         if (data['status'] == true && data['result'] != null) {
           final List list = data['result'];
           setState(() {
             _examMarks = list.map((e) => ExamMarks.fromJson(e)).toList();
           });
         } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'No marks found')));
         }
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load marks')));
    } finally {
      setState(() => _isLoadingMarks = false);
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
                    _fetchExamMarks(val.examId);
                  }
                },
              ),
            ),

          Expanded(
            child: _isLoadingMarks
                ? const Center(child: CircularProgressIndicator())
                : _examMarks.isEmpty
                    ? const Center(child: Text('Select an exam to view marks'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _examMarks.length,
                        itemBuilder: (context, index) {
                          final item = _examMarks[index];
                          final isPass = item.result.toLowerCase() == 'pass';
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.subjectName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(item.examType),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Mark: ${item.mark}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        item.result,
                                        style: TextStyle(
                                          color: isPass ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
    );
  }
}
