import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userMode = 'engineer';
  bool _offlineMode = true;
  bool _autoSync = true;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 2,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // User Mode Section
              _buildSection(
                title: 'User Mode',
                children: [
                  RadioListTile<String>(
                    title: const Text('Engineer Mode'),
                    subtitle: const Text('Access to advanced features'),
                    value: 'engineer',
                    groupValue: _userMode,
                    onChanged: (value) {
                      setState(() => _userMode = value ?? 'engineer');
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Passenger Mode'),
                    subtitle: const Text('Simplified interface'),
                    value: 'passenger',
                    groupValue: _userMode,
                    onChanged: (value) {
                      setState(() => _userMode = value ?? 'passenger');
                    },
                  ),
                ],
              ),

              // Data & Sync Section
              _buildSection(
                title: 'Data & Synchronization',
                children: [
                  CheckboxListTile(
                    title: const Text('Offline Mode'),
                    subtitle: const Text('Work without internet connection'),
                    value: _offlineMode,
                    onChanged: (value) {
                      setState(() => _offlineMode = value ?? true);
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Auto Sync'),
                    subtitle: const Text('Automatically sync when online'),
                    value: _autoSync,
                    onChanged: (value) {
                      setState(() => _autoSync = value ?? true);
                    },
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Database synced successfully'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text('Sync Now'),
                      ),
                    ),
                  ),
                ],
              ),

              // Display Section
              _buildSection(
                title: 'Display & Theme',
                children: [
                  ListTile(
                    title: const Text('Theme'),
                    trailing: DropdownButton<ThemeMode>(
                      value: _themeMode,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _themeMode = value ?? ThemeMode.system);
                      },
                    ),
                  ),
                ],
              ),

              // Data Management Section
              _buildSection(
                title: 'Data Management',
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_sweep),
                    title: const Text('Clear Cache'),
                    subtitle: const Text('Remove temporary files'),
                    onTap: () => _showDeleteDialog(
                      context,
                      'Clear Cache',
                      'This will remove temporary files. Continue?',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Clear All Data'),
                    subtitle:
                        const Text('Delete all local maintenance records'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showDeleteDialog(
                      context,
                      'Clear All Data',
                      'This will permanently delete all maintenance records. Continue?',
                    ),
                  ),
                ],
              ),

              // About Section
              _buildSection(
                title: 'About',
                children: [
                  ListTile(
                    title: const Text('Version'),
                    trailing: const Text('1.0.0'),
                  ),
                  ListTile(
                    title: const Text('Build'),
                    trailing: const Text('2026.04.03'),
                  ),
                  ListTile(
                    title: const Text('App Name'),
                    trailing: const Text('AeroAssist AI'),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'Aircraft Maintenance & Support System\n\nDesigned for technicians and engineers to streamline maintenance procedures and improve efficiency.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          ...children,
          Divider(height: 1, indent: 0.w, endIndent: 0.w),
        ],
      );

  void _showDeleteDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title completed')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
