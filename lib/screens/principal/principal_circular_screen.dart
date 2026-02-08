import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_circular.dart';
import 'package:holy_cross_app/screens/principal/add_circular_screen.dart';

class PrincipalCircularScreen extends StatefulWidget {
  const PrincipalCircularScreen({super.key});

  @override
  State<PrincipalCircularScreen> createState() => _PrincipalCircularScreenState();
}

class _PrincipalCircularScreenState extends State<PrincipalCircularScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffCircular> _circulars = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCirculars();
  }

  Future<void> _fetchCirculars() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStaffCirculars(token);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _circulars = list.map((e) => StaffCircular.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching circulars: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Circulars"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _circulars.isEmpty
              ? const Center(child: Text("No Circulars Found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _circulars.length,
                  itemBuilder: (context, index) {
                    return _buildCircularCard(_circulars[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCircularScreen()));
          if (result == true) {
            _fetchCirculars();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCircularCard(StaffCircular circular) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    circular.className,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  circular.entryDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              circular.circularMessage,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Text(
              "By: ${circular.staffName}",
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
