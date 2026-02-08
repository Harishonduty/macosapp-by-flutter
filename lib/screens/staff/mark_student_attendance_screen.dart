import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_class.dart';
import 'package:holy_cross_app/models/student_attendance_data.dart';
import 'package:holy_cross_app/models/post_attendance.dart';

class MarkStudentAttendanceScreen extends StatefulWidget {
  const MarkStudentAttendanceScreen({super.key});

  @override
  State<MarkStudentAttendanceScreen> createState() => _MarkStudentAttendanceScreenState();
}

class _MarkStudentAttendanceScreenState extends State<MarkStudentAttendanceScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  
  List<StaffClass> _classes = [];
  List<StudentAttendanceData> _students = [];
  List<StudentAttendanceData> _filteredStudents = [];
  List<Map<String, String>> _sessions = [];
  List<Map<String, String>> _absentTypes = [];

  StaffClass? _selectedClass;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchClasses();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _students;
      } else {
        _filteredStudents = _students.where((student) {
          return student.name.toLowerCase().contains(query) ||
                 student.admissionNo.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentClasses(token);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final bool isSuccess = (data['status'] == true) || (data['statusCode'] == 200);
        
        if (isSuccess && data['result'] != null) {
          if (data['result'] is List) {
            final List list = data['result'];
            setState(() {
              _classes = list.map((e) => StaffClass.fromJson(e)).toList();
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStudents() async {
    if (_selectedClass == null) return;
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final formattedDate = "${_selectedDate.day.toString().padLeft(2,'0')}/${_selectedDate.month.toString().padLeft(2,'0')}/${_selectedDate.year}";

      final response = await _apiClient.getClassWiseStudentAttendance(
        token,
        formattedDate,
        _selectedClass!.classesId,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final bool isSuccess = (data['status'] == true) || (data['statusCode'] == 200);

        if (isSuccess && data['result'] != null) {
          final result = data['result'];
          
          final List studentList = result['lstStudent'] ?? [];
          final List sessionList = result['Session'] ?? result['session'] ?? [];
          final List absentTypeList = result['AbsentType'] ?? result['absentType'] ?? [];

          final students = studentList.map((e) => StudentAttendanceData.fromJson(e)).toList();
          final sessions = sessionList.map<Map<String, String>>((e) => {
              'id': e['SESSION_ID']?.toString() ?? e['session_id']?.toString() ?? '',
              'name': e['SESSION_TYPE']?.toString() ?? e['session_type']?.toString() ?? '',
            }).toList();
          final absentTypes = absentTypeList.map<Map<String, String>>((e) => {
              'id': e['REMARK_ID']?.toString() ?? e['remark_id']?.toString() ?? '',
              'name': e['REMARK_NAME']?.toString() ?? e['REMARKS']?.toString() ?? e['remarks']?.toString() ?? '',
            }).toList();

          // Mark students as selected if they already have attendance marked
          for (var student in students) {
            if (student.attendanceId.isNotEmpty && student.attendanceId != 'null') {
              student.isSelected = true;
              // If absentType or session is empty, set defaults
              if (student.absentType.isEmpty && absentTypes.length > 1) {
                student.absentType = absentTypes[1]['id']!; // Absent
              }
              if (student.session.isEmpty && sessions.isNotEmpty) {
                student.session = sessions[0]['id']!; // Default session
              }
            }
          }

          setState(() {
            _students = students;
            _filteredStudents = students;
            _sessions = sessions;
            _absentTypes = absentTypes;
            _error = '';
          });
        } else {
          final msg = data['message'] ?? 'No students found';
          setState(() {
            _students = [];
            _filteredStudents = [];
            _error = msg;
          });
        }
      } else {
        setState(() => _error = 'Failed to load students');
      }
    } catch (e) {
      setState(() => _error = 'Failed to load students: $e');
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
      if (_selectedClass != null) {
        _fetchStudents();
      }
    }
  }
  
  Future<void> _submitAttendance() async {
    final selectedStudents = _students.where((s) => s.isSelected).toList();
    if (selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students selected as absent'))
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Attendance'),
        content: Text('Mark ${selectedStudents.length} students as absent?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    
    try {
      final token = PreferenceService.getString('token');
      final formattedDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2,'0')}-${_selectedDate.day.toString().padLeft(2,'0')}";

      List<Map<String, dynamic>> postData = selectedStudents.map((s) => PostAttendance(
        studentId: s.studentId,
        studentName: s.name,
        absentType: s.absentType,
        session: s.session,
        absentDate: formattedDate,
        attendanceId: s.attendanceId,
        classId: s.classId
      ).toJson()).toList();

      final response = await _apiClient.insertStudentAttendance(token, postData);
      if(response.data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'Success'))
          );
        }
        _fetchStudents();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'Failed'))
          );
        }
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Student Attendance',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Class and Date Selectors
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Class Selector
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<StaffClass>(
                        isExpanded: true,
                        value: _selectedClass,
                        hint: const Text(
                          'Select Class',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                        items: _classes.map((StaffClass c) {
                          return DropdownMenuItem<StaffClass>(
                            value: c,
                            child: Text(
                              "${c.className} ${c.sectionName}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (StaffClass? newValue) {
                          setState(() {
                            _selectedClass = newValue;
                          });
                          _fetchStudents();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Date Selector
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search Icon
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: InkWell(
              onTap: () {
                // Show search dialog or expand search field
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Search Students'),
                    content: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Enter student name or admission no',
                        prefixIcon: Icon(Icons.search),
                      ),
                      autofocus: true,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.black54, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Search students...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Student List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? Center(
                        child: Text(
                          _error.isNotEmpty ? _error : 'No students found',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Column(
                              children: [
                                // Student name and checkbox
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          student.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: student.isSelected,
                                            activeColor: const Color(0xFF00BCD4),
                                            onChanged: (bool? value) {
                                              setState(() {
                                                student.isSelected = value ?? false;
                                                if (student.isSelected) {
                                                  // Set to Absent
                                                  if (_absentTypes.length > 1) {
                                                    student.absentType = _absentTypes[1]['id']!;
                                                  } else if (_absentTypes.isNotEmpty) {
                                                    student.absentType = _absentTypes[0]['id']!;
                                                  }
                                                  // Default to Full Day
                                                  if (_sessions.isNotEmpty) {
                                                    student.session = _sessions[0]['id']!;
                                                  }
                                                } else {
                                                  // Set to Present
                                                  if (_absentTypes.isNotEmpty) {
                                                    student.absentType = _absentTypes[0]['id']!;
                                                  }
                                                  student.session = '';
                                                }
                                              });
                                            },
                                          ),
                                          const Text(
                                            'Absent',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Session selection (shown when checked)
                                if (student.isSelected && _sessions.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                    child: Row(
                                      children: _sessions.map((sess) {
                                        // Map session names to short forms
                                        String displayName = sess['name']!;
                                        if (displayName.toLowerCase().contains('full')) {
                                          displayName = 'Full Day';
                                        } else if (displayName.toLowerCase().contains('fore') || 
                                                   displayName.toLowerCase().contains('fn')) {
                                          displayName = 'FN';
                                        } else if (displayName.toLowerCase().contains('after') || 
                                                   displayName.toLowerCase().contains('an')) {
                                          displayName = 'AN';
                                        }
                                        
                                        return Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Radio<String>(
                                                value: sess['id']!,
                                                groupValue: student.session,
                                                activeColor: const Color(0xFF00BCD4),
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                visualDensity: VisualDensity.compact,
                                                onChanged: (val) {
                                                  setState(() {
                                                    student.session = val!;
                                                  });
                                                },
                                              ),
                                              Text(
                                                displayName,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _filteredStudents.isNotEmpty
          ? FloatingActionButton(
              onPressed: _submitAttendance,
              backgroundColor: const Color(0xFF2196F3),
              child: const Icon(Icons.check, color: Colors.white),
            )
          : null,
    );
  }
}
