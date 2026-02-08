import 'package:flutter/material.dart';
import 'package:holy_cross_app/widgets/dashboard_grid.dart';
import 'package:holy_cross_app/screens/staff/mark_student_attendance_screen.dart';
import 'package:holy_cross_app/screens/staff/staff_homework_screen.dart';
import 'package:holy_cross_app/screens/staff/staff_remarks_screen.dart';
import 'package:holy_cross_app/screens/staff/add_student_remarks_screen.dart';
import 'package:holy_cross_app/screens/staff/staff_announcement_screen.dart';
import 'package:holy_cross_app/screens/staff/staff_circular_screen.dart';
import 'package:holy_cross_app/screens/staff/staff_timetable_screen.dart';
import 'package:holy_cross_app/screens/staff/staff_info_screen.dart';
import 'package:holy_cross_app/screens/staff/student_leave_approval_screen.dart';
import 'package:holy_cross_app/screens/staff/exam_mark_list_screen.dart';
import 'package:holy_cross_app/screens/staff/staff_leave_request_screen.dart';
import 'package:holy_cross_app/screens/common/change_password_screen.dart';
import 'package:holy_cross_app/screens/common/gallery_screen.dart';

class StaffDashboardContent extends StatelessWidget {
  const StaffDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DashboardItem> items = [
      DashboardItem(
        title: "Staff Info",
        icon: Icons.info,
        color: Colors.blue,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffInfoScreen()));
        },
      ),
      DashboardItem(
        title: "Student Attendance",
        icon: Icons.how_to_reg,
        color: Colors.green,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MarkStudentAttendanceScreen()));
        },
      ),
      DashboardItem(
        title: "Home Work",
        icon: Icons.assignment,
        color: Colors.orange,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffHomeworkScreen()));
        },
      ),
      DashboardItem(
        title: "Announcement",
        icon: Icons.campaign,
        color: Colors.purple,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffAnnouncementScreen()));
        },
      ),
      DashboardItem(
        title: "Student Leave Approval",
        icon: Icons.approval,
        color: Colors.teal,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLeaveApprovalScreen()));
        },
      ),
      DashboardItem(
        title: "Staff Leave Request",
        icon: Icons.event_note,
        color: Colors.red,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffLeaveRequestScreen()));
        },
      ),
      DashboardItem(
        title: "Send Student Remarks",
        icon: Icons.rate_review,
        color: Colors.amber,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStudentRemarksScreen()));
        },
      ),
      DashboardItem(
        title: "Staff Remarks",
        icon: Icons.comment,
        color: Colors.indigo,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffRemarksScreen()));
        },
      ),
      DashboardItem(
        title: "Circular",
        icon: Icons.description,
        color: Colors.cyan,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffCircularScreen()));
        },
      ),
      DashboardItem(
        title: "Change Password",
        icon: Icons.lock,
        color: Colors.blueGrey,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
        },
      ),
      DashboardItem(
        title: "Gallery",
        icon: Icons.collections,
        color: Colors.pink,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
        },
      ),
      DashboardItem(
        title: "Class Timetable",
        icon: Icons.calendar_today,
        color: Colors.brown,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffTimetableScreen()));
        },
      ),
      DashboardItem(
        title: "Exam Mark Entry",
        icon: Icons.edit_note,
        color: Colors.deepOrange,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamMarkListScreen()));
        },
      ),
      DashboardItem(
        title: "Online Payment",
        icon: Icons.payment,
        color: Colors.green,
        onTap: () {},
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          DashboardGrid(items: items),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
