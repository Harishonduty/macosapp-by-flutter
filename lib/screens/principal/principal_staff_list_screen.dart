import 'package:flutter/material.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_info_data.dart';

enum StaffCategory { teaching, nonTeaching }

class PrincipalStaffListScreen extends StatefulWidget {
  final StaffCategory category;
  const PrincipalStaffListScreen({super.key, required this.category});

  @override
  State<PrincipalStaffListScreen> createState() => _PrincipalStaffListScreenState();
}

class _PrincipalStaffListScreenState extends State<PrincipalStaffListScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  
  List<StaffInfoData> _allStaff = [];
  List<StaffInfoData> _filteredStaff = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
    _searchController.addListener(_filterStaff);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStaff() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStaff = _allStaff;
      } else {
        _filteredStaff = _allStaff.where((staff) {
          final name = (staff.name ?? '').toLowerCase();
          final code = (staff.employeeCode ?? '').toLowerCase();
          final mobile = (staff.mobile ?? '').toLowerCase();
          return name.contains(query) || code.contains(query) || mobile.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _fetchStaff() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStaffInfo(token);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List list = [];
        
        if (data['result'] != null && data['result']['lstofStaffInfo'] != null) {
          list = data['result']['lstofStaffInfo'];
        } else if (data['result'] is List) {
          list = data['result'];
        }

        final staffList = list.map((e) => StaffInfoData.fromJson(e)).toList();
        
        setState(() {
          // Filter based on category
          _allStaff = staffList.where((s) {
            final cat = (s.category ?? '').toLowerCase();
            if (widget.category == StaffCategory.teaching) {
              // Exclude "Non Teaching Staff"
              return !cat.contains('non');
            } else {
              // Include only non-teaching staff
              return cat.contains('non');
            }
          }).toList();
          _filteredStaff = _allStaff;
        });
      }
    } catch (e) {
      debugPrint('Error fetching staff: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.category == StaffCategory.teaching ? 'Class Teachers' : 'Non-Teaching Staff',
          style: const TextStyle(
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
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Search'),
                    content: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Enter name, code or mobile',
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
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.black54, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Search...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Staff List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStaff.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.inbox,
                          size: 80,
                          color: Colors.black26,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filteredStaff.length,
                        itemBuilder: (context, index) {
                          return _buildStaffCard(_filteredStaff[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(StaffInfoData staff) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Gender row
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      const TextSpan(
                        text: 'Name : ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextSpan(
                        text: staff.name ?? 'Unknown',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    const TextSpan(
                      text: 'Gender : ',
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextSpan(
                      text: staff.gender ?? 'N/A',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Employee Code and Mobile row
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      const TextSpan(
                        text: 'Employee Code : ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextSpan(
                        text: staff.employeeCode ?? 'N/A',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    const TextSpan(
                      text: 'Mobile : ',
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextSpan(
                      text: staff.mobile ?? 'N/A',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
