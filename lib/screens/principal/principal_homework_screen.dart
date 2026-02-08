import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/home_work.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/screens/staff/add_student_homework_screen.dart';

class PrincipalHomeworkScreen extends StatefulWidget {
  const PrincipalHomeworkScreen({super.key});

  @override
  State<PrincipalHomeworkScreen> createState() => _PrincipalHomeworkScreenState();
}

class _PrincipalHomeworkScreenState extends State<PrincipalHomeworkScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  List<HomeWork> _homeworks = [];
  List<HomeWork> _filteredHomeworks = [];
  List<StaffClass> _classes = [];
  
  StaffClass? _selectedClass;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
    _fetchHomeworks();
  }

  Future<void> _fetchClasses() async {
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
    }
  }

  Future<void> _fetchHomeworks() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await _apiClient.getHomeWorks(
        token,
        formattedDate,
        _selectedClass?.classId ?? "",
      );

      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _homeworks = list.map((e) => HomeWork.fromJson(e)).toList();
          _filteredHomeworks = _homeworks;
        });
      } else {
        setState(() {
          _homeworks = [];
          _filteredHomeworks = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching homeworks: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredHomeworks = _homeworks.where((hw) {
        final className = hw.className?.toLowerCase() ?? "";
        final description = hw.description?.toLowerCase() ?? "";
        final subject = hw.subjectName?.toLowerCase() ?? "";
        return className.contains(query.toLowerCase()) ||
               description.contains(query.toLowerCase()) ||
               subject.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchHomeworks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Principal Homework"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildSearchBar(),
          Expanded(
            child: _isLoading && _homeworks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchHomeworks,
                    child: _filteredHomeworks.isEmpty
                        ? const Center(child: Text("No homework found for selected criteria"))
                        : _buildHomeworkList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentHomeworkScreen()),
          );
          if (result == true) {
            _fetchHomeworks();
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<StaffClass>(
                  value: _selectedClass,
                  hint: const Text("All Classes"),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<StaffClass>(value: null, child: Text("All Classes")),
                    ..._classes.map((c) => DropdownMenuItem(value: c, child: Text(c.className))),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedClass = val;
                    });
                    _fetchHomeworks();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSearch,
        decoration: InputDecoration(
          hintText: "Search by subject or description...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          fillColor: Colors.grey[100],
          filled: true,
        ),
      ),
    );
  }

  Widget _buildHomeworkList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredHomeworks.length,
      itemBuilder: (context, index) {
        final hw = _filteredHomeworks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hw.className ?? "N/A",
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Text(
                      hw.homeworkDate ?? "",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  hw.subjectName ?? "General",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  hw.description ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
