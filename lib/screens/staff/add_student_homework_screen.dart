import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/staff_class_subject.dart';

class AddStudentHomeworkScreen extends StatefulWidget {
  const AddStudentHomeworkScreen({super.key});

  @override
  State<AddStudentHomeworkScreen> createState() => _AddStudentHomeworkScreenState();
}

class _AddStudentHomeworkScreenState extends State<AddStudentHomeworkScreen> {
  final ApiClient _apiClient = ApiClient();
  final _descriptionController = TextEditingController();

  List<StaffClass> _classes = [];
  List<StaffClassSubject> _subjects = [];

  StaffClass? _selectedClass;
  StaffClassSubject? _selectedSubject;
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;
  final String _error = '';

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
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _classes = list.map((e) => StaffClass.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSubjects() async {
    if (_selectedClass == null) return;
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getClassWiseSubjects(
        token,
        _selectedClass!.classId,
      );

      if (response.statusCode == 200 && response.data != null) {
         final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _subjects = list.map((e) => StaffClassSubject.fromJson(e)).toList();
            _selectedSubject = null; // Reset selected subject
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _submitHomework() async {
    if (_selectedClass == null || _selectedSubject == null || _descriptionController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
       return;
    }

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final formattedDate = DateFormat('yyyy-M-d').format(_selectedDate);

      final Map<String, dynamic> data = {
        "HOMEWORK_ID": null,
        "SUBJECT_ID": "0", // As per Java code: postStudentData.setSUBJECT_ID("0");
        "CLASS_ID": _selectedClass!.classId,
        "HOMEWORK_DATE": formattedDate,
        "DESCRIPTION": _descriptionController.text.trim(),
        "SMSFLAG": "2",
        "ACADEMY_YEAR_ID": "3", // As per Java code
        "IS_DELETED": "1" // As per Java code
      };
      
      final response = await _apiClient.insertClassWiseHomework(token, data);
      
      if(response.data['status'] == true) {
         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? 'Homework Added Successfully')));
             Navigator.pop(context, true); // Return success
         }
      } else {
         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? 'Failed to add homework')));
         }
      }

    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error adding homework')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Homework'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Select Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 16),
             DropdownButtonFormField<StaffClass>(
                  decoration: const InputDecoration(
                    labelText: 'Select Class',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedClass,
                  items: _classes.map((StaffClass c) {
                    return DropdownMenuItem<StaffClass>(
                      value: c,
                      child: Text("${c.className} ${c.sectionName}"),
                    );
                  }).toList(),
                  onChanged: (StaffClass? newValue) {
                    setState(() {
                      _selectedClass = newValue;
                      _subjects = []; // Clear subjects
                    });
                     _fetchSubjects();
                  },
                ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StaffClassSubject>(
                  decoration: const InputDecoration(
                    labelText: 'Select Subject',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSubject,
                   hint: const Text('Select a subject'),
                  items: _subjects.map((StaffClassSubject c) {
                    return DropdownMenuItem<StaffClassSubject>(
                      value: c,
                      child: Text(c.subjectName),
                    );
                  }).toList(),
                  onChanged: (StaffClassSubject? newValue) {
                    setState(() {
                      _selectedSubject = newValue;
                    });
                  },
                ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitHomework,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SEND'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
