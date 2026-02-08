import 'package:flutter/material.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/subject.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:intl/intl.dart';

class AddHomeworkScreen extends StatefulWidget {
  const AddHomeworkScreen({super.key});

  @override
  State<AddHomeworkScreen> createState() => _AddHomeworkScreenState();
}

class _AddHomeworkScreenState extends State<AddHomeworkScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<StaffClass> _classes = [];
  List<Subject> _subjects = [];
  
  StaffClass? _selectedClass;
  Subject? _selectedSubject;
  DateTime? _homeworkDate;
  DateTime? _submissionDate;
  
  bool _isLoading = false;
  bool _isLoadingSubjects = false;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentClasses(token);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List list = [];
        
        if (data['result'] != null && data['result']['lstofClass'] != null) {
          list = data['result']['lstofClass'];
        } else if (data['result'] is List) {
          list = data['result'];
        }

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

  Future<void> _fetchSubjects(String classId) async {
    setState(() {
      _isLoadingSubjects = true;
      _subjects = [];
      _selectedSubject = null;
    });
    
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getClassWiseSubjects(token, classId);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List list = [];
        
        if (data['result'] is List) {
          list = data['result'];
        }

        setState(() {
          _subjects = list.map((e) => Subject.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
    } finally {
      if (mounted) setState(() => _isLoadingSubjects = false);
    }
  }

  Future<void> _saveHomework() async {
    // Validation
    if (_selectedClass == null) {
      _showError('Please select a class');
      return;
    }
    if (_selectedSubject == null) {
      _showError('Please select a subject');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showError('Please enter homework description');
      return;
    }
    if (_homeworkDate == null) {
      _showError('Please select homework date');
      return;
    }
    if (_submissionDate == null) {
      _showError('Please select submission date');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final data = {
        'CLASS_ID': _selectedClass!.classId,
        'SUBJECT_ID': _selectedSubject!.subjectId,
        'HOMEWORK_DATE': DateFormat('yyyy-MM-dd').format(_homeworkDate!),
        'HOMEWORK_DESCRIPTION': _descriptionController.text.trim(),
        'SUBMISSION_DATE': DateFormat('yyyy-MM-dd').format(_submissionDate!),
      };

      final response = await _apiClient.insertClassWiseHomework(token, data);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseData['message'] ?? 'Homework saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          _showError(responseData['message'] ?? 'Failed to save homework');
        }
      }
    } catch (e) {
      debugPrint('Error saving homework: $e');
      _showError('Error saving homework');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectHomeworkDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _homeworkDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _homeworkDate = picked;
      });
    }
  }

  Future<void> _selectSubmissionDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _submissionDate ?? _homeworkDate ?? DateTime.now(),
      firstDate: _homeworkDate ?? DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _submissionDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Add Homework',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Class Selector
                  _buildLabel('Select Class'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<StaffClass>(
                        isExpanded: true,
                        value: _selectedClass,
                        hint: const Text('Select Class'),
                        items: _classes.map((classData) {
                          return DropdownMenuItem<StaffClass>(
                            value: classData,
                            child: Text(classData.className),
                          );
                        }).toList(),
                        onChanged: (StaffClass? value) {
                          setState(() {
                            _selectedClass = value;
                          });
                          if (value != null) {
                            _fetchSubjects(value.classId);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Subject Selector
                  _buildLabel('Select Subject'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _isLoadingSubjects
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<Subject>(
                              isExpanded: true,
                              value: _selectedSubject,
                              hint: const Text('Select Subject'),
                              items: _subjects.map((subject) {
                                return DropdownMenuItem<Subject>(
                                  value: subject,
                                  child: Text(subject.subjectName),
                                );
                              }).toList(),
                              onChanged: _selectedClass == null
                                  ? null
                                  : (Subject? value) {
                                      setState(() {
                                        _selectedSubject = value;
                                      });
                                    },
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  _buildLabel('Homework Description'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Enter homework description',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Homework Date
                  _buildLabel('Homework Date'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectHomeworkDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.black54),
                          const SizedBox(width: 12),
                          Text(
                            _homeworkDate == null
                                ? 'Select Date'
                                : DateFormat('dd/MM/yyyy').format(_homeworkDate!),
                            style: TextStyle(
                              fontSize: 14,
                              color: _homeworkDate == null ? Colors.black54 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Submission Date
                  _buildLabel('Submission Date'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectSubmissionDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.black54),
                          const SizedBox(width: 12),
                          Text(
                            _submissionDate == null
                                ? 'Select Date'
                                : DateFormat('dd/MM/yyyy').format(_submissionDate!),
                            style: TextStyle(
                              fontSize: 14,
                              color: _submissionDate == null ? Colors.black54 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Save Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveHomework,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'SAVE HOMEWORK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }
}
