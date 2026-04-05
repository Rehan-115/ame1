import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../services/database_service.dart';

class MaintenanceStartScreen extends StatefulWidget {
  const MaintenanceStartScreen({super.key});

  @override
  State<MaintenanceStartScreen> createState() => _MaintenanceStartScreenState();
}

class _MaintenanceStartScreenState extends State<MaintenanceStartScreen> {
  late TextEditingController _technicianController;
  late DatabaseService _db;
  String _selectedProcedure = '';

  // Standard procedures
  final List<String> _procedures = [
    'Engine Oil Change',
    'Brake System Inspection',
    'Landing Gear Maintenance',
    'Hydraulic System Check',
    'Fuel System Inspection',
    'Emergency Landing Checks',
    'Critical System Inspection',
    'Hydraulic Pressure Test',
    'Brake System Emergency Check',
    'Fuel System Verification'
  ];

  @override
  void initState() {
    super.initState();
    _technicianController = TextEditingController();
    _db = Provider.of<DatabaseService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Start Maintenance'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(13.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card - Professional
                Container(
                  padding: EdgeInsets.all(11.w),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.08),
                    border: Border.all(
                      color: AppTheme.successColor.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'All systems ready for maintenance',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // Choose Your Action heading
                Text(
                  'Choose Your Action',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 8.h),

                // Technician Input
                Text(
                  'Technician Name',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1976D2),
                  ),
                ),
                SizedBox(height: 5.h),
                TextField(
                  controller: _technicianController,
                  decoration: InputDecoration(
                    hintText: 'Enter technician name',
                    prefixIcon: Icon(Icons.person, size: 16.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide: const BorderSide(
                          color: Color(0xFF1976D2), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide:
                          const BorderSide(color: Color(0xFF1976D2), width: 2),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 10.sp),
                ),
                SizedBox(height: 12.h),

                // Procedure Selection
                Text(
                  'Select Procedure',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 5.h),
                DropdownButtonFormField<String>(
                  initialValue:
                      _selectedProcedure.isEmpty ? null : _selectedProcedure,
                  hint: const Text('Choose procedure...'),
                  items: _procedures
                      .map((proc) =>
                          DropdownMenuItem(value: proc, child: Text(proc)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedProcedure = value ?? '');
                    if (value != null && value.isNotEmpty) {
                      _saveToHistory(value);
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.build, size: 16.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide: const BorderSide(
                          color: Color(0xFF388E3C), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.r),
                      borderSide:
                          const BorderSide(color: Color(0xFF388E3C), width: 2),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                    isDense: true,
                  ),
                ),
                SizedBox(height: 14.h),

                // Procedure Details
                if (_selectedProcedure.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(11.w),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: AppTheme.accentColor.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Procedure Details',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        _buildDetailRow('Procedure', _selectedProcedure),
                        _buildDetailRow(
                            'Aircraft Type', 'Configure in settings'),
                        _buildDetailRow('Estimated Steps', '5 steps'),
                        _buildDetailRow('Estimated Time', '30-45 minutes'),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                ],

                // Start Button
                SizedBox(
                  width: double.infinity,
                  height: 38.h,
                  child: ElevatedButton.icon(
                    onPressed: _selectedProcedure.isEmpty ||
                            _technicianController.text.isEmpty
                        ? null
                        : () => _startMaintenance(context),
                    icon: const Icon(Icons.play_arrow, size: 14),
                    label: Text(
                      'Start Maintenance',
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      );

  Widget _buildDetailRow(String label, String value) => Padding(
        padding: EdgeInsets.only(bottom: 5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5.sp,
                color: const Color(0xFF666666),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      );

  void _startMaintenance(BuildContext context) {
    // TODO: Implement navigation to maintenance procedure screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚀 Starting: $_selectedProcedure\nTechnician: ${_technicianController.text}',
        ),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  void dispose() {
    _technicianController.dispose();
    super.dispose();
  }

  Future<void> _saveToHistory(String procedure) async {
    try {
      final technicianName = _technicianController.text.trim();
      if (technicianName.isNotEmpty) {
        // Save technician name + procedure as procedure history entry
        await _db.saveHistoryEntry(
          '$technicianName - $procedure',
          'procedure',
        );
      }
    } catch (e) {
      print('Error saving to history: $e');
    }
  }
}
