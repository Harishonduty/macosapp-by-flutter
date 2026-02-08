import 'package:flutter/material.dart';
import 'package:holy_cross_app/models/staff_homework.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/screens/principal/add_homework_screen.dart';
import 'package:intl/intl.dart';

class PrincipalHomeworkListScreen extends StatefulWidget {
  const PrincipalHomeworkListScreen({super.key});

  @override
  State<PrincipalHomeworkListScreen> createState() => _PrincipalHomeworkListScreenState();
}

class _PrincipalHomeworkListScreenState extends State<PrincipalHomeworkListScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  
  List<StaffHomework> _allHomework = [];
  List<StaffHomework> _filteredHomework = [];
  bool _isLoading = false;
  String _selectedDate = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fetchHomework();
    _searchController.addListener(_filterHomework);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterHomework() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredHomework = _allHomework;
      } else {
        _filteredHomework = _allHomework.where((homework) {
          final className = homework.className.toLowerCase();
          final description = homework.description.toLowerCase();
          final date = homework.homeworkDate.toLowerCase();
          return className.contains(query) || description.contains(query) || date.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _fetchHomework() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getHomeWorks(token, _selectedDate, '');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List list = [];
        
        if (data['result'] is List) {
          list = data['result'];
        }

        setState(() {
          _allHomework = list.map((e) => StaffHomework.fromJson(e)).toList();
          _filteredHomework = _allHomework;
        });
      }
    } catch (e) {
      debugPrint('Error fetching homework: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      _fetchHomework();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'View Homework',
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
      body: Column(
        children: [
          // Date Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: Colors.black54),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy').format(DateTime.parse(_selectedDate)),
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Search'),
                        content: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Enter class, description or date',
                            prefixIcon: Icon(Icons.search),
                          ),
                          autofocus: true,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              Navigator.pop(context);
                            },
                            child: const Text('Clear'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.search, size: 20, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Homework List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHomework.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 80, color: Colors.black26),
                            SizedBox(height: 16),
                            Text(
                              'No Homework Found',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredHomework.length,
                        itemBuilder: (context, index) {
                          return _buildHomeworkCard(_filteredHomework[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHomeworkScreen()),
          );
          if (result == true) {
            _fetchHomework();
          }
        },
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHomeworkCard(StaffHomework homework) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Name
            Text(
              homework.className,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Subject
            Row(
              children: [
                const Text(
                  'Subject : ',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  homework.subjectName,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description : ',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Expanded(
                  child: Text(
                    homework.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Homework Date
            Row(
              children: [
                const Text(
                  'Homework Date : ',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  homework.homeworkDate,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Submission Date
            Row(
              children: [
                const Text(
                  'Submission Date : ',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  homework.submissionDate,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
