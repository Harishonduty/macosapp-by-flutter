import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_profile.dart';

class StaffInfoScreen extends StatefulWidget {
  const StaffInfoScreen({super.key});

  @override
  State<StaffInfoScreen> createState() => _StaffInfoScreenState();
}

class _StaffInfoScreenState extends State<StaffInfoScreen> {
  final ApiClient _apiClient = ApiClient();
  StaffProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaffProfile();
  }

  Future<void> _fetchStaffProfile() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStaffInfo(token);
      if (response.data['status'] == true) {
        setState(() {
          _profile = StaffProfile.fromJson(response.data['result']['lstofStaffInfo']);
        });
      }
    } catch (e) {
      debugPrint('Error fetching staff profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Information'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('Profile not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              _profile!.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person,
                                size: 80,
                                color: AppColors.lightGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _profile!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _profile!.designation,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildInfoTile(Icons.badge, 'Employee Code', _profile!.employeeCode),
                      _buildInfoTile(Icons.cake, 'Date of Birth', _profile!.dob),
                      _buildInfoTile(Icons.phone, 'Mobile', _profile!.mobile),
                      _buildInfoTile(Icons.email, 'Email', _profile!.email.isEmpty ? 'N/A' : _profile!.email),
                      _buildInfoTile(Icons.calendar_month, 'Date of Joining', _profile!.doj),
                      _buildInfoTile(Icons.school, 'Qualification', _profile!.qualificationName),
                      _buildInfoTile(Icons.category, 'Category', _profile!.stfCategory),
                      _buildInfoTile(Icons.work_outline, 'Department', _profile!.deptCategoryName),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'N/A' : value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
