import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/screens/common/staff_birthday_screen.dart';

class StaffHomeContent extends StatefulWidget {
  const StaffHomeContent({super.key});

  @override
  State<StaffHomeContent> createState() => _StaffHomeContentState();
}

class _StaffHomeContentState extends State<StaffHomeContent> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? staffProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaffProfile();
  }

  Future<void> _fetchStaffProfile() async {
    try {
      final response = await _apiClient.getStaffInfo(
        PreferenceService.getString('token') ?? '',
      );
      if (response.data['status'] == true) {
        setState(() {
          staffProfile = response.data['result']['lstofStaffInfo'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching staff profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    '${staffProfile?['IMAGE_PATH'] ?? ''}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.lightGray,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staffProfile?['STAFF_NAME'] ?? 'Staff Name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      staffProfile?['DESIGNATION'] ?? 'Designation',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Birthday Card
          _buildActionCard(
            title: "Staff Birthday's",
            subtitle: "Current Date Staff Birthday's",
            icon: Icons.cake,
            color: Colors.orange[400]!,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffBirthdayScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
