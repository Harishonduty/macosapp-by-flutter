import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_info_data.dart';
import 'package:holy_cross_app/models/staff_remarks.dart';

class AddStaffRemarkScreen extends StatefulWidget {
  const AddStaffRemarkScreen({super.key});

  @override
  State<AddStaffRemarkScreen> createState() => _AddStaffRemarkScreenState();
}

class _AddStaffRemarkScreenState extends State<AddStaffRemarkScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffInfoData> _staffList = [];
  List<RemarksType> _remarkTypes = [];
  
  StaffInfoData? _selectedStaff;
  RemarksType? _selectedType;
  final TextEditingController _remarkController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final staffResponse = await _apiClient.getStaffInfo(token);
      final typesResponse = await _apiClient.getRemarksTypes(token);

      if (staffResponse.data['status'] == true) {
        final List list = staffResponse.data['result']['lstofStaffInfo'] ?? [];
        _staffList = list.map((e) => StaffInfoData.fromJson(e)).toList();
      }

      if (typesResponse.data['status'] == true) {
        final List list = typesResponse.data['result'] ?? [];
        _remarkTypes = list.map((e) => RemarksType.fromJson(e)).toList();
      }
      
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching add remark data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedStaff == null || _selectedType == null || _remarkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      
      final remarkData = {
        "STAFF_ID": _selectedStaff!.staffId,
        "REMARK": _remarkController.text.trim(),
        "REMARK_TYPE": _selectedType!.id, // remark_id in Java
        "ENTRY_ID": "1",
        "ENTRY_DATE": "",
        "ACADEMIC_YEAR_ID": "2",
        "REMARK_ID": _selectedType!.id,
      };

      final response = await _apiClient.insertStaffRemarks(token, [remarkData]);
      if (response.data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Remark saved successfully")));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Failed to save remark")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error submitting remark")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Staff Remark"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _staffList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDropdown<StaffInfoData>(
                    label: "Select Staff",
                    value: _selectedStaff,
                    items: _staffList.map((s) => DropdownMenuItem(value: s, child: Text(s.name ?? ''))).toList(),
                    onChanged: (val) => setState(() => _selectedStaff = val),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown<RemarksType>(
                    label: "Remark Type",
                    value: _selectedType,
                    items: _remarkTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                    onChanged: (val) => setState(() => _selectedType = val),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _remarkController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: "Remark Description",
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
                          : const Text("SAVE REMARK", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
