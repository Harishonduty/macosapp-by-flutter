import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/staff_circular.dart';

class StaffCircularScreen extends StatefulWidget {
  const StaffCircularScreen({super.key});

  @override
  State<StaffCircularScreen> createState() => _StaffCircularScreenState();
}

class _StaffCircularScreenState extends State<StaffCircularScreen> {
  final ApiClient _apiClient = ApiClient();
  List<StaffCircular> _circulars = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchCirculars();
  }

  Future<void> _fetchCirculars() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStaffCirculars(token);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _circulars = list.map((e) => StaffCircular.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
       // setState(() => _error = 'Failed to load circulars');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circulars'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _circulars.isEmpty
              ? Center(child: Text(_error.isNotEmpty ? _error : 'No Circulars Found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _circulars.length,
                  itemBuilder: (context, index) {
                    final item = _circulars[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.circularMessage, 
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'By: ${item.staffName}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                Text(
                                  item.entryDate,
                                  style: TextStyle(fontSize: 12, color: Colors.indigo.shade400),
                                ),
                              ],
                            ),
                            if(item.className.isNotEmpty) ...[
                               const SizedBox(height: 4),
                               Text(
                                  'Class: ${item.className}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
