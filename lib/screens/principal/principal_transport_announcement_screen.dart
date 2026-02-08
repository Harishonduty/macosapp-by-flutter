import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/trip_data.dart';
import 'package:holy_cross_app/models/van_info.dart';
import 'package:holy_cross_app/models/transport_announcement.dart';
import 'package:holy_cross_app/screens/principal/add_transport_announcement_screen.dart';

class PrincipalTransportAnnouncementScreen extends StatefulWidget {
  const PrincipalTransportAnnouncementScreen({super.key});

  @override
  State<PrincipalTransportAnnouncementScreen> createState() => _PrincipalTransportAnnouncementScreenState();
}

class _PrincipalTransportAnnouncementScreenState extends State<PrincipalTransportAnnouncementScreen> {
  final ApiClient _apiClient = ApiClient();
  List<TripData> _trips = [];
  List<VanInfo> _vans = [];
  List<VanInfo> _places = [];
  List<TransportAnnouncement> _announcements = [];
  List<TransportAnnouncement> _filteredAnnouncements = [];

  String? _selectedTripId;
  String? _selectedTripName;
  String? _selectedVanId;
  String? _selectedVanName;
  String? _selectedPlaceId;
  String? _selectedPlaceName;

  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

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
          _selectedVanId = null;
          _selectedVanName = null;
          _selectedPlaceId = null;
          _selectedPlaceName = null;
          _announcements = [];
          _filteredAnnouncements = [];
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
          _selectedPlaceId = null;
          _selectedPlaceName = null;
          _announcements = [];
          _filteredAnnouncements = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching places: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAnnouncements() async {
    if (_selectedTripId == null || _selectedVanId == null || _selectedPlaceId == null) return;
    
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getAdminTransportAnnouncement(token, {
        'BOARDING_PLACE_ID': _selectedPlaceId,
        'TRIP_ID': _selectedTripId,
        'VEHICLE_ID': _selectedVanId,
      });
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _announcements = list.map((e) => TransportAnnouncement.fromJson(e)).toList();
          _filteredAnnouncements = _announcements;
        });
      }
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredAnnouncements = _announcements.where((item) {
        final description = item.announcement?.toLowerCase() ?? '';
        final name = item.name?.toLowerCase() ?? '';
        final vehicle = item.vehicleName?.toLowerCase() ?? '';
        return description.contains(query.toLowerCase()) || 
               name.contains(query.toLowerCase()) ||
               vehicle.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transport Announcements"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSelectors(),
          if (_announcements.isNotEmpty) _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildAnnouncementList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransportAnnouncementScreen()),
          );
          if (result == true) {
            _fetchAnnouncements();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSelectors() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          _buildSelectorRow(
            label: _selectedTripName ?? "Select Trip",
            onTap: () => _showSelectionDialog("Select Trip", _trips, (item) {
              setState(() {
                _selectedTripId = item.tripId;
                _selectedTripName = item.tripName;
              });
              _fetchVans(item.tripId);
            }),
          ),
          const SizedBox(height: 12),
          _buildSelectorRow(
            label: _selectedVanName ?? "Select Van",
            onTap: _vans.isEmpty ? null : () => _showSelectionDialog("Select Van", _vans, (item) {
              setState(() {
                _selectedVanId = item.vehicleId;
                _selectedVanName = item.vehicleName;
              });
              _fetchPlaces(item.vehicleId!);
            }),
          ),
          const SizedBox(height: 12),
          _buildSelectorRow(
            label: _selectedPlaceName ?? "Select Boarding Place",
            onTap: _places.isEmpty ? null : () => _showSelectionDialog("Select Place", _places, (item) {
              setState(() {
                _selectedPlaceId = item.boardingPlaceId;
                _selectedPlaceName = item.placeName;
              });
              _fetchAnnouncements();
            }),
          ),
        ],
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSearch,
        decoration: InputDecoration(
          hintText: "Search announcements...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildAnnouncementList() {
    if (_announcements.isEmpty && !_isLoading) {
      return const Center(child: Text("No announcements found for this selection"));
    }
    return ListView.builder(
      itemCount: _filteredAnnouncements.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = _filteredAnnouncements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name ?? 'Staff', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text(item.dateFrom ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.announcement ?? '', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.directions_bus, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(item.vehicleName ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 16),
                    const Icon(Icons.place, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(item.placeName ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
