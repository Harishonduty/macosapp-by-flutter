import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/principal_activity_report_data.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:intl/intl.dart';

enum PrincipalReportType { assignment, project, gallery }

class PrincipalActivityReportScreen extends StatefulWidget {
  final PrincipalReportType reportType;

  const PrincipalActivityReportScreen({super.key, required this.reportType});

  @override
  State<PrincipalActivityReportScreen> createState() => _PrincipalActivityReportScreenState();
}

class _PrincipalActivityReportScreenState extends State<PrincipalActivityReportScreen> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _reports = [];
  List<StaffClass> _classes = [];
  final List<StaffClass> _selectedClasses = [];
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  String get _title {
    switch (widget.reportType) {
      case PrincipalReportType.assignment: return "Assignment Report";
      case PrincipalReportType.project: return "Project Report";
      case PrincipalReportType.gallery: return "Gallery Report";
    }
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
      final fromStr = DateFormat('yyyy-MM-dd').format(_fromDate);
      final toStr = DateFormat('yyyy-MM-dd').format(_toDate);

      late final dynamic response;
      switch (widget.reportType) {
        case PrincipalReportType.assignment:
          response = await _apiClient.getAssignmentReport(token, classIds, fromStr, toStr);
          break;
        case PrincipalReportType.project:
          response = await _apiClient.getProjectReport(token, classIds, fromStr, toStr);
          break;
        case PrincipalReportType.gallery:
          response = await _apiClient.getGalleryReport(token, classIds, fromStr, toStr);
          break;
      }

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            switch (widget.reportType) {
              case PrincipalReportType.assignment:
                _reports = list.map((e) => AssignmentReportData.fromJson(e)).toList();
                break;
              case PrincipalReportType.project:
                _reports = list.map((e) => ProjectReportData.fromJson(e)).toList();
                break;
              case PrincipalReportType.gallery:
                _reports = list.map((e) => GalleryReportData.fromJson(e)).toList();
                break;
            }
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
        title: Text(_title),
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
                    ? Center(child: Text(_error.isNotEmpty ? _error : 'Select classes and dates to view report'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          return _buildReportCard(_reports[index]);
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
              Expanded(
                child: _buildDatePicker("From Date", _fromDate, (d) {
                  setState(() => _fromDate = d);
                  _fetchReports();
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePicker("To Date", _toDate, (d) {
                  setState(() => _toDate = d);
                  _fetchReports();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime value, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
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

  Widget _buildReportCard(dynamic report) {
    String title = "";
    String staff = "";
    String date = "";
    String? path = "";

    if (report is AssignmentReportData) {
      title = report.title ?? 'No Title';
      staff = report.staffName ?? 'N/A';
      date = report.date ?? report.entryDate ?? '';
      path = report.path;
    } else if (report is ProjectReportData) {
      title = report.title ?? 'No Title';
      staff = report.staffName ?? 'N/A';
      date = report.date ?? report.entryDate ?? '';
      path = report.path;
    } else if (report is GalleryReportData) {
      title = report.title ?? 'No Title';
      staff = report.staffName ?? 'N/A';
      date = report.entryDate ?? '';
      path = report.path;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                  ),
                ),
                if (path != null && path.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.download, color: AppColors.primary),
                    onPressed: () {
                      // Handle file view/download
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Staff: $staff", style: const TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Date: $date", style: const TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
