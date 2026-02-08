import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/strength_report_data.dart';
import 'package:holy_cross_app/models/staff_class.dart';

class StrengthReportScreen extends StatefulWidget {
  const StrengthReportScreen({super.key});

  @override
  State<StrengthReportScreen> createState() => _StrengthReportScreenState();
}

class _StrengthReportScreenState extends State<StrengthReportScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StrengthReportData> _reports = [];
  List<StaffClass> _classes = [];
  final List<StaffClass> _selectedClasses = [];
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;
  bool _isLoading = false;
  String _error = '';

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

  Future<void> _fetchReports() async {
    if (_selectedClasses.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final token = PreferenceService.getString('token');
      final classIds = _selectedClasses.map((c) => c.classId).join(',');
      
      String genderIds = '';
      if (_isMaleSelected && _isFemaleSelected) {
        genderIds = "1,2";
      } else if (_isMaleSelected) {
        genderIds = "1";
      } else if (_isFemaleSelected) {
        genderIds = "2";
      }

      final response = await _apiClient.getStrengthReport(token, classIds, genderIds);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _reports = list.map((e) => StrengthReportData.fromJson(e)).toList();
          });
        } else {
          setState(() {
            _reports = [];
            _error = data['message'] ?? 'No data found';
          });
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load report');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strength Report'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                    ? Center(child: Text(_error.isNotEmpty ? _error : 'Select classes and gender to view report'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          return _buildStrengthCard(_reports[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select Classes", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _showMultiClassDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedClasses.isEmpty
                          ? "Tap to select classes"
                          : _selectedClasses.map((c) => c.className).join(", "),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("Gender:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text("Male"),
                selected: _isMaleSelected,
                onSelected: (val) {
                  setState(() => _isMaleSelected = val);
                  _fetchReports();
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text("Female"),
                selected: _isFemaleSelected,
                onSelected: (val) {
                  setState(() => _isFemaleSelected = val);
                  _fetchReports();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMultiClassDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Classes"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final cls = _classes[index];
                    final isSelected = _selectedClasses.contains(cls);
                    return CheckboxListTile(
                      title: Text(cls.className),
                      value: isSelected,
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) {
                            _selectedClasses.add(cls);
                          } else {
                            _selectedClasses.remove(cls);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                    _fetchReports();
                  },
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStrengthCard(StrengthReportData report) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          "${report.className ?? ''} - ${report.sectionName ?? ''}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        subtitle: Text("Section ID: ${report.sectionId ?? 'N/A'}"),
        trailing: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            report.strength ?? '0',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
