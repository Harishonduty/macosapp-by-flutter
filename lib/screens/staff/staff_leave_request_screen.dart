import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:intl/intl.dart';

class StaffLeaveRequestScreen extends StatefulWidget {
  const StaffLeaveRequestScreen({super.key});

  @override
  State<StaffLeaveRequestScreen> createState() => _StaffLeaveRequestScreenState();
}

class _StaffLeaveRequestScreenState extends State<StaffLeaveRequestScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isLoading = false;

  Future<void> _selectFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _fromDate = picked);
    }
  }

  Future<void> _selectToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _toDate = picked);
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter reason")));
      return;
    }
    if (_fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select from date")));
      return;
    }
    if (_toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select to date")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final data = {
        'DATE_FROM': DateFormat('yyyy-MM-dd').format(_fromDate!),
        'DATE_TO': DateFormat('yyyy-MM-dd').format(_toDate!),
        'REASON': _reasonController.text.trim(),
        'SESSION_FORM': 'FN',
        'SESSION_TO': 'AN',
      };

      final response = await _apiClient.requestStaffLeave(token, data);
      if (response.data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Leave request submitted")));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Failed to submit")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Leave Request'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Reason",
                hintText: "Enter reason for leave",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectFromDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: "From Date",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  _fromDate == null ? 'Select date' : DateFormat('yyyy-MM-dd').format(_fromDate!),
                  style: TextStyle(color: _fromDate == null ? Colors.grey : Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectToDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: "To Date",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  _toDate == null ? 'Select date' : DateFormat('yyyy-MM-dd').format(_toDate!),
                  style: TextStyle(color: _toDate == null ? Colors.grey : Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitLeaveRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("SUBMIT REQUEST", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
