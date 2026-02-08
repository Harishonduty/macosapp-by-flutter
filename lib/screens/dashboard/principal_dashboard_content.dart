import 'package:flutter/material.dart';
import 'package:holy_cross_app/widgets/dashboard_grid.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/screens/principal/class_attendance_report_screen.dart';
import 'package:holy_cross_app/screens/principal/strength_report_screen.dart';
import 'package:holy_cross_app/screens/principal/principal_activity_report_screen.dart';
import 'package:holy_cross_app/screens/principal/principal_staff_list_screen.dart';
import 'package:holy_cross_app/screens/principal/principal_student_info_screen.dart';
import 'package:holy_cross_app/screens/principal/exam_mark_entry_screen.dart';
import 'package:holy_cross_app/screens/principal/admin_announcement_screen.dart';
import 'package:holy_cross_app/screens/principal/principal_staff_remarks_screen.dart';
import 'package:holy_cross_app/screens/principal/principal_circular_screen.dart';
import 'package:holy_cross_app/screens/principal/add_admin_content_screen.dart';
import 'package:holy_cross_app/screens/principal/staff_leave_approval_screen.dart';
import 'package:holy_cross_app/screens/principal/principal_homework_list_screen.dart';
import 'package:holy_cross_app/screens/principal/add_homework_screen.dart';
import 'package:holy_cross_app/screens/staff/mark_student_attendance_screen.dart';

class PrincipalDashboardContent extends StatefulWidget {
  const PrincipalDashboardContent({super.key});

  @override
  State<PrincipalDashboardContent> createState() => _PrincipalDashboardContentState();
}

class _PrincipalDashboardContentState extends State<PrincipalDashboardContent> {
  String _selectedCategory = "ALL";

  final List<String> _categories = [
    "ALL",
    "Profile",
    "Attendance",
    "Payment",
    "Student Transport Details",
    "Calendar and Gallery",
    "Reports",
    "Class Timetable",
    "Examination",
    "Remark",
    "Homework"
  ];

  Map<String, List<DashboardItem>> get _categorizedItems => {
    "Profile": [
      DashboardItem(title: "Student", icon: Icons.person, color: Colors.blue, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalStudentInfoScreen()));
      }),
      DashboardItem(title: "Teaching Staff", icon: Icons.school, color: Colors.green, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalStaffListScreen(category: StaffCategory.teaching)));
      }),
      DashboardItem(title: "Non-Teaching Staff", icon: Icons.work, color: Colors.orange, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalStaffListScreen(category: StaffCategory.nonTeaching)));
      }),
    ],
    "Attendance": [
      DashboardItem(
        title: "Student Attendance",
        icon: Icons.how_to_reg,
        color: Colors.purple,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MarkStudentAttendanceScreen()));
        },
      ),
      DashboardItem(title: "Late Attendance", icon: Icons.timer, color: Colors.red, onTap: () {}),
      DashboardItem(title: "Leave Request", icon: Icons.event_busy, color: Colors.teal, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffLeaveApprovalScreen()));
      }),
      DashboardItem(title: "Staff Attendance", icon: Icons.badge, color: Colors.indigo, onTap: () {}),
      DashboardItem(title: "Staff Substitute", icon: Icons.switch_account, color: Colors.cyan, onTap: () {}),
      DashboardItem(title: "Bio Metric Log", icon: Icons.fingerprint, color: Colors.blueGrey, onTap: () {}),
      DashboardItem(title: "Appointment", icon: Icons.schedule, color: Colors.brown, onTap: () {}),
      DashboardItem(title: "Class Teachers", icon: Icons.supervisor_account, color: Colors.deepOrange, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalStaffListScreen(category: StaffCategory.teaching)));
      }),
    ],
    "Payment": [
      DashboardItem(title: "Fee Collection", icon: Icons.payments, color: Colors.green, onTap: () {}),
      DashboardItem(title: "Student View", icon: Icons.person_search, color: Colors.blue, onTap: () {}),
      DashboardItem(title: "Online Payment", icon: Icons.account_balance, color: Colors.indigo, onTap: () {}),
    ],
    "Student Transport Details": [
      DashboardItem(title: "Van Info", icon: Icons.bus_alert, color: Colors.amber, onTap: () {}),
      DashboardItem(title: "Transport Announcement", icon: Icons.campaign, color: Colors.orange, onTap: () {}),
    ],
    "Calendar and Gallery": [
      DashboardItem(title: "Calendar", icon: Icons.calendar_month, color: Colors.teal, onTap: () {}),
      DashboardItem(title: "Gallery", icon: Icons.collections, color: Colors.pink, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAdminContentScreen(contentType: AdminContentType.gallery)));
      }),
      DashboardItem(title: "Admin Project", icon: Icons.lightbulb, color: Colors.amber, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAdminContentScreen(contentType: AdminContentType.project)));
      }),
      DashboardItem(title: "Admin Assignment", icon: Icons.note_add, color: Colors.blue, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAdminContentScreen(contentType: AdminContentType.assignment)));
      }),
      DashboardItem(title: "Circular", icon: Icons.campaign, color: Colors.orange, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalCircularScreen()));
      }),
      DashboardItem(title: "Admin Announcement", icon: Icons.announcement, color: Colors.red, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnnouncementScreen()));
      }),
    ],
    "Reports": [
      DashboardItem(title: "Assignment Report", icon: Icons.analytics, color: Colors.blue, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalActivityReportScreen(reportType: PrincipalReportType.assignment)));
      }),
      DashboardItem(title: "Project Report", icon: Icons.insights, color: Colors.green, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalActivityReportScreen(reportType: PrincipalReportType.project)));
      }),
      DashboardItem(title: "Gallery Report", icon: Icons.photo_library, color: Colors.purple, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalActivityReportScreen(reportType: PrincipalReportType.gallery)));
      }),
      DashboardItem(title: "Strength Report", icon: Icons.groups, color: Colors.teal, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StrengthReportScreen()));
      }),
      DashboardItem(title: "Absent Report", icon: Icons.person_off, color: Colors.red, onTap: () {}),
      DashboardItem(title: "Attendance Report", icon: Icons.fact_check, color: Colors.indigo, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassAttendanceReportScreen()));
      }),
    ],
    "Class Timetable": [
      DashboardItem(title: "All Class Timetable", icon: Icons.table_chart, color: Colors.blue, onTap: () {}),
      DashboardItem(title: "All Staff Timetable", icon: Icons.grid_on, color: Colors.green, onTap: () {}),
    ],
    "Examination": [
      DashboardItem(title: "Exam Mark Entry", icon: Icons.edit_note, color: Colors.orange, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamMarkEntryScreen()));
      }),
    ],
    "Remark": [
      DashboardItem(title: "Student Remark", icon: Icons.comment, color: Colors.blue, onTap: () {}),
      DashboardItem(title: "Staff Remark", icon: Icons.forum, color: Colors.green, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalStaffRemarksScreen()));
      }),
    ],
    "Homework": [
      DashboardItem(title: "Add Homework", icon: Icons.add_task, color: Colors.purple, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHomeworkScreen()));
      }),
      DashboardItem(title: "View Homework", icon: Icons.preview, color: Colors.teal, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalHomeworkListScreen()));
      }),
    ],
  };

  List<DashboardItem> get _filteredItems {
    if (_selectedCategory == "ALL") {
      List<DashboardItem> allItems = [];
      _categorizedItems.values.forEach(allItems.addAll);
      return allItems;
    }
    return _categorizedItems[_selectedCategory] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category Selector
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                DashboardGrid(items: _filteredItems),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
