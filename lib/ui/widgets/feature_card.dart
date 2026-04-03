import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aeroassist_ai/core/theme/app_theme.dart';

class FeatureCard extends StatefulWidget {
  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = Colors.blue,
    this.badge,
    this.emoji,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  final String? badge;
  final String? emoji;

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Card(
            elevation: _isHovering ? 4 : 1,
            shadowColor: widget.color.withOpacity(0.15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r)),
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(6.r),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: _isHovering
                          ? widget.color.withOpacity(0.3)
                          : widget.color.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.all(14.w),
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        height: 52.h,
                        width: 52.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color.withOpacity(0.12),
                              widget.color.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: widget.color.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: widget.emoji != null
                              ? Text(widget.emoji!,
                                  style: TextStyle(fontSize: 24.sp))
                              : Icon(
                                  widget.icon,
                                  color: widget.color,
                                  size: 24.sp,
                                ),
                        ),
                      ),
                      SizedBox(width: 14.w),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Arrow Icon
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14.sp,
                        color: _isHovering
                            ? widget.color.withOpacity(0.6)
                            : widget.color.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Badge
          if (widget.badge != null)
            Positioned(
              top: 8.w,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.badge!,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      );
}
