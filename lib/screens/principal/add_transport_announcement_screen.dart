import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/trip_data.dart';
import 'package:holy_cross_app/models/van_info.dart';
import 'package:intl/intl.dart';

class AddTransportAnnouncementScreen extends StatefulWidget {
  const AddTransportAnnouncementScreen({super.key});

  @override
  State<AddTransportAnnouncementScreen> createState() => _AddTransportAnnouncementScreenState();
}

class _AddTransportAnnouncementScreenState extends State<AddTransportAnnouncementScreen> {
  final ApiClient _apiClient = ApiClient();
  final _announcementController = TextEditingController();
  
  List<TripData> _trips = [];
  List<VanInfo> _vans = [];
  List<VanInfo> _places = [];

  String? _selectedTripId;
  String? _selectedTripName;
  String? _selectedVanId;
  String? _selectedVanName;
  String? _selectedPlaceId;
  String? _selectedPlaceName;

  DateTime? _fromDate;
  DateTime? _toDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getTrips(token);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _trips = list.map((e) => TripData.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching trips: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchVans(String tripId) async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getVanInfo(token, tripId);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _vans = list.map((e) => VanInfo.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching vans: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPlaces(String vanId) async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getBoardingPlaces(token, vanId);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _places = list.map((e) => VanInfo.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching places: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedTripId == null || _selectedVanId == null || _selectedPlaceId == null || 
        _fromDate == null || _toDate == null || _announcementController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.addTransportAnnouncement(token, {
        'TRAN_STU_ANNOUNCEMENT_ID': '0',
        'BOARDING_PLACE_ID': _selectedPlaceId,
        'TRIP_ID': _selectedTripId,
        'VEHICLE_ID': _selectedVanId,
        'ANNOUNCEMENT': _announcementController.text,
        'DATE_FROM': DateFormat('yyyy-MM-dd').format(_fromDate!),
        'DATE_TO': DateFormat('yyyy-MM-dd').format(_toDate!),
        'IS_TWO_WAY': '1',
      });

      if (response.data['status'] == true) {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Announcement saved")));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'] ?? "Failed to save")));
        }
      }
    } catch (e) {
      debugPrint('Error adding announcement: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Announcement"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSelectorRow(
                  label: _selectedTripName ?? "Select Trip",
                  onTap: () => _showSelectionDialog("Select Trip", _trips, (item) {
                    setState(() {
                      _selectedTripId = item.tripId;
                      _selectedTripName = item.tripName;
                      _selectedVanId = null;
                      _selectedVanName = null;
                      _selectedPlaceId = null;
                      _selectedPlaceName = null;
                    });
                    _fetchVans(item.tripId);
                  }),
                ),
                const SizedBox(height: 16),
                _buildSelectorRow(
                  label: _selectedVanName ?? "Select Van",
                  onTap: _vans.isEmpty ? null : () => _showSelectionDialog("Select Van", _vans, (item) {
                    setState(() {
                      _selectedVanId = item.vehicleId;
                      _selectedVanName = item.vehicleName;
                      _selectedPlaceId = null;
                      _selectedPlaceName = null;
                    });
                    _fetchPlaces(item.vehicleId!);
                  }),
                ),
                const SizedBox(height: 16),
                _buildSelectorRow(
                  label: _selectedPlaceName ?? "Select Boarding Place",
                  onTap: _places.isEmpty ? null : () => _showSelectionDialog("Select Place", _places, (item) {
                    setState(() {
                      _selectedPlaceId = item.boardingPlaceId;
                      _selectedPlaceName = item.placeName;
                    });
                  }),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateSelector(
                        label: "From Date",
                        date: _fromDate,
                        onTap: () => _selectDate(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateSelector(
                        label: "To Date",
                        date: _toDate,
                        onTap: () => _selectDate(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _announcementController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Announcement Message",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("SEND", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSelectorRow({required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: onTap == null ? Colors.grey.shade200 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: onTap == null ? Colors.grey.shade50 : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: onTap == null ? Colors.grey : Colors.black)),
            Icon(Icons.arrow_drop_down, color: onTap == null ? Colors.grey : Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({required String label, DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(date != null ? DateFormat('dd-MM-yyyy').format(date) : "Select", style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) _fromDate = picked;
        else _toDate = picked;
      });
    }
  }

  void _showSelectionDialog(String title, List items, Function(dynamic) onSelect) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                String text = "";
                if (item is TripData) text = item.tripName;
                else if (item is VanInfo) {
                  if (title.contains("Van")) text = item.vehicleName ?? "";
                  else text = item.placeName ?? "";
                }
                return ListTile(
                  title: Text(text),
                  onTap: () {
                    onSelect(item);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
