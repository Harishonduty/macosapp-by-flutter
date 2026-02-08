import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/post_announcement.dart';
import 'package:intl/intl.dart';

class AddStaffAnnouncementScreen extends StatefulWidget {
  const AddStaffAnnouncementScreen({super.key});

  @override
  State<AddStaffAnnouncementScreen> createState() => _AddStaffAnnouncementScreenState();
}

class _AddStaffAnnouncementScreenState extends State<AddStaffAnnouncementScreen> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  
  List<StaffClass> _classes = [];
  StaffClass? _selectedClass;
  
  final _announcementController = TextEditingController();
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 7));

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
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

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  Future<void> _submitAnnouncement() async {
    if (!_formKey.currentState!.validate() || _selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select class and fill description')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      
      final postData = PostAnnouncement(
        announcement: _announcementController.text.trim(),
        dateFrom: DateFormat('yyyy-MM-dd').format(_fromDate),
        dateTo: DateFormat('yyyy-MM-dd').format(_toDate),
        classId: _selectedClass!.classId,
      );

      final response = await _apiClient.insertAnnouncement(token, postData.toJson());
      if (response.data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'Announcement added successfully'))
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'Failed to add announcement'))
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding announcement'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Announcement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _classes.isEmpty 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDropdown<StaffClass>(
                      value: _selectedClass,
                      label: 'Select Class',
                      items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c.className))).toList(),
                      onChanged: (val) => setState(() => _selectedClass = val),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectFromDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'From Date',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(DateFormat('dd/MM/yyyy').format(_fromDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectToDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'To Date',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(DateFormat('dd/MM/yyyy').format(_toDate)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _announcementController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Announcement Description',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Please enter description' : null,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitAnnouncement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('POST ANNOUNCEMENT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items,
      onChanged: onChanged,
      validator: (val) => val == null ? 'Selection required' : null,
    );
  }
}
