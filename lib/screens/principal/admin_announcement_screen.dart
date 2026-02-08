import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/admin_announcement_data.dart';
import 'package:holy_cross_app/screens/principal/add_admin_announcement_screen.dart';
import 'package:intl/intl.dart';

class AdminAnnouncementScreen extends StatefulWidget {
  const AdminAnnouncementScreen({super.key});

  @override
  State<AdminAnnouncementScreen> createState() => _AdminAnnouncementScreenState();
}

class _AdminAnnouncementScreenState extends State<AdminAnnouncementScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffClass> _classes = [];
  final List<StaffClass> _selectedClasses = [];
  List<AdminAnnouncementData> _announcements = [];
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();
  bool _isLoading = false;

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
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _classes = list.map((e) => StaffClass.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAnnouncements() async {
    if (_selectedClasses.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final classIds = _selectedClasses.map((c) => c.classId).join(',');
      final fromStr = DateFormat('yyyy-MM-dd').format(_fromDate);
      final toStr = DateFormat('yyyy-MM-dd').format(_toDate);
      
      final response = await _apiClient.getAdminAnnouncement(token, fromStr, toStr, classIds);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _announcements = list.map((e) => AdminAnnouncementData.fromJson(e)).toList();
        });
      } else {
        setState(() => _announcements = []);
      }
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Announcements"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _announcements.isEmpty
                    ? const Center(child: Text("No announcements found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _announcements.length,
                        itemBuilder: (context, index) => _buildAnnouncementCard(_announcements[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAdminAnnouncementScreen()));
          if (result == true) {
            _fetchAnnouncements();
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
      child: Column(
        children: [
          InkWell(
            onTap: _showMultiClassDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]!), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedClasses.isEmpty ? "Select Classes" : _selectedClasses.map((c) => c.className).join(", "),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDatePicker("From", _fromDate, (d) => setState(() { _fromDate = d; _fetchAnnouncements(); }))),
              const SizedBox(width: 8),
              Expanded(child: _buildDatePicker("To", _toDate, (d) => setState(() { _toDate = d; _fetchAnnouncements(); }))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime value, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2000), lastDate: DateTime(2101));
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd/MM/yyyy').format(value), style: const TextStyle(fontSize: 12)),
            const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _showMultiClassDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Select Classes"),
          content: SizedBox(width: double.maxFinite, child: ListView.builder(
            shrinkWrap: true, itemCount: _classes.length,
            itemBuilder: (context, index) {
              final cls = _classes[index];
              return CheckboxListTile(
                title: Text(cls.className),
                value: _selectedClasses.contains(cls),
                onChanged: (val) {
                  setDialogState(() { val! ? _selectedClasses.add(cls) : _selectedClasses.remove(cls); });
                },
              );
            },
          )),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(onPressed: () { Navigator.pop(context); setState(() {}); _fetchAnnouncements(); }, child: const Text("Done")),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(AdminAnnouncementData announcement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(announcement.announcement ?? '', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("From: ${announcement.dateFrom ?? 'N/A'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text("To: ${announcement.dateTo ?? 'N/A'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
