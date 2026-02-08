import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/trip_data.dart';
import 'package:holy_cross_app/models/van_info.dart';

class VanInfoScreen extends StatefulWidget {
  const VanInfoScreen({super.key});

  @override
  State<VanInfoScreen> createState() => _VanInfoScreenState();
}

class _VanInfoScreenState extends State<VanInfoScreen> {
  final ApiClient _apiClient = ApiClient();
  List<TripData> _trips = [];
  List<VanInfo> _vans = [];
  List<VanInfo> _places = [];
  List<VanInfo> _students = [];
  List<VanInfo> _filteredStudents = [];

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
          _students = [];
          _filteredStudents = [];
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
          _students = [];
          _filteredStudents = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching places: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStudents(String placeId) async {
    setState(() => _isLoading = true);
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentListByBoardingPlace(token, placeId);
      if (response.data['status'] == true) {
        final List list = response.data['result'] ?? [];
        setState(() {
          _students = list.map((e) => VanInfo.fromJson(e)).toList();
          _filteredStudents = _students;
        });
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredStudents = _students.where((student) {
        final name = student.firstName?.toLowerCase() ?? '';
        final id = student.studentId?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) || id.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Van Info"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSelectors(),
          if (_students.isNotEmpty) _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildStudentList(),
          ),
        ],
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
              _fetchStudents(item.boardingPlaceId!);
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
          hintText: "Search by Student Name or ID",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (_students.isEmpty && !_isLoading) {
      return const Center(child: Text("No students found for this selection"));
    }
    return ListView.builder(
      itemCount: _filteredStudents.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            title: Text(student.firstName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("ID: ${student.studentId ?? 'N/A'}\nDistance: ${student.distance ?? '0'} km"),
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
