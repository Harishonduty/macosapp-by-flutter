import 'package:flutter/material.dart';
import 'package:holy_cross_app/theme/app_colors.dart';
import 'package:holy_cross_app/utils/preference_service.dart';
import 'package:holy_cross_app/networks/api_client.dart';
import 'package:holy_cross_app/models/fee_receipt.dart';

class StudentFeeReceiptScreen extends StatefulWidget {
  const StudentFeeReceiptScreen({super.key});

  @override
  State<StudentFeeReceiptScreen> createState() => _StudentFeeReceiptScreenState();
}

class _StudentFeeReceiptScreenState extends State<StudentFeeReceiptScreen> {
  final ApiClient _apiClient = ApiClient();
  List<FeeReceipt> _feeReceipts = [];
  bool _isLoading = true;
  String _error = '';
  String _studentId = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _fetchStudentId();
    if (_studentId.isNotEmpty) {
      await _fetchFeeReceipt();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Student ID not found';
      });
    }
  }

  Future<void> _fetchStudentId() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getStudentDetails(token);
      if (response.statusCode == 200 && response.data != null) {
         final data = response.data;
         if (data['status'] == true && data['result'] != null) {
           final List list = data['result'];
           if (list.isNotEmpty) {
             _studentId = list[0]['STUDENT_ID']?.toString() ?? '';
           }
         }
      }
    } catch (e) {
      debugPrint('Error fetching student ID: $e');
    }
  }

  Future<void> _fetchFeeReceipt() async {
    try {
      final token = PreferenceService.getString('token');
      final response = await _apiClient.getFeeReceipt(token, _studentId);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == true && data['result'] != null) {
           final resultData = data['result'];
           if (resultData != null && resultData['FEES_INFO'] != null) {
              final List list = resultData['FEES_INFO'];
              setState(() {
                _feeReceipts = list.map((e) => FeeReceipt.fromJson(e)).toList();
              });
           }
        } else if (data['message'] != null) {
           setState(() => _error = data['message']);
        }
      }
    } catch (e) {
      setState(() => _error = 'Failed to load fee receipts');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Receipt'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _feeReceipts.isEmpty
                  ? const Center(child: Text('No Fee Receipts Found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _feeReceipts.length,
                      itemBuilder: (context, index) {
                        final item = _feeReceipts[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.frequencyName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      item.paymentDate,
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Amount: ${item.amount}'),
                                    Text('Paid: ${item.paid}', style: const TextStyle(color: Colors.green)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Balance: ${item.balance}', style: const TextStyle(color: Colors.red)),
                                    Chip(
                                      label: Text(
                                        item.status,
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                      backgroundColor: AppColors.primary,
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
