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
  int _maintenanceTypeIndex = 1; // 0=AOG, 1=Scheduled, 2=Unscheduled

  // Maintenance type specific procedures
  final Map<int, List<String>> _proceduresByType = {
    0: [
      'Emergency Landing Checks',
      'Critical System Inspection',
      'Hydraulic Pressure Test',
      'Brake System Emergency Check',
      'Fuel System Verification'
    ],
    1: [
      'Engine Oil Change',
      'Brake System Inspection',
      'Landing Gear Maintenance',
      'Hydraulic System Check',
      'Fuel System Inspection'
    ],
    2: [
      'Damage Assessment',
      'Structural Inspection',
      'Component Damage Report',
      'Functional Testing',
      'Emergency Repair Procedures'
    ],
  };

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

                // Dynamic Maintenance Type Alert Banner
                _buildMaintenanceTypeBanner(),
                SizedBox(height: 14.h),

                // Maintenance Type Toggle - AOG / Scheduled / Unscheduled
                Text(
                  'Maintenance Type',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildToggleButton(
                          label: 'AOG Urgent',
                          isSelected: _maintenanceTypeIndex == 0,
                          icon: Icons.emergency_outlined,
                          backgroundColor: _maintenanceTypeIndex == 0
                              ? const Color(0xFFFF4444).withOpacity(0.1)
                              : Colors.transparent,
                          borderColor: _maintenanceTypeIndex == 0
                              ? const Color(0xFFFF4444)
                              : const Color(0xFFE0E0E0),
                          textColor: _maintenanceTypeIndex == 0
                              ? const Color(0xFFFF4444)
                              : AppTheme.textDark,
                          onPressed: () {
                            setState(() => _maintenanceTypeIndex = 0);
                            _selectedProcedure = '';
                          },
                        ),
                      ),
                      Container(
                        width: 1,
                        color: const Color(0xFFE0E0E0),
                      ),
                      Expanded(
                        child: _buildToggleButton(
                          label: 'Scheduled',
                          isSelected: _maintenanceTypeIndex == 1,
                          icon: Icons.calendar_today_outlined,
                          backgroundColor: _maintenanceTypeIndex == 1
                              ? const Color(0xFF00D4FF).withOpacity(0.1)
                              : Colors.transparent,
                          borderColor: _maintenanceTypeIndex == 1
                              ? const Color(0xFF00D4FF)
                              : const Color(0xFFE0E0E0),
                          textColor: _maintenanceTypeIndex == 1
                              ? const Color(0xFF00D4FF)
                              : AppTheme.textDark,
                          onPressed: () {
                            setState(() => _maintenanceTypeIndex = 1);
                            _selectedProcedure = '';
                          },
                        ),
                      ),
                      Container(
                        width: 1,
                        color: const Color(0xFFE0E0E0),
                      ),
                      Expanded(
                        child: _buildToggleButton(
                          label: 'Unscheduled',
                          isSelected: _maintenanceTypeIndex == 2,
                          icon: Icons.cloud_upload_outlined,
                          backgroundColor: _maintenanceTypeIndex == 2
                              ? const Color(0xFFFFAA00).withOpacity(0.1)
                              : Colors.transparent,
                          borderColor: _maintenanceTypeIndex == 2
                              ? const Color(0xFFFFAA00)
                              : const Color(0xFFE0E0E0),
                          textColor: _maintenanceTypeIndex == 2
                              ? const Color(0xFFFFAA00)
                              : AppTheme.textDark,
                          onPressed: () {
                            setState(() => _maintenanceTypeIndex = 2);
                            _selectedProcedure = '';
                          },
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
                  'Select Procedure (${_getMaintenanceTypeLabel()})',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: _getMaintenanceTypeColor(),
                  ),
                ),
                SizedBox(height: 5.h),
                DropdownButtonFormField<String>(
                  initialValue:
                      _selectedProcedure.isEmpty ? null : _selectedProcedure,
                  hint: const Text('Choose procedure...'),
                  items: _proceduresByType[_maintenanceTypeIndex]!
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
                        _buildDetailRow(
                            'Maintenance Type', _getMaintenanceTypeLabel()),
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

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.transparent,
    Color borderColor = const Color(0xFFE0E0E0),
    Color textColor = const Color(0xFF666666),
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(bottom: BorderSide(color: borderColor, width: 2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: textColor,
                  size: 18.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  String _getMaintenanceTypeLabel() {
    switch (_maintenanceTypeIndex) {
      case 0:
        return 'AOG Urgent';
      case 1:
        return 'Scheduled';
      case 2:
        return 'Unscheduled';
      default:
        return 'Unknown';
    }
  }

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

  Color _getMaintenanceTypeColor() {
    switch (_maintenanceTypeIndex) {
      case 0:
        return const Color(0xFFFF4444);
      case 1:
        return const Color(0xFF00D4FF);
      case 2:
        return const Color(0xFFFFAA00);
      default:
        return AppTheme.textDark;
    }
  }

  String _getMaintenanceTypeDescription() {
    switch (_maintenanceTypeIndex) {
      case 0:
        return 'Critical System Interrupt - Aircraft on Ground';
      case 1:
        return 'Routine Mechanical Workflow - Preventive Maintenance';
      case 2:
        return 'Emergency/Damage Alerts - Immediate Assessment Required';
      default:
        return 'Select maintenance type';
    }
  }

  Widget _buildMaintenanceTypeBanner() {
    final colors = [
      const Color(0xFFFF4444),
      const Color(0xFF00D4FF),
      const Color(0xFFFFAA00),
    ];
    final icons = [
      Icons.warning_amber_rounded,
      Icons.check_circle_outline_rounded,
      Icons.emergency_rounded,
    ];

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors[_maintenanceTypeIndex].withOpacity(0.08),
        border: Border.all(
          color: colors[_maintenanceTypeIndex].withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          Icon(
            icons[_maintenanceTypeIndex],
            color: colors[_maintenanceTypeIndex],
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMaintenanceTypeLabel(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: colors[_maintenanceTypeIndex],
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  _getMaintenanceTypeDescription(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: colors[_maintenanceTypeIndex].withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
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
