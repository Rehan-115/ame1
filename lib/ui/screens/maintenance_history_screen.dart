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

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen>
    with TickerProviderStateMixin {
  late DatabaseService _db;
  late Future<List<MaintenanceLog>> _logsFuture;
  late Future<List<Map<String, dynamic>>> _historyFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _db = Provider.of<DatabaseService>(context, listen: false);
    _logsFuture = _db.getLogs();
    _historyFuture = _db.getHistory(limit: 100);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Maintenance History'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Maintenance Logs'),
              Tab(text: 'Search History'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {
                _logsFuture = _db.getLogs();
                _historyFuture = _db.getHistory();
              }),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Maintenance Logs Tab
            FutureBuilder<List<MaintenanceLog>>(
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
                        Icon(Icons.error,
                            size: 40.sp, color: AppTheme.errorColor),
                        SizedBox(height: 12.h),
                        Text(
                          'Error loading records',
                          style: TextStyle(
                              fontSize: 12.sp, color: AppTheme.textGrey),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  itemCount: logs.length,
                  itemBuilder: (context, index) => _buildLogCard(logs[index]),
                );
              },
            ),
            // Search History Tab
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final history = snapshot.data ?? [];

                if (history.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_outlined,
                          size: 40.sp,
                          color: const Color(0xFFE0E0E0),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No search history yet',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Technical queries will appear here',
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  itemCount: history.length,
                  itemBuilder: (context, index) =>
                      _buildHistoryCard(history[index]),
                );
              },
            ),
          ],
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

  Widget _buildHistoryCard(Map<String, dynamic> history) {
    final timestamp = DateTime.tryParse(history['timestamp'] as String? ?? '');
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final query = history['query'] as String? ?? '';
    final type = history['type'] as String? ?? 'search';

    IconData typeIcon = Icons.search_outlined;
    Color typeColor = const Color(0xFF00D4FF);

    switch (type) {
      case 'technical':
        typeIcon = Icons.build_outlined;
        typeColor = const Color(0xFFFF6B35);
        break;
      case 'error':
        typeIcon = Icons.error_outline;
        typeColor = const Color(0xFFFF4444);
        break;
      case 'procedure':
        typeIcon = Icons.assignment_outlined;
        typeColor = const Color(0xFF00FF00);
        break;
      default:
        typeIcon = Icons.search_outlined;
        typeColor = const Color(0xFF00D4FF);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2125),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFF2A2F36), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Icon(
                    typeIcon,
                    size: 16.sp,
                    color: typeColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: typeColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        timestamp != null
                            ? dateFormat.format(timestamp)
                            : 'Unknown time',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: const Color(0xFF7A7A7A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F14),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                query,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFFE2E2E2),
                  fontFamily: 'Inter',
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: const Color(0xFF777777),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      );

  Widget _buildActionButton(
          IconData icon, String label, VoidCallback onPressed) =>
      TextButton.icon(
        icon: Icon(icon, size: 14.sp),
        label: Text(label),
        onPressed: onPressed,
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
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: log.imagePaths.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text('📷 Image ${index + 1}: ${log.imagePaths[index]}'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
}
