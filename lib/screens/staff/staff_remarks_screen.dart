import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_remarks.dart';

class StaffRemarksScreen extends StatefulWidget {
  const StaffRemarksScreen({super.key});

  @override
  State<StaffRemarksScreen> createState() => _StaffRemarksScreenState();
}

class _StaffRemarksScreenState extends State<StaffRemarksScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffRemark> _remarks = [];
  List<StaffRemark> _filteredRemarks = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRemarks();
  }

  Future<void> _fetchRemarks() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStaffRemarks(token);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _remarks = list.map((e) => StaffRemark.fromJson(e)).toList();
          _filteredRemarks = _remarks;
        });
      }
    } catch (e) {
      debugPrint('Error fetching remarks: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterRemarks(String query) {
    setState(() {
      _filteredRemarks = _remarks
          .where((r) =>
              r.remark.toLowerCase().contains(query.toLowerCase()) ||
              r.staffName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Remarks'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterRemarks,
              decoration: InputDecoration(
                hintText: 'Search remarks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRemarks.isEmpty
                    ? const Center(child: Text('No remarks found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRemarks.length,
                        itemBuilder: (context, index) {
                          final item = _filteredRemarks[index];
                          return Card(
                            elevation: 3,
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
                                      Expanded(
                                        child: Text(
                                          item.remarkType,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item.entryDate,
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.remark,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(color: Colors.grey[300]),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        'By: ${item.staffName}',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey[700],
                                          fontSize: 13,
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
