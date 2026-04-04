import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AeroMainSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Function(String)? onMaintenanceTypeSelected;
  final List<SidebarItem> items;
  final bool isDrawer;

  const AeroMainSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onMaintenanceTypeSelected,
    required this.items,
    this.isDrawer = false,
  });

  @override
  State<AeroMainSidebar> createState() => _AeroMainSidebarState();
}

class _AeroMainSidebarState extends State<AeroMainSidebar>
    with TickerProviderStateMixin {
  late int hoveredIndex;
  bool isConnected = true;
  bool expandMaintenanceMenu = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    hoveredIndex = -1;

    // Pulsing animation for AOG urgency
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDrawer) {
      return Drawer(
        backgroundColor: Colors.transparent,
        child: _buildDrawerContent(),
      );
    }

    // Desktop sidebar
    return Container(
      width: 280.w,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF121416),
        border: Border(
          right: BorderSide(
            color: const Color(0xFF2A2F36),
            width: 1,
          ),
        ),
      ),
      child: _buildSidebarContent(),
    );
  }

  Widget _buildDrawerContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF121416).withOpacity(0.95),
        border: Border(
          right: BorderSide(
            color: const Color(0xFF00D4FF).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Drawer Header with Close Button & Logo
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF2A2F36),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Logo
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D4FF), Color(0xFF0088FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'AM',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AeroMain',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE2E2E2),
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.h,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2D8659),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Synced',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF7A7A7A),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_outlined,
                    size: 20.sp,
                    color: const Color(0xFF7A7A7A),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Navigation Items
          Expanded(
            child: _buildNavigationList(),
          ),
          // Footer Profile Card
          _buildProfileFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        // Header with AeroMain branding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2125),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'AeroMain',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00D4FF),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divider
        Container(
          height: 1,
          color: const Color(0xFF2A2F36),
          margin: EdgeInsets.symmetric(horizontal: 12.w),
        ),
        // Navigation Items
        Expanded(
          child: _buildNavigationList(),
        ),
        // Footer Profile Card
        _buildProfileFooter(),
      ],
    );
  }

  Widget _buildNavigationList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      child: Column(
        children: [
          // Dashboard
          _buildNavItem(0, 'Dashboard', Icons.home_outlined),
          SizedBox(height: 8.h),

          // Start Maintenance with Subsections
          _buildStartMaintenanceSection(),
          SizedBox(height: 8.h),

          // Smart Manual
          _buildNavItem(2, 'Smart Manual', Icons.book_outlined),
          SizedBox(height: 8.h),

          // History
          _buildNavItem(3, 'History', Icons.history_outlined),
          SizedBox(height: 8.h),

          // Camera Inspection
          _buildNavItem(4, 'Camera Inspection', Icons.camera_alt_outlined),
        ],
      ),
    );
  }

  Widget _buildStartMaintenanceSection() {
    return Column(
      children: [
        // Main "Start Maintenance" collapsible item
        GestureDetector(
          onTap: () {
            setState(() => expandMaintenanceMenu = !expandMaintenanceMenu);
            widget.onItemSelected(1);
          },
          child: MouseRegion(
            onEnter: (_) => setState(() => hoveredIndex = 1),
            onExit: (_) => setState(() => hoveredIndex = -1),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                color: widget.selectedIndex == 1
                    ? const Color(0xFF00D4FF).withOpacity(0.12)
                    : hoveredIndex == 1
                        ? const Color(0xFF1E2125)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: widget.selectedIndex == 1
                      ? const Color(0xFF00D4FF).withOpacity(0.4)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 18.sp,
                    color: widget.selectedIndex == 1
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFFA0A0A0),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Start Maintenance',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: widget.selectedIndex == 1
                            ? const Color(0xFFE2E2E2)
                            : const Color(0xFFC0C0C0),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expandMaintenanceMenu ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.chevron_right_outlined,
                      size: 20.sp,
                      color: const Color(0xFF7A7A7A),
                    ),
                  ),
                  if (widget.selectedIndex == 1)
                    Container(
                      width: 3.w,
                      height: 20.h,
                      margin: EdgeInsets.only(left: 8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4FF),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Submenu with AOG, Scheduled, Unscheduled
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: expandMaintenanceMenu ? 160.h : 0.h,
          child: AnimatedOpacity(
            opacity: expandMaintenanceMenu ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(left: 16.w, top: 8.h),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vertical line
                          Container(
                            width: 2.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D4FF).withOpacity(0.3),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // AOG Urgent
                                _buildMaintenanceSubtype(
                                  'AOG Urgent',
                                  Icons.emergency_outlined,
                                  const Color(0xFF8B0000),
                                  'aog',
                                  isUrgent: true,
                                ),
                                SizedBox(height: 12.h),
                                // Scheduled
                                _buildMaintenanceSubtype(
                                  'Scheduled',
                                  Icons.calendar_today_outlined,
                                  const Color(0xFF0088FF),
                                  'scheduled',
                                ),
                                SizedBox(height: 12.h),
                                // Unscheduled
                                _buildMaintenanceSubtype(
                                  'Unscheduled',
                                  Icons.cloud_upload_outlined,
                                  const Color(0xFFF57C00),
                                  'unscheduled',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceSubtype(
    String label,
    IconData icon,
    Color color,
    String type, {
    bool isUrgent = false,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onMaintenanceTypeSelected?.call(type);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isUrgent
              ? const Color(0xFF8B0000).withOpacity(0.1)
              : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isUrgent
                ? const Color(0xFF8B0000).withOpacity(0.3)
                : color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            ScaleTransition(
              scale: isUrgent
                  ? _pulseAnimation
                  : const AlwaysStoppedAnimation(1.0),
              child: Icon(
                icon,
                size: 16.sp,
                color: color,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            if (isUrgent)
              Padding(
                padding: EdgeInsets.only(left: 6.w),
                child: Container(
                  width: 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        widget.onItemSelected(index);
        if (widget.isDrawer) {
          Navigator.pop(context);
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => hoveredIndex = index),
        onExit: (_) => setState(() => hoveredIndex = -1),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            color: widget.selectedIndex == index
                ? const Color(0xFF00D4FF).withOpacity(0.12)
                : hoveredIndex == index
                    ? const Color(0xFF1E2125)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: widget.selectedIndex == index
                  ? const Color(0xFF00D4FF).withOpacity(0.4)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: widget.selectedIndex == index
                    ? const Color(0xFF00D4FF)
                    : const Color(0xFFA0A0A0),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: widget.selectedIndex == index
                        ? const Color(0xFFE2E2E2)
                        : const Color(0xFFC0C0C0),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (widget.selectedIndex == index)
                Container(
                  width: 3.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4FF),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileFooter() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFF2A2F36),
            width: 1,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2125),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: const Color(0xFF232629),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Status indicator dot
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00FF00),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF00).withOpacity(0.6),
                    blurRadius: 8.r,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Status',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00FF00),
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Operational',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF7A7A7A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.cloud_done_outlined,
              size: 16.sp,
              color: const Color(0xFF00D4FF),
            ),
          ],
        ),
      ),
    );
  }

  int get selectedIndex => widget.selectedIndex;
}

class SidebarItem {
  final IconData icon;
  final String label;
  final String? sublabel;

  SidebarItem({
    required this.icon,
    required this.label,
    this.sublabel,
  });
}
