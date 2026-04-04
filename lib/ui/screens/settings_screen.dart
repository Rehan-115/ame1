import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/chat_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  String _selectedLanguage = 'English';
  bool _runningDiagnostics = false;
  String _diagnosticsStatus = '';

  late ChatService _chatService;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _runningDiagnostics = true;
      _diagnosticsStatus = 'Running tests...';
    });

    try {
      final results = await _chatService.runServiceDiagnostics();
      
      if (mounted) {
        setState(() {
          _runningDiagnostics = false;
          _diagnosticsStatus = _formatDiagnostics(results);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_diagnosticsStatus.split('\n').first),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _runningDiagnostics = false;
          _diagnosticsStatus = '❌ Diagnostics failed: $e';
        });
      }
    }
  }

  String _formatDiagnostics(Map<String, dynamic> results) {
    final tests = results['tests'] as Map<String, dynamic>? ?? {};
    final parts = <String>[];
    
    for (final entry in tests.entries) {
      final value = entry.value as Map<String, dynamic>? ?? {};
      final status = value['status'] ?? 'UNKNOWN';
      parts.add('${entry.key}: $status');
    }
    
    return parts.join('\n');
  }
        appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF222222),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // General Section
              Container(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'General',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00D4FF),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Notifications
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF222222),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Receive alerts and updates',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() => _notificationsEnabled = value);
                          },
                          activeColor: const Color(0xFF00D4FF),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Sound
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sound',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF222222),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Enable notification sounds',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _soundEnabled,
                          onChanged: (value) {
                            setState(() => _soundEnabled = value);
                          },
                          activeColor: const Color(0xFF00D4FF),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1.h, color: Colors.grey[200]),
              // Display Section
              Container(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Display',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00D4FF),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Dark Mode
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF222222),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Use dark theme',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _darkModeEnabled,
                          onChanged: (value) {
                            setState(() => _darkModeEnabled = value);
                          },
                          activeColor: const Color(0xFF00D4FF),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Language
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Language',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            underline: SizedBox.shrink(),
                            value: _selectedLanguage,
                            items:
                                const ['English', 'Spanish', 'French', 'German']
                                    .map((lang) => DropdownMenuItem(
                                          value: lang,
                                          child: Text(lang),
                                        ))
                                    .toList(),
                            onChanged: (value) {
                              setState(
                                  () => _selectedLanguage = value ?? 'English');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1.h, color: Colors.grey[200]),
              // Diagnostics Section
              Container(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnostics',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00D4FF),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: _runningDiagnostics ? null : _runDiagnostics,
                      icon: _runningDiagnostics
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.bug_report),
                      label: Text(
                        _runningDiagnostics ? 'Testing...' : 'Test Services',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4FF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                    ),
                    if (_diagnosticsStatus.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          _diagnosticsStatus,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF333333),
                            height: 1.6,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
