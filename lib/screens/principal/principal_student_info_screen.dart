import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/admin_student_data.dart';

class PrincipalStudentInfoScreen extends StatefulWidget {
  const PrincipalStudentInfoScreen({super.key});

  @override
  State<PrincipalStudentInfoScreen> createState() => _PrincipalStudentInfoScreenState();
}

class _PrincipalStudentInfoScreenState extends State<PrincipalStudentInfoScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffClass> _classes = [];
  List<AdminStudentData> _students = [];
  StaffClass? _selectedClass;
  AdminStudentData? _selectedStudent;
  AdminStudentDataById? _studentDetail;
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
      print("Response Data (Classes): ${response.data}"); // Debug
      if (response.statusCode == 200) {
        final data = response.data;
        List list = [];
        if (data is List) {
          list = data;
        } else if (data['result'] != null) {
          list = data['result'];
        }
        
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
      print("\n\n=== STUDENT API REQUEST START ===");
      print("Class ID: $classId");
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getAdminClassWiseStudent(token, classId);
      print("Status Code: ${response.statusCode}");
      print("Response Data (Students): ${response.data}"); // Keep this line as is or similar
      print("=== STUDENT API RESPONSE END ===\n\n");
      
      if (response.statusCode == 200) {
        final data = response.data;
        List list = [];
        // Handle nested result structure
        if (data['result'] != null) {
          if (data['result'] is List) {
             list = data['result'];
          } else if (data['result']['lstStudentInfo'] != null) {
             // Sometimes it might be nested further, checking common patterns
             list = data['result']['lstStudentInfo'];
          } else {
             // Fallback if result is a map but we don't know the key
             // Check if 'result' itself is iterable or try to find a list value
             try {
                // If the API returns { result: [ ... ] } this is covered above.
                // If it returns { result: { students: [ ... ] } }
                // Let's assume for now it's either direct list or list under 'result'
                // based on previous successful screens.
                print("Warning: Unknown student list structure inside result");
             } catch (e) { print(e); }
          }
        } else if (data is List) {
          list = data;
        }

        setState(() {
          _students = list.map((e) => AdminStudentData.fromJson(e)).toList();
          _selectedStudent = null;
          _studentDetail = null;
        });
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStudentDetail(String studentId) async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getAdminStudentById(token, studentId);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        if (list.isNotEmpty) {
          setState(() {
            _studentDetail = AdminStudentDataById.fromJson(list[0]);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching student detail: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Information"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdowns(),
            const SizedBox(height: 24),
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _studentDetail != null
                  ? _buildStudentProfile()
                  : const Center(child: Text("Select class and student to view details")),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<StaffClass>(
              value: _selectedClass,
              decoration: const InputDecoration(labelText: "Select Class"),
              items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c.className))).toList(),
              onChanged: (val) {
                if (val != _selectedClass) {
                  setState(() {
                    _selectedClass = val;
                    _students = []; // Clear student list
                    _selectedStudent = null; // Clear selected student
                    _studentDetail = null; // Clear student detail
                  });
                  if (val != null) _fetchStudents(val.classesId);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AdminStudentData>(
              value: _selectedStudent,
              decoration: const InputDecoration(labelText: "Select Student"),
              items: _students.map((s) => DropdownMenuItem(value: s, child: Text(s.firstName ?? ''))).toList(),
              onChanged: (val) {
                setState(() => _selectedStudent = val);
                if (val != null && val.studentId != null) _fetchStudentDetail(val.studentId!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentProfile() {
    final detail = _studentDetail!;
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: detail.photoPath != null ? NetworkImage(detail.photoPath!) : null,
            child: detail.photoPath == null ? const Icon(Icons.person, size: 50, color: AppColors.primary) : null,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            detail.firstName ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoCard([
          _buildInfoRow(Icons.numbers, "Admission No", detail.admissionNo),
          _buildInfoRow(Icons.class_, "Class", detail.className),
          _buildInfoRow(Icons.format_list_numbered, "Roll No", detail.rollNumber),
          _buildInfoRow(Icons.cake, "DOB", detail.dob),
          _buildInfoRow(Icons.bloodtype, "Blood Group", detail.bloodGroupId),
          _buildInfoRow(Icons.person_outline, "Gender", detail.genderName),
        ], "Academic Details"),
        const SizedBox(height: 16),
        _buildInfoCard([
          _buildInfoRow(Icons.person, "Father's Name", detail.fatherName),
          _buildInfoRow(Icons.phone, "Father's Mobile", detail.fatherMobile),
          _buildInfoRow(Icons.person_pin, "Mother's Name", detail.motherName),
          _buildInfoRow(Icons.phone_android, "Mother's Mobile", detail.motherMobile),
        ], "Guardian Details"),
        const SizedBox(height: 16),
        _buildInfoCard([
          _buildInfoRow(Icons.home, "Address", detail.permanentAddress),
        ], "Contact Details"),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children, String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }
}
