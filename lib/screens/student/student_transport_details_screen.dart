import 'package:flutter/material.dart';
import 'package:holy_cross_app/models/transport_details.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';

class StudentTransportDetailsScreen extends StatefulWidget {
  const StudentTransportDetailsScreen({super.key});

  @override
  State<StudentTransportDetailsScreen> createState() => _StudentTransportDetailsScreenState();
}

class _StudentTransportDetailsScreenState extends State<StudentTransportDetailsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<TransportDetails> _details = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getTransportDetails(token);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
          final List list = data['result'];
          setState(() {
            _details = list.map((e) => TransportDetails.fromJson(e)).toList();
          });
        } else {
            setState(() => _error = data['message'] ?? 'No transport details found');
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load transport details');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details.isEmpty
              ? Center(child: Text(_error.isNotEmpty ? _error : 'No Details Found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _details.length,
                  itemBuilder: (context, index) {
                    final item = _details[index];
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
                              item.vehicleName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            ),
                            const SizedBox(height: 8),
                             _buildInfoRow('Vehicle No:', item.vehicleNo),
                             _buildInfoRow('Route Name:', item.routeName),
                             _buildInfoRow('Boarding Place:', item.boardingPlace),
                             _buildInfoRow('Distance:', '${item.distance} KM'),
                             _buildInfoRow('Trip Type:', item.isOneWayTwoWay),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
