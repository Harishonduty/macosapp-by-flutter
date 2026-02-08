import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/home_work.dart';

class StudentHomeworkScreen extends StatefulWidget {
  const StudentHomeworkScreen({super.key});

  @override
  State<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen> {
  final ApiClient _apiClient = ApiClient();
  
  List<HomeWork> _homeWorks = [];
  String _selectedDate = '';
  final String _classId = '';
  
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _updateViewStatus();
    _fetchHomeWorks();
  }

  Future<void> _updateViewStatus() async {
    try {
      final token = PreferenceService.getString('token');
      await _apiClient.updateHomeworkViewStatus(token);
    } catch (_) {
      // Ignore
    }
  }

  Future<void> _fetchHomeWorks() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getHomeWorks(token, _selectedDate, _classId);

      if (response.statusCode == 200 && response.data != null) {
         final data = response.data;
         if (data['status'] == true && data['result'] != null) {
            final List list = data['result'];
            setState(() {
               _homeWorks = list.map((e) => HomeWork.fromJson(e)).toList();
            });
         } else {
            setState(() {
               if (data['message'] != null) _error = data['message'];
               _homeWorks = [];
            });
         }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load homework');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
         // Java code uses format year-month-day. 
         // Note: Java month is 0-indexed, but this logic handled it manually.
         // Let's use standard ISO format or what the API expects. 
         // Java: strBuf.append(year); strBuf.append("-"); strBuf.append(month + 1); strBuf.append("-"); strBuf.append(dayOfMonth);
         _selectedDate = DateFormat('yyyy-M-d').format(picked);
      });
      _fetchHomeWorks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
             ? Center(child: Text(_error))
             : _homeWorks.isEmpty
                 ? const Center(child: Text('No Homework Found'))
                 : ListView.builder(
                     padding: const EdgeInsets.all(16),
                     itemCount: _homeWorks.length,
                     itemBuilder: (context, index) {
                       final item = _homeWorks[index];
                       return Card(
                         elevation: 3,
                         margin: const EdgeInsets.only(bottom: 16),
                         child: Padding(
                           padding: const EdgeInsets.all(16.0),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                    Expanded(
                                      child: Text(
                                        item.subjectName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      item.homeworkDate,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                 ],
                               ),
                               const Divider(),
                               Text(item.description),
                               const SizedBox(height: 8),
                               Align(
                                 alignment: Alignment.centerRight,
                                 child: Text(
                                   item.className,
                                   style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                       );
                     },
                   ),
    );
  }
}
