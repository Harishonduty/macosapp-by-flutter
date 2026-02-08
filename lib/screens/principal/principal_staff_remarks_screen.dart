import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_remarks.dart';
import 'package:holy_cross_app/screens/principal/add_staff_remark_screen.dart';

class PrincipalStaffRemarksScreen extends StatefulWidget {
  const PrincipalStaffRemarksScreen({super.key});

  @override
  State<PrincipalStaffRemarksScreen> createState() => _PrincipalStaffRemarksScreenState();
}

class _PrincipalStaffRemarksScreenState extends State<PrincipalStaffRemarksScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffRemark> _allRemarks = [];
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
          _allRemarks = list.map((e) => StaffRemark.fromJson(e)).toList();
          _filteredRemarks = _allRemarks;
        });
      }
    } catch (e) {
      debugPrint('Error fetching staff remarks: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filter(String query) {
    setState(() {
      _filteredRemarks = _allRemarks.where((r) {
        final name = r.staffName.toLowerCase();
        final remark = r.remark.toLowerCase();
        final type = r.remarkType.toLowerCase();
        return name.contains(query.toLowerCase()) || 
               remark.contains(query.toLowerCase()) || 
               type.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Remarks"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: "Search by staff name or remark",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRemarks.isEmpty
                    ? const Center(child: Text("No Remarks Found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRemarks.length,
                        itemBuilder: (context, index) {
                          return _buildRemarkCard(_filteredRemarks[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStaffRemarkScreen()));
          if (result == true) {
            _fetchRemarks();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRemarkCard(StaffRemark remark) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    remark.staffName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    remark.remarkType,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              remark.remark,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  remark.entryDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
