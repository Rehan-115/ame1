import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/feature_card.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildFuturisticAppBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // System Status Banner
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withOpacity(0.1),
                      border: Border.all(
                        color: const Color(0xFF00D4FF),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.25),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FF00),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FF00).withOpacity(0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'SYSTEM STATUS: RECOVERY SUCCESSFUL',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00D4FF),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Main Status Section
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 400;
                      return isMobile
                          ? Column(
                              children: [
                                _buildStatusBox(
                                  icon: Icons.info_rounded,
                                  status: 'SYSTEM STATUS: OPTIMAL',
                                  subtitle: 'Online AI active.\nAwaiting operational verification...',
                                ),
                                SizedBox(height: 12.h),
                                _buildStatusBox(
                                  icon: Icons.router,
                                  status: 'AI CORE: ACTIVE - STABLE',
                                  subtitle: 'MODE: UNLOCKED - VERIFIED',
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _buildStatusBox(
                                    icon: Icons.info_rounded,
                                    status: 'SYSTEM STATUS: OPTIMAL',
                                    subtitle: 'Online AI active.\nAwaiting operational verification...',
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildStatusBox(
                                    icon: Icons.router,
                                    status: 'AI CORE: ACTIVE - STABLE',
                                    subtitle: 'MODE: UNLOCKED - VERIFIED',
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Start Maintenance Card
                  _buildMainStatusCard(
                    icon: Icons.settings_rounded,
                    title: 'Start Maintenance',
                    subtitle: 'PROCEDURE ACTIVE. Visual data restored.',
                    onTap: () => Navigator.pushNamed(context, '/maintenance'),
                  ),
                  SizedBox(height: 12.h),

                  // AI Assistant Card
                  _buildFeatureCardWithStatus(
                    icon: Icons.chat_bubble_outline,
                    title: 'AI Assistant',
                    subtitle: 'SERVICE AVAILABLE. Database access confirmed.',
                    onTap: () => Navigator.pushNamed(context, '/chat'),
                  ),
                  SizedBox(height: 12.h),

                  // Smart Manual Card
                  _buildFeatureCardWithStatus(
                    icon: Icons.library_books,
                    title: 'Smart Manual',
                    subtitle: 'PROCEDURE ACCESS GRANTED. File integrity confirmed.',
                    onTap: () => Navigator.pushNamed(context, '/manual'),
                  ),
                  SizedBox(height: 12.h),

                  // History Card
                  _buildFeatureCardWithStatus(
                    icon: Icons.history,
                    title: 'History',
                    subtitle: 'LOGS AVAILABLE. Historical data secured.',
                    onTap: () => Navigator.pushNamed(context, '/history'),
                  ),
                  SizedBox(height: 12.h),

                  // Camera Inspection Card
                  _buildFeatureCardWithStatus(
                    icon: Icons.camera_alt,
                    title: 'Camera Inspection',
                    subtitle: 'ACTIVE. Hardware link established.',
                    onTap: () => Navigator.pushNamed(context, '/camera'),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),

            // System Health Indicator (Bottom Right)
            Positioned(
              bottom: 30.h,
              right: 16.w,
              child: _buildHealthIndicator(),
            ),
          ],
        ),
      );

  AppBar _buildFuturisticAppBar() => AppBar(
      backgroundColor: const Color(0xFF0A1929),
      elevation: 0,
      title: Row(
        children: [
          Text(
            'AeroAssist AI',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00D4FF),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Center(
            child: Text(
              'TIME: 16:30',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00D4FF),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Center(
            child: Icon(
              Icons.cloud_done_rounded,
              color: const Color(0xFF00FF00),
              size: 18.sp,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Center(
            child: Icon(
              Icons.refresh_rounded,
              color: const Color(0xFF00D4FF),
              size: 18.sp,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Center(
            child: Icon(
              Icons.settings_rounded,
              color: const Color(0xFF00D4FF),
              size: 18.sp,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Center(
            child: Icon(
              Icons.menu_rounded,
              color: const Color(0xFF00D4FF),
              size: 18.sp,
            ),
          ),
        ),
      ],
    );

  Widget _buildStatusBox({
    required IconData icon,
    required String status,
    required String subtitle,
  }) => Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1929),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF00D4FF),
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00D4FF),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );

  Widget _buildMainStatusCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1929),
          border: Border.all(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4FF).withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFF00D4FF).withOpacity(0.08),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00D4FF),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00D4FF),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildFeatureCardWithStatus({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1929),
          border: Border.all(
            color: const Color(0xFF00D4FF).withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: const Color(0xFF00D4FF).withOpacity(0.08),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00D4FF),
                size: 18.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00D4FF),
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildHealthIndicator() => Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1929),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.4),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SYSTEM HEALTH',
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '100%',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00FF00),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
}
