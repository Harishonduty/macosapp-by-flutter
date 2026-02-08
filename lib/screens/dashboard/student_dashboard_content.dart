import 'package:flutter/material.dart';
import 'package:holy_cross_app/widgets/dashboard_grid.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/screens/student/student_homework_screen.dart';
import 'package:holy_cross_app/screens/student/student_time_table_screen.dart';
import 'package:holy_cross_app/screens/student/student_exam_time_table_screen.dart';
import 'package:holy_cross_app/screens/student/student_attendance_screen.dart';
import 'package:holy_cross_app/screens/student/student_leave_request_screen.dart';
import 'package:holy_cross_app/screens/student/student_notification_screen.dart';
import 'package:holy_cross_app/screens/student/student_exam_mark_screen.dart';
import 'package:holy_cross_app/screens/student/student_fee_receipt_screen.dart';

import 'package:holy_cross_app/screens/student/student_gallery_screen.dart';
import 'package:holy_cross_app/screens/student/student_assignment_screen.dart';
import 'package:holy_cross_app/screens/student/student_info_screen.dart';
import 'package:holy_cross_app/screens/student/student_calendar_screen.dart';
import 'package:holy_cross_app/screens/student/student_assignment_report_screen.dart';
import 'package:holy_cross_app/screens/student/student_transport_announcement_screen.dart';
import 'package:holy_cross_app/screens/student/student_project_screen.dart';
import 'package:holy_cross_app/screens/student/student_remarks_screen.dart';
import 'package:holy_cross_app/screens/student/student_lesson_qa_screen.dart';
import 'package:holy_cross_app/screens/student/student_van_info_screen.dart';
import 'package:holy_cross_app/screens/student/student_announcement_screen.dart';
import 'package:holy_cross_app/screens/common/change_password_screen.dart';

class StudentDashboardContent extends StatefulWidget {
  const StudentDashboardContent({super.key});

  @override
  State<StudentDashboardContent> createState() => _StudentDashboardContentState();
}

class _StudentDashboardContentState extends State<StudentDashboardContent> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic> _badgeCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchBadgeCounts();
  }

  Future<void> _fetchBadgeCounts() async {
    try {
      final response = await _apiClient.getViewStatus(
        PreferenceService.getString('token') ?? '',
      );
      if (response.data['status'] == true) {
        setState(() {
          _badgeCounts = response.data['result'] ?? {};
        });
      }
    } catch (e) {
      debugPrint('Error fetching badge counts: $e');
    }
  }

  int _getCount(String key) {
    var val = _badgeCounts[key];
    if (val == null) return 0;
    return int.tryParse(val.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final List<DashboardItem> items = [
      DashboardItem(
        title: "Child Info",
        icon: Icons.person,
        color: Colors.blue,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentInfoScreen()));
        },
      ),
      DashboardItem(
        title: "Home Work",
        icon: Icons.assignment,
        color: Colors.orange,
        badgeCount: _getCount('homework_count'),
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentHomeworkScreen()));
        },
      ),
      DashboardItem(
        title: "Attendance",
        icon: Icons.fact_check,
        color: Colors.green,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentAttendanceScreen()));
        },
      ),
      DashboardItem(
        title: "Class Timetable",
        icon: Icons.event,
        color: Colors.purple,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentTimeTableScreen()));
        },
      ),
      DashboardItem(
        title: "Exam Timetable",
        icon: Icons.calendar_month,
        color: Colors.red,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentExamTimeTableScreen()));
        },
      ),
      DashboardItem(
        title: "Exam Result",
        icon: Icons.grade,
        color: Colors.amber,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentExamMarkScreen()));
        },
      ),
      DashboardItem(
        title: "Calendar",
        icon: Icons.today,
        color: Colors.teal,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentCalendarScreen()));
        },
      ),
      DashboardItem(
        title: "Leave Request",
        icon: Icons.edit_calendar,
        color: Colors.indigo,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLeaveRequestScreen()));
        },
      ),
      DashboardItem(
        title: "Notification",
        icon: Icons.notifications,
        color: Colors.redAccent,
        badgeCount: _getCount('notification_count'),
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentNotificationScreen()));
        },
      ),
      DashboardItem(
        title: "Passenger Details",
        icon: Icons.commute,
        color: Colors.cyan,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentVanInfoScreen()));
        },
      ),
      DashboardItem(
        title: "Payment",
        icon: Icons.receipt_long,
        color: Colors.blueGrey,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentFeeReceiptScreen()));
        },
      ),
      DashboardItem(
        title: "Online Payment",
        icon: Icons.account_balance_wallet,
        color: Colors.green,
        onTap: () {},
      ),
      DashboardItem(
        title: "Announcement",
        icon: Icons.campaign,
        color: Colors.orangeAccent,
        badgeCount: _getCount('announcent_count'),
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentAnnouncementScreen()));
        },
      ),
      DashboardItem(
        title: "Remarks",
        icon: Icons.feedback,
        color: Colors.brown,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentRemarksScreen()));
        },
      ),
      DashboardItem(
        title: "Change Password",
        icon: Icons.vpn_key,
        color: Colors.grey,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
        },
      ),
      DashboardItem(
        title: "Gallery",
        icon: Icons.photo_library,
        color: Colors.pink,
        badgeCount: _getCount('gallery_count'),
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentGalleryScreen()));
        },
      ),
      DashboardItem(
        title: "Project",
        icon: Icons.lightbulb,
        color: Colors.deepPurple,
        badgeCount: _getCount('project_count'),
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentProjectScreen()));
        },
      ),
      DashboardItem(
        title: "Lesson Q&A",
        icon: Icons.quiz,
        color: Colors.blueAccent,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLessonQaScreen()));
        },
      ),
      DashboardItem(
        title: "Assignment",
        icon: Icons.note_add,
        color: Colors.amberAccent,
        badgeCount: _getCount('assignment_count'),
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentAssignmentScreen()));
        },
      ),
      DashboardItem(
        title: "Assignment Report",
        icon: Icons.analytics,
        color: Colors.lightGreen,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentAssignmentReportScreen()));
        },
      ),
      DashboardItem(
        title: "Transport Announcement",
        icon: Icons.record_voice_over,
        color: Colors.orange,
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentTransportAnnouncementScreen()));
        },
      ),
    ];

    return RefreshIndicator(
      onRefresh: _fetchBadgeCounts,
      child: SingleChildScrollView(
        child: Column(
          children: [
            DashboardGrid(items: items),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
