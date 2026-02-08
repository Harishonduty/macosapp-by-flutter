import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:intl/intl.dart';

class AddAdminAnnouncementScreen extends StatefulWidget {
  const AddAdminAnnouncementScreen({super.key});

  @override
  State<AddAdminAnnouncementScreen> createState() => _AddAdminAnnouncementScreenState();
}

class _AddAdminAnnouncementScreenState extends State<AddAdminAnnouncementScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffClass> _classes = [];
  final List<StaffClass> _selectedClasses = [];
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 7));
  final TextEditingController _announcementController = TextEditingController();
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

  Future<void> _submit() async {
    if (_selectedClasses.isEmpty || _announcementController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select classes and enter announcement")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final classIds = _selectedClasses.map((c) => c.classId).join(',');
      final fromStr = DateFormat('yyyy-MM-dd').format(_fromDate);
      final toStr = DateFormat('yyyy-MM-dd').format(_toDate);

      final data = {
        "ANNOUNCE_ID": "",
        "CLASS_ID": classIds,
        "DATE_FROM": fromStr,
        "DATE_TO": toStr,
        "ANNOUNCE_MENT": _announcementController.text.trim(),
      };

      final response = await _apiClient.insertAdminAnnouncement(token, data);
      if (response.data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Announcement saved")));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Failed to save")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error submitting announcement")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Admin Announcement"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildClassSelector(),
            const SizedBox(height: 16),
            _buildDatePickers(),
            const SizedBox(height: 16),
            TextField(
              controller: _announcementController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Announcement Description",
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("SEND ANNOUNCEMENT", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelector() {
    return InkWell(
      onTap: _showMultiClassDialog,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Select Classes",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedClasses.isEmpty ? "Tap to select classes" : _selectedClasses.map((c) => c.className).join(", "),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(child: _buildDatePicker("From Date", _fromDate, (d) => setState(() => _fromDate = d))),
        const SizedBox(width: 12),
        Expanded(child: _buildDatePicker("To Date", _toDate, (d) => setState(() => _toDate = d))),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime value, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: value, firstDate: DateTime.now(), lastDate: DateTime(2101));
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
            ElevatedButton(onPressed: () { Navigator.pop(context); setState(() {}); }, child: const Text("Done")),
          ],
        ),
      ),
    );
  }
}
