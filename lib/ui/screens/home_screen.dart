import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _currentTime;
  late Timer _timer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Refresh dashboard data
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _currentTime = DateTime.now();
        });

        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ System refreshed - All systems operational'),
            backgroundColor: const Color(0xFF00FF00),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildFuturisticAppBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'AeroAssist AI',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // System Status Banner - Recovery Successful
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withOpacity(0.08),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withOpacity(0.6),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(6.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FF00),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FF00).withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'SYSTEM STATUS: RECOVERY SUCCESSFUL',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00FF00),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Main Info Panels
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 500;
                      return isMobile
                          ? Column(
                              children: [
                                _buildInfoPanel(
                                  title: 'SYSTEM STATUS: OPTIMAL',
                                  description:
                                      'Online AI active. Awaiting operational verification...',
                                  icon: Icons.verified_outlined,
                                ),
                                SizedBox(height: 14.h),
                                _buildInfoPanel(
                                  title: 'AI CORE: ACTIVE - STABLE',
                                  description: 'MODE: UNLOCKED - VERIFIED',
                                  icon: Icons.settings_remote_outlined,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _buildInfoPanel(
                                    title: 'SYSTEM STATUS: OPTIMAL',
                                    description:
                                        'Online AI active. Awaiting operational verification...',
                                    icon: Icons.verified_outlined,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: _buildInfoPanel(
                                    title: 'AI CORE: ACTIVE - STABLE',
                                    description: 'MODE: UNLOCKED - VERIFIED',
                                    icon: Icons.settings_remote_outlined,
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Feature Cards
                  _buildFeatureActionBar(
                    icon: Icons.build_outlined,
                    title: 'Start Maintenance',
                    description: 'PROCEDURE ACTIVE. Visual data restored.',
                    onTap: () => Navigator.pushNamed(context, '/maintenance'),
                  ),
                  SizedBox(height: 12.h),

                  _buildFeatureActionBar(
                    icon: Icons.chat_bubble_outline,
                    title: 'AI Assistant',
                    description:
                        'SERVICE AVAILABLE. Database access confirmed.',
                    onTap: () => Navigator.pushNamed(context, '/chat'),
                  ),
                  SizedBox(height: 12.h),

                  _buildFeatureActionBar(
                    icon: Icons.book_outlined,
                    title: 'Smart Manual',
                    description:
                        'PROCEDURE ACCESS GRANTED. File integrity confirmed.',
                    onTap: () => Navigator.pushNamed(context, '/manual'),
                  ),
                  SizedBox(height: 12.h),

                  _buildFeatureActionBar(
                    icon: Icons.history_outlined,
                    title: 'History',
                    description: 'LOGS AVAILABLE. Historical data secured.',
                    onTap: () => Navigator.pushNamed(context, '/history'),
                  ),
                  SizedBox(height: 12.h),

                  _buildFeatureActionBar(
                    icon: Icons.camera_alt_outlined,
                    title: 'Camera Inspection',
                    description: 'ACTIVE. Hardware link established.',
                    onTap: () => Navigator.pushNamed(context, '/camera'),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),

            // System Health Indicator (Bottom Right)
            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: _buildSystemHealth(),
            ),
          ],
        ),
      );

  AppBar _buildFuturisticAppBar() => AppBar(
        backgroundColor: const Color(0xFF0A0F14),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0088FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'AM',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'AeroMain',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00D4FF),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TIME',
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white24,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    _formatTime(_currentTime),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00D4FF),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_done_rounded,
                    color: const Color(0xFF00FF00),
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Center(
              child: _isRefreshing
                  ? SizedBox(
                      width: 16.sp,
                      height: 16.sp,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF00D4FF).withOpacity(0.8),
                        ),
                        strokeWidth: 2,
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: const Color(0xFF00D4FF),
                        size: 16.sp,
                      ),
                      onPressed: _refreshDashboard,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(maxWidth: 32.w),
                      tooltip: 'Refresh',
                    ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      );

  Widget _buildInfoPanel({
    required String title,
    required String description,
    required IconData icon,
  }) =>
      Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1929).withOpacity(0.6),
          border: Border.all(
            color: const Color(0xFF00D4FF).withOpacity(0.4),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF00D4FF),
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00D4FF),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      );

  Widget _buildFeatureActionBar({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1929).withOpacity(0.4),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.08),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF00D4FF),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.arrow_forward_rounded,
                color: const Color(0xFF00D4FF).withOpacity(0.6),
                size: 18.sp,
              ),
            ],
          ),
        ),
      );

  Widget _buildSystemHealth() => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1929).withOpacity(0.7),
          border: Border.all(
            color: const Color(0xFF00FF00).withOpacity(0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF00).withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'SYSTEM HEALTH',
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '100%',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00FF00),
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              width: 80.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(1.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1.r),
                child: LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF00FF00).withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
