import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/student_attendance_data.dart';
import 'package:holy_cross_app/models/fee_class_wise_data.dart';

class PrincipalFeeCollectionScreen extends StatefulWidget {
  const PrincipalFeeCollectionScreen({super.key});

  @override
  State<PrincipalFeeCollectionScreen> createState() => _PrincipalFeeCollectionScreenState();
}

class _PrincipalFeeCollectionScreenState extends State<PrincipalFeeCollectionScreen> with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;

  List<StaffClass> _classes = [];
  List<StudentAttendanceData> _students = [];
  List<FeeClassWiseData> _feeData = [];
  List<FeeClassWiseData> _filteredFeeData = [];

  StaffClass? _selectedClass;
  StudentAttendanceData? _selectedStudent;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _resetData();
      }
    });
    _fetchClasses();
  }

  void _resetData() {
    setState(() {
      _selectedClass = null;
      _selectedStudent = null;
      _students = [];
      _feeData = [];
      _filteredFeeData = [];
      _searchController.clear();
    });
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

  Future<void> _fetchStudents(String classId) async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final now = DateTime.now();
      final dateStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
      final response = await _apiClient.getClassWiseStudentAttendanceByDate(dateStr, classId, token);
      if (response.data['status'] == true) {
        final List list = response.data['result']['lstStudent'] ?? [];
        setState(() {
          _students = list.map((e) => StudentAttendanceData.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFeeData() async {
    if (_selectedClass == null) return;
    if (_tabController.index == 1 && _selectedStudent == null) return;

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = _tabController.index == 0
          ? await _apiClient.getClassWiseFee(token, "1", _selectedClass!.classId)
          : await _apiClient.getStudentWiseFee(token, "1", _selectedClass!.classId, _selectedStudent!.studentId!);

      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _feeData = list.map((e) => FeeClassWiseData.fromJson(e)).toList();
          _filteredFeeData = _feeData;
        });
      } else {
        setState(() {
          _feeData = [];
          _filteredFeeData = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching fee data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredFeeData = _feeData.where((f) {
        final name = (f.firstName ?? f.name ?? "").toLowerCase();
        final id = (f.studentId ?? "").toLowerCase();
        final reg = (f.studentRegisterNumber ?? "").toLowerCase();
        return name.contains(query.toLowerCase()) || 
               id.contains(query.toLowerCase()) || 
               reg.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fee Collection"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Class Wise"),
            Tab(text: "Student Wise"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          if (_feeData.isNotEmpty) _buildSearchBar(),
          Expanded(
            child: _isLoading && _feeData.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _feeData.isEmpty
                    ? const Center(child: Text("Select filters to view fee details"))
                    : _buildFeeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          _buildDropdown<StaffClass>(
            label: "Select Class",
            value: _selectedClass,
            items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c.className))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedClass = val;
                _selectedStudent = null;
                _students = [];
                _feeData = [];
                _filteredFeeData = [];
              });
              if (val != null) {
                if (_tabController.index == 0) {
                  _fetchFeeData();
                } else {
                  _fetchStudents(val.classId);
                }
              }
            },
          ),
          if (_tabController.index == 1) ...[
            const SizedBox(height: 12),
            _buildDropdown<StudentAttendanceData>(
              label: "Select Student",
              value: _selectedStudent,
              items: _students.map((s) => DropdownMenuItem(value: s, child: Text(s.name ?? ''))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedStudent = val;
                  _feeData = [];
                  _filteredFeeData = [];
                });
                if (val != null) _fetchFeeData();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSearch,
        decoration: InputDecoration(
          hintText: "Search by name or ID...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          fillColor: Colors.grey[100],
          filled: true,
        ),
      ),
    );
  }

  Widget _buildFeeList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredFeeData.length,
      itemBuilder: (context, index) {
        final fee = _filteredFeeData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
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
                        fee.name ?? fee.firstName ?? "N/A",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (fee.status ?? "").toLowerCase() == 'paid' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fee.status ?? "N/A",
                        style: TextStyle(
                          color: (fee.status ?? "").toLowerCase() == 'paid' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildFeeRow("Register No", fee.studentRegisterNumber ?? "N/A"),
                _buildFeeRow("Frequency", fee.frequencyName ?? "N/A"),
                _buildFeeRow("Total Amount", "₹${fee.amount ?? '0'}"),
                _buildFeeRow("Paid Amount", "₹${fee.paid ?? '0'}", color: Colors.green),
                _buildFeeRow("Discount", "₹${fee.discount ?? '0'}", color: Colors.blue),
                _buildFeeRow("Balance", "₹${fee.balance ?? '0'}", color: Colors.red, isBold: true),
                if (fee.paymentDate != null && fee.paymentDate!.isNotEmpty)
                   _buildFeeRow("Last Payment", fee.paymentDate!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeeRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
