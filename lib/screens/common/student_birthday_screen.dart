import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:intl/intl.dart';

class StudentBirthdayScreen extends StatefulWidget {
  const StudentBirthdayScreen({super.key});

  @override
  State<StudentBirthdayScreen> createState() => _StudentBirthdayScreenState();
}

class _StudentBirthdayScreenState extends State<StudentBirthdayScreen> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _allBirthdays = [];
  List<Map<String, dynamic>> _filteredBirthdays = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBirthdays();
  }

  Future<void> _fetchBirthdays() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentBirthdays(token);
      
      print("Student Birthday Response: ${response.data}"); // Debug

      if (response.statusCode == 200) {
        final data = response.data;
        List list = [];
        
        // Handle various JSON structures
        if (data is List) {
          list = data;
        } else if (data['result'] != null && data['result'] is List) {
          list = data['result'];
        }

        setState(() {
          _allBirthdays = list.map((e) => Map<String, dynamic>.from(e)).toList();
          _filteredBirthdays = _allBirthdays;
        });
      }
    } catch (e) {
      debugPrint('Error fetching student birthdays: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterBirthdays(String query) {
    setState(() {
      _filteredBirthdays = _allBirthdays.where((b) {
        final name = (b['STUDENT_NAME'] ?? b['name'] ?? "").toString().toLowerCase();
        final className = (b['CLASS_NAME'] ?? b['class'] ?? "").toString().toLowerCase();
        final dob = (b['DOB'] ?? b['dob'] ?? "").toString().toLowerCase();
        
        return name.contains(query.toLowerCase()) || 
               className.contains(query.toLowerCase()) || 
               dob.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Birthdays"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBirthdays.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cake_outlined, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty 
                                  ? "No birthdays today" 
                                  : "No matching birthdays found",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : _buildBirthdayList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _filterBirthdays,
        decoration: InputDecoration(
          hintText: "Search by name or class...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          fillColor: Colors.grey[100],
          filled: true,
        ),
      ),
    );
  }

  Widget _buildBirthdayList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredBirthdays.length,
      itemBuilder: (context, index) {
        final birthday = _filteredBirthdays[index];
        final name = birthday['STUDENT_NAME'] ?? birthday['name'] ?? "N/A";
        final className = birthday['CLASS_NAME'] ?? birthday['class'] ?? "N/A";
        final dob = birthday['DOB'] ?? birthday['dob'] ?? "";

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Class: $className"),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.cake, color: Colors.pinkAccent, size: 20),
                const SizedBox(height: 4),
                Text(
                  dob,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
