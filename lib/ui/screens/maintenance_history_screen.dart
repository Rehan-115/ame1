import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/maintenance_models.dart';
import '../../services/database_service.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  const MaintenanceHistoryScreen({super.key});

  @override
  State<MaintenanceHistoryScreen> createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  late DatabaseService _db;
  late Future<List<MaintenanceLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _db = Provider.of<DatabaseService>(context, listen: false);
    _logsFuture = _db.getLogs();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Maintenance History'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() => _logsFuture = _db.getLogs()),
            ),
          ],
        ),
        body: FutureBuilder<List<MaintenanceLog>>(
          future: _logsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 40.sp, color: AppTheme.errorColor),
                    SizedBox(height: 12.h),
                    Text(
                      'Error loading records',
                      style:
                          TextStyle(fontSize: 12.sp, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              );
            }

            final logs = snapshot.data ?? [];

            if (logs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 40.sp,
                      color: const Color(0xFFE0E0E0),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No maintenance records yet',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Complete a maintenance procedure to see records',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              itemCount: logs.length,
              itemBuilder: (context, index) => _buildLogCard(logs[index]),
            );
          },
        ),
      );

  Widget _buildLogCard(MaintenanceLog log) {
    final duration = log.endTime?.difference(log.startTime);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status indicator
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: log.status == 'completed'
                  ? AppTheme.successColor.withOpacity(0.08)
                  : AppTheme.warningColor.withOpacity(0.08),
              border: Border(
                left: BorderSide(
                  color: log.status == 'completed'
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                  width: 3.w,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.procedureId,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'By ${log.technician}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: log.status == 'completed'
                        ? AppTheme.successColor
                        : AppTheme.warningColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    log.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details section
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Date', dateFormat.format(log.startTime)),
                _buildDetailRow(
                  'Time',
                  '${timeFormat.format(log.startTime)} - ${timeFormat.format(log.endTime ?? DateTime.now())}',
                ),
                if (duration != null)
                  _buildDetailRow('Duration', '${duration.inMinutes} minutes'),
                _buildDetailRow(
                  'Steps',
                  '${log.stepLogs.where((s) => s.completed).length}/${log.stepLogs.length}',
                ),
                _buildDetailRow('Photos', '${log.imagePaths.length} captured'),
                if (log.notes != null && log.notes!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBg,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          log.notes!,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: Color(0xFFE8E8E8), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                    Icons.description, 'Report', () => _showReport(log)),
                _buildActionButton(
                    Icons.image, 'Images', () => _showImages(log)),
                _buildActionButton(
                    Icons.download, 'Export', () => _exportLog(log)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
          IconData icon, String label, VoidCallback onPressed) =>
      TextButton.icon(
        icon: Icon(icon, size: 14.sp),
        label: Text(label),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        ),
      );

  Widget _buildDetailRow(String label, String value) => Padding(
        padding: EdgeInsets.only(bottom: 5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: const Color(0xFF666666)),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF222222),
              ),
            ),
          ],
        ),
      );

  void _showReport(MaintenanceLog log) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📄 Full report generation in progress...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showImages(MaintenanceLog log) {
    if (log.imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images captured for this procedure')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Captured Images'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            log.imagePaths.length,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                height: 150.h,
                color: Colors.grey.shade200,
                child: Center(child: Text('Image ${index + 1}')),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _exportLog(MaintenanceLog log) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📤 Exporting to file...'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }
}
