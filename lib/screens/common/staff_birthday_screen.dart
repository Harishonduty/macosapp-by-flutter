import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_birthday_data.dart';

class StaffBirthdayScreen extends StatefulWidget {
  const StaffBirthdayScreen({super.key});

  @override
  State<StaffBirthdayScreen> createState() => _StaffBirthdayScreenState();
}

class _StaffBirthdayScreenState extends State<StaffBirthdayScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffBirthdayData> _allBirthdays = [];
  List<StaffBirthdayData> _filteredBirthdays = [];
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
      final response = await _apiClient.getStaffBirthdays(token);
      print("Response Data: ${response.data}"); // Debug printing
      if (response.statusCode == 200) {
        final data = response.data;
        List list = [];
        // Handle if result is directly the list or inside result key
        if (data is List) {
          list = data;
        } else if (data['result'] != null) {
          list = data['result'];
        }
        
        // Sometimes the API might return success but empty list
        // And the previous check: if (response.data['status'] == true) 
        // failed because 'status' key doesn't exist in your example response.
        
        setState(() {
          _allBirthdays = list.map((e) => StaffBirthdayData.fromJson(e)).toList();
          _filteredBirthdays = _allBirthdays;
        });
      }
    } catch (e) {
      debugPrint('Error fetching birthdays: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterBirthdays(String query) {
    setState(() {
      _filteredBirthdays = _allBirthdays.where((b) {
        final name = (b.name ?? "").toLowerCase();
        final code = (b.staffCode ?? "").toLowerCase();
        final dob = (b.dob ?? "").toLowerCase();
        return name.contains(query.toLowerCase()) || 
               code.contains(query.toLowerCase()) || 
               dob.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Birthdays"),
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
          hintText: "Search by name or staff code...",
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
              birthday.name ?? "N/A",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Staff Code: ${birthday.staffCode ?? 'N/A'}"),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.cake, color: Colors.pinkAccent, size: 20),
                const SizedBox(height: 4),
                Text(
                  birthday.dob ?? "",
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
