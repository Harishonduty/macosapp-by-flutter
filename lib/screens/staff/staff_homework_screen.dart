import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_homework.dart';

import 'add_student_homework_screen.dart';

class StaffHomeworkScreen extends StatefulWidget {
  const StaffHomeworkScreen({super.key});

  @override
  State<StaffHomeworkScreen> createState() => _StaffHomeworkScreenState();
}

class _StaffHomeworkScreenState extends State<StaffHomeworkScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffHomework> _homeworks = [];
  bool _isLoading = false;
  String _error = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchHomeworks();
  }

  Future<void> _fetchHomeworks() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final token = PreferenceService.getString('token');
      final formattedDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2,'0')}-${_selectedDate.day.toString().padLeft(2,'0')}";
      
      final response = await _apiClient.getStaffHomeworks(token, formattedDate);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _homeworks = list.map((e) => StaffHomework.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      // setState(() => _error = 'Failed to load homework');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
     if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchHomeworks();
    }
  }

  void _navigateToAddHomework() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStudentHomeworkScreen()),
    );
    if (result == true) {
      _fetchHomeworks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
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
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _homeworks.isEmpty
                    ? Center(child: Text(_error.isNotEmpty ? _error : 'No Homework Found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _homeworks.length,
                        itemBuilder: (context, index) {
                          final item = _homeworks[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.className, 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                      ),
                                      Text(
                                        item.subjectName,
                                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.description,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Date: ${item.homeworkDate}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
        onPressed: _navigateToAddHomework,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
