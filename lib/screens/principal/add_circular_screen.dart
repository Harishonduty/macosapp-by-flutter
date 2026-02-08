import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';

class AddCircularScreen extends StatefulWidget {
  const AddCircularScreen({super.key});

  @override
  State<AddCircularScreen> createState() => _AddCircularScreenState();
}

class _AddCircularScreenState extends State<AddCircularScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffClass> _classes = [];
  StaffClass? _selectedClass;
  final TextEditingController _messageController = TextEditingController();
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
        _classes = list.map((e) => StaffClass.fromJson(e)).toList();
      }
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching classes for circular: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedClass == null || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a class and enter message")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      
      final circularData = {
        "CLASS_ID": _selectedClass!.classId,
        "CIRCULAR_MESSAGE": _messageController.text.trim(),
        "ENTRY_ID": "1",
        "ENTRY_DATE": "",
        "CIRCULAR_ID": "0", // 0 for new
      };

      final response = await _apiClient.insertCircular(token, [circularData]);
      if (response.data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Circular saved successfully")));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Failed to save circular")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error submitting circular")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Circular"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _classes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<StaffClass>(
                    value: _selectedClass,
                    decoration: InputDecoration(
                      labelText: "Select Class",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c.className))).toList(),
                    onChanged: (val) => setState(() => _selectedClass = val),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: "Circular Message",
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
                          : const Text("SAVE CIRCULAR", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
