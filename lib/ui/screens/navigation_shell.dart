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

class _NavigationShellState extends State<NavigationShell>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  String?
      selectedMaintenanceType; // Track subsection selection (AOG, Scheduled, Unscheduled)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _drawerAnimationController;

  @override
  void initState() {
    super.initState();
    // Smooth drawer animation controller
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

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
      icon: Icons.history_outlined,
      label: 'History',
      sublabel: 'Maintenance Logs',
    ),
    SidebarItem(
      icon: Icons.camera_alt_outlined,
      label: 'Camera Inspection',
      sublabel: 'Visual Analysis',
    ),
    SidebarItem(
      icon: Icons.chat_bubble_outlined,
      label: 'AI Assistant',
      sublabel: 'Chat Support',
    ),
  ];

  late final List<Widget> screens = [
    const HomeScreen(),
    const MaintenanceStartScreen(),
    const SmartManualScreen(),
    const MaintenanceHistoryScreen(),
    const CameraInspectionScreen(),
    const ChatScreen(), // AI Assistant
  ];

  void _selectMaintenanceType(String type) {
    setState(() {
      selectedMaintenanceType = type;
      selectedIndex = 1; // Start Maintenance is at index 1
    });
    _drawerAnimationController.reverse();
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0A0F14),
      drawer: !isDesktop
          ? AeroMainSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  selectedIndex = index;
                  selectedMaintenanceType = null;
                });
                _drawerAnimationController.reverse();
                Navigator.pop(context); // Close drawer after selection
              },
              onMaintenanceTypeSelected: _selectMaintenanceType,
              items: sidebarItems,
              isDrawer: true,
            )
          : null,
      body: Row(
        children: [
          // Desktop sidebar (always visible on desktop, hidden on mobile)
          if (isDesktop)
            AeroMainSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  selectedIndex = index;
                  selectedMaintenanceType = null;
                });
              },
              onMaintenanceTypeSelected: _selectMaintenanceType,
              items: sidebarItems,
              isDrawer: false,
            ),
          // Main Content Area
          Expanded(
            child: Container(
              color: const Color(0xFF0A0F14),
              child: Column(
                children: [
                  // Top App Bar with Hamburger Menu (mobile)
                  if (!isDesktop)
                    Container(
                      height: 56.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F26),
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFF2A2F36),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Open Menu',
                            padding: EdgeInsets.zero,
                            constraints:
                                BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.menu_close,
                              progress: _drawerAnimationController,
                              size: 24.sp,
                              color: const Color(0xFF00D4FF),
                            ),
                            onPressed: () {
                              if (_scaffoldKey.currentState!.isDrawerOpen) {
                                _drawerAnimationController.reverse();
                                Navigator.pop(context);
                              } else {
                                _drawerAnimationController.forward();
                                _scaffoldKey.currentState?.openDrawer();
                              }
                            },
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AeroMain',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF00D4FF),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                Text(
                                  'Aircraft Maintenance',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF9CA3AF),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: screens[selectedIndex],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
