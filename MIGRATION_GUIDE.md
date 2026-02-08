
# Migration Guide - Java to Flutter Conversion

This guide tracks the progress of migrating screens and functionalities from the original Java Android project to the new Flutter application.

## 1. Authentication
| Screen/Feature | Original File | Flutter File | Status |
| :--- | :--- | :--- | :--- |
| Login Screen | `LoginActivity.java` | `lib/screens/login_screen.dart` | ✅ Done |
| Splash Screen | `SplashActivity.java` | `lib/screens/splash_screen.dart` | ✅ Done |
| Landing/Home | `SFSLandingActivity.java` | `lib/screens/landing_screen.dart` | ✅ Done |

## 2. Common/Base
| Screen/Feature | Original File | Flutter File | Status |
| :--- | :--- | :--- | :--- |
| Dashboard Grid | N/A | `lib/widgets/dashboard_grid.dart` | ✅ Done |
| Api Client | `ApiClient.java` | `lib/networks/api_client.dart` | ✅ Done |
| Preference Service | `SharedPreferenceClass.java` | `lib/utils/preference_service.dart` | ✅ Done |

## 3. Student Module
| Screen/Feature | Original File | Flutter File | Status |
| :--- | :--- | :--- | :--- |
| Student Home | `StudentHomeFragment.java` | `lib/screens/home/student_home_content.dart` | ✅ Done |
| Student Dashboard | `StudentDashboardFragment.java` | `lib/screens/dashboard/student_dashboard_content.dart` | ✅ Done |
| Announcement | `StudentAnnouncementActivity.java` | `lib/screens/student/student_announcement_screen.dart` | ✅ Done |
| Class Timetable | `StudentTimeTableActivity.java` | `lib/screens/student/student_time_table_screen.dart` | ✅ Done |
| Exam Timetable | `StudentExamTimetableActivity.java` | `lib/screens/student/student_exam_time_table_screen.dart` | ✅ Done |
| Lesson Q&A | `LessonQuestionAnswerActivity.java` | `lib/screens/student/student_lesson_qa_screen.dart` | ✅ Done |
| Assignment | `StudentAssignmentActivity.java` | `lib/screens/student/student_assignment_screen.dart` | ✅ Done |
| Assignment Report | `StudentAssignmentReportActivity.java` | `lib/screens/student/student_assignment_report_screen.dart` | ✅ Done |
| Attendance | `StudentAttendanceListActivity.java` | `lib/screens/student/student_attendance_screen.dart` | ✅ Done |
| Calendar | `StudentCalendarActivity.java` | `lib/screens/student/student_calendar_screen.dart` | ✅ Done |
| Exam Marks | `StudentExamMarkActivity.java` | `lib/screens/student/student_exam_mark_screen.dart` | ✅ Done |
| Fee Receipt | `StudentFeeReceiptActivity.java` | `lib/screens/student/student_fee_receipt_screen.dart` | ✅ Done |
| Gallery | `StudentGalleryActivity.java` | `lib/screens/student/student_gallery_screen.dart` | ✅ Done |
| Homework | `StudentHomeworkActivity.java` | `lib/screens/student/student_homework_screen.dart` | ✅ Done |
| Student Info | `StudentInfoActivity.java` | `lib/screens/student/student_info_screen.dart` | ✅ Done |
| Leave Request | `StudentLeaveRequestActivity.java` | `lib/screens/student/student_leave_request_screen.dart` | ✅ Done |
| Notification | `StudentNotificationActivity.java` | `lib/screens/student/student_notification_screen.dart` | ✅ Done |
| Project | `StudentProjectActivity.java` | `lib/screens/student/student_project_screen.dart` | ✅ Done |
| Remarks | `StudentRemarksActivity.java` | `lib/screens/student/student_remarks_screen.dart` | ✅ Done |
| Transport Announcement | `StudentTransportAnnouncementActivity.java` | `lib/screens/student/student_transport_announcement_screen.dart` | ✅ Done |
| Transport Details | `StudentTransportDetailsActivity.java` | `lib/screens/student/student_transport_details_screen.dart` | ✅ Done |
| Van Info | `StudentVanInfo.java` | `lib/screens/student/student_van_info_screen.dart` | ✅ Done |

## 4. Staff Module
| Screen/Feature | Original File | Flutter File | Status |
| :--- | :--- | :--- | :--- |
| Staff Home | `StaffHomeFragment.java` | `lib/screens/home/staff_home_content.dart` | ✅ Done |
| Staff Dashboard | `StaffDashboardFragment.java` | `lib/screens/dashboard/staff_dashboard_content.dart` | ✅ Done |
| Add Announcement | `AddStaffAnnouncementActivity.java` | `lib/screens/staff/add_staff_announcement_screen.dart` | ✅ Done |
| Add Homework | `AddStudentHomeworkActivity.java` | `lib/screens/staff/add_student_homework_screen.dart` | ✅ Done |
| Add Remarks | `AddStudentRemarksActivity.java` | `lib/screens/staff/add_student_remarks_screen.dart` | ✅ Done |
| Class Timetable | `ClassTimetableActivity.java` | `lib/screens/staff/staff_timetable_screen.dart` | ✅ Done |
| Mark Attendance | `MarkStudentAttendanceActivity.java` | `lib/screens/staff/mark_student_attendance_screen.dart` | ✅ Done |
| Staff Announcement | `StaffAnnouncementActivity.java` | `lib/screens/staff/staff_announcement_screen.dart` | ✅ Done |
| Staff Attendance | `StaffAttendanceActivity.java` |  | 📅 To Do |
| Staff Circular | `StaffCircularActivity.java` | `lib/screens/staff/staff_circular_screen.dart` | ✅ Done |
| Staff Homework | `StaffHomeworkActivity.java` | `lib/screens/staff/staff_homework_screen.dart` | ✅ Done |
| Staff Info | `StaffInfoActivity.java` | `lib/screens/staff/staff_info_screen.dart` | ✅ Done |
| Staff Remarks | `StaffRemarksActivity.java` | `lib/screens/staff/staff_remarks_screen.dart` | ✅ Done |
| Leave Request Approval | `StudentLeaveRequestApprovalActivity.java` | `lib/screens/staff/student_leave_approval_screen.dart` | ✅ Done |
| Exam Mark Entry | `ListExamMarksActivity.java` | `lib/screens/staff/exam_mark_list_screen.dart` | ✅ Done |
| Change Password | `ChangePasswordActivity.java` | `lib/screens/common/change_password_screen.dart` | ✅ Done |
| Gallery | `GalleryActivity.java` | `lib/screens/common/gallery_screen.dart` | ✅ Done |

## 5. Principal Module
| Screen/Feature | Original File | Flutter File | Status |
| :--- | :--- | :--- | :--- |
| Principal Home | `PrincipalHomeFragment.java` | `lib/screens/home/principal_home_content.dart` | ✅ Done |
| Principal Dashboard | `PrincipalDashboardFragment.java` | `lib/screens/dashboard/principal_dashboard_content.dart` | ✅ Done |
| Absentees Report | `AbsenteesReportActivity.java` |  | 📅 To Do |
| Add Announcement | `AddAdminAnnouncementActivity.java` |  | 📅 To Do |
| Add Assignment | `AddAdminAssignmentActivity.java` |  | 📅 To Do |
| Add Gallery | `AddAdminGalleryActivity.java` |  | 📅 To Do |
| Add Homework | `AddAdminHomeworkActivity.java` |  | 📅 To Do |
| Add Project | `AddAdminProjectActivity.java` |  | 📅 To Do |
| ... and 48 others | ... | ... | 📅 To Do |

## Next Steps
1.  **Code Polish & Bug Fixes**: Address `flutter analyze` issues and ensure consistent UI across modules.
2.  **Principal Module**: Start migrating Principal-specific reports and entry screens.
3.  **Student Module Enhancements**: Finalize any remaining edge cases.

