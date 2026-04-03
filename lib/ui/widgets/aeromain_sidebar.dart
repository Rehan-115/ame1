import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AeroMainSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<SidebarItem> items;

  const AeroMainSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  State<AeroMainSidebar> createState() => _AeroMainSidebarState();
}

class _AeroMainSidebarState extends State<AeroMainSidebar> {
  late int hoveredIndex;

  @override
  void initState() {
    super.initState();
    hoveredIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      height: double.infinity,
      color: const Color(0xFF1A1C1E),
      child: Column(
        children: [
          // Logo Area
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
            child: Row(
              children: [
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
                Text(
                  'AeroMain',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE2E2E2),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFF2A2C2F),
            height: 1,
            thickness: 1,
          ),
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = widget.selectedIndex == index;
                final isHovered = hoveredIndex == index;

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() => hoveredIndex = index);
                    },
                    onExit: (_) {
                      setState(() => hoveredIndex = -1);
                    },
                    child: GestureDetector(
                      onTap: () => widget.onItemSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00D4FF).withOpacity(0.15)
                              : isHovered
                                  ? const Color(0xFF2A2C2F)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00D4FF).withOpacity(0.5)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Icon(
                              item.icon,
                              size: 20.sp,
                              color: isSelected
                                  ? const Color(0xFF00D4FF)
                                  : const Color(0xFFA0A0A0),
                            ),
                            SizedBox(width: 14.w),
                            // Label
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFFE2E2E2)
                                          : const Color(0xFFC0C0C0),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  if (item.sublabel != null) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      item.sublabel!,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w400,
                                        color: isSelected
                                            ? const Color(0xFF00D4FF).withOpacity(0.7)
                                            : const Color(0xFF7A7A7A),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Active Indicator
                            if (isSelected)
                              Container(
                                width: 4.w,
                                height: 24.h,
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
                );
              },
            ),
          ),
          // Footer
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Column(
              children: [
                const Divider(
                  color: Color(0xFF2A2C2F),
                  height: 1,
                  thickness: 1,
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2C2F),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00FF00),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Status',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFA0A0A0),
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              'Operational',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF00FF00),
                                fontFamily: 'Inter',
                              ),
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
        ],
      ),
    );
  }
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
