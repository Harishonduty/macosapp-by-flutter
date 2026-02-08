import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/class_attendance_report_data.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:intl/intl.dart';

class ClassAttendanceReportScreen extends StatefulWidget {
  const ClassAttendanceReportScreen({super.key});

  @override
  State<ClassAttendanceReportScreen> createState() => _ClassAttendanceReportScreenState();
}

class _ClassAttendanceReportScreenState extends State<ClassAttendanceReportScreen> {
  final ApiClient _apiClient = ApiClient();
  List<ClassAttendanceReportData> _reports = [];
  List<StaffClass> _classes = [];
  StaffClass? _selectedClass;
  DateTime _selectedDate = DateTime.now();
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
        _fetchReports();
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final token = PreferenceService.getString('token');
      final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
      final classId = _selectedClass?.classId ?? "";
      
      final response = await _apiClient.getClassAttendanceReport(token, formattedDate, classId);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _reports = list.map((e) => ClassAttendanceReportData.fromJson(e)).toList();
          });
        } else {
          setState(() {
            _reports = [];
            _error = data['message'] ?? 'No reports found';
          });
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load report');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Attendance Report'),
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
                    ? Center(child: Text(_error.isNotEmpty ? _error : 'No Reports Found'))
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
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<StaffClass>(
                  value: _selectedClass,
                  decoration: InputDecoration(
                    labelText: 'Select Class',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<StaffClass>(value: null, child: Text("All Classes")),
                    ..._classes.map((c) => DropdownMenuItem(value: c, child: Text(c.className))),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedClass = val);
                    _fetchReports();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                        const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ClassAttendanceReportData report) {
    return Card(
      elevation: 4,
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
                Text(
                  report.className ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.date ?? '',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (report.studentName != null) ...[
              _buildInfoRow(Icons.person, "Student", report.studentName!),
              _buildInfoRow(Icons.check_circle_outline, "Status", report.attendanceStatus ?? 'N/A', 
                  color: report.attendanceStatus == "Present" ? Colors.green : Colors.red),
            ] else ...[
              Row(
                children: [
                   _buildCounter("TOTAL", report.totalStudents ?? '0', Colors.blue),
                   const SizedBox(width: 16),
                   _buildCounter("PRESENT", report.presentCount ?? '0', Colors.green),
                   const SizedBox(width: 16),
                   _buildCounter("ABSENT", report.absentCount ?? '0', Colors.red),
                ],
              ),
              if (report.absentNames != null && report.absentNames!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text("Absentees:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(report.absentNames!, style: TextStyle(color: Colors.red[700], fontSize: 13)),
              ]
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color ?? Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildCounter(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
