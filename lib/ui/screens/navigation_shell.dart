import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/aeromain_sidebar.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'smart_manual_screen.dart';
import 'maintenance_start_screen.dart';
import 'maintenance_history_screen.dart';
import 'camera_inspection_screen.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int selectedIndex = 0;

  late final List<SidebarItem> sidebarItems = [
    SidebarItem(
      icon: Icons.home_outlined,
      label: 'Dashboard',
      sublabel: 'System Overview',
    ),
    SidebarItem(
      icon: Icons.build_outlined,
      label: 'Start Maintenance',
      sublabel: 'Begin Procedure',
    ),
    SidebarItem(
      icon: Icons.book_outlined,
      label: 'Smart Manual',
      sublabel: 'Documentation',
    ),
    SidebarItem(
      icon: Icons.message_outlined,
      label: 'AI Assistant',
      sublabel: 'Chat Support',
    ),
    SidebarItem(
      icon: Icons.camera_alt_outlined,
      label: 'Camera Inspection',
      sublabel: 'Visual Analysis',
    ),
    SidebarItem(
      icon: Icons.history_outlined,
      label: 'History',
      sublabel: 'Maintenance Logs',
    ),
  ];

  late final List<Widget> screens = [
    const HomeScreen(),
    const MaintenanceStartScreen(),
    const SmartManualScreen(),
    const ChatScreen(),
    const CameraInspectionScreen(),
    const MaintenanceHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F14),
      body: Row(
        children: [
          // Sidebar
          AeroMainSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() => selectedIndex = index);
            },
            items: sidebarItems,
          ),
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFF0A0F14),
              child: screens[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
