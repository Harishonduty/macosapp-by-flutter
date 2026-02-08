import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/screens/home/staff_home_content.dart';
import 'package:holy_cross_app/screens/home/student_home_content.dart';
import 'package:holy_cross_app/screens/home/principal_home_content.dart';
import 'package:holy_cross_app/screens/dashboard/staff_dashboard_content.dart';
import 'package:holy_cross_app/screens/dashboard/student_dashboard_content.dart';
import 'package:holy_cross_app/screens/dashboard/principal_dashboard_content.dart';
import 'package:holy_cross_app/screens/login_screen.dart';

class SFSLandingScreen extends StatefulWidget {
  const SFSLandingScreen({super.key});

  @override
  State<SFSLandingScreen> createState() => _SFSLandingScreenState();
}

class _SFSLandingScreenState extends State<SFSLandingScreen> {
  int _currentIndex = 0;
  String _role = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = PreferenceService.getString('role');
    setState(() {
      _role = role ?? '';
      _isLoading = false;
    });
  }

  Widget _getHomeContent() {
    if (_role == '1' || _role == '5') {
      return const PrincipalHomeContent();
    } else if (_role == '2' || _role == '6') {
      return const StudentHomeContent();
    } else if (_role == '3') {
      return const StaffHomeContent();
    }
    return const Center(child: Text('Unknown Role'));
  }

  Widget _getDashboardContent() {
    if (_role == '1' || _role == '5') {
      return const PrincipalDashboardContent();
    } else if (_role == '2' || _role == '6') {
      return const StudentDashboardContent();
    } else if (_role == '3') {
      return const StaffDashboardContent();
    }
    return const Center(child: Text('Unknown Role'));
  }

  void _logout() async {
    await PreferenceService.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holy Cross'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _getHomeContent(),
          _getDashboardContent(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}
