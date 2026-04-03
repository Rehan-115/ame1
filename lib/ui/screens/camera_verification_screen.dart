import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/visual_lock_service.dart';
import '../../core/theme/app_theme.dart';

class CameraVerificationScreen extends StatefulWidget {
  const CameraVerificationScreen({
    Key? key,
    required this.component,
    required this.instruction,
  }) : super(key: key);
  final String component;
  final String instruction;

  @override
  State<CameraVerificationScreen> createState() =>
      _CameraVerificationScreenState();
}

class _CameraVerificationScreenState extends State<CameraVerificationScreen> {
  late VisualLockService _visualLockService;
  bool _isVerified = false;
  bool _isProcessing = false;
  double _confidence = 0;

  @override
  void initState() {
    super.initState();
    _visualLockService = VisualLockService();
    _startVerification();
  }

  Future<void> _startVerification() async {
    setState(() => _isProcessing = true);

    // Simulate real-time verification
    await for (final update in _visualLockService.detectionStream(
      widget.component,
    )) {
      if (!mounted) return;

      setState(() {
        _confidence = update['confidence'] ?? 0.0;
        _isVerified = update['detected'] ?? false;
      });

      if (_isVerified) {
        _showSuccessDialog();
        return;
      }
    }

    setState(() => _isProcessing = false);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✓ Verification Success'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Component: ${widget.component}'),
            SizedBox(height: 8.h),
            Text('Confidence: ${(_confidence * 100).toStringAsFixed(1)}%'),
            SizedBox(height: 8.h),
            const Text(
              'Step verified and recorded',
              style: TextStyle(
                color: AppTheme.successColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Visual Lock Verification'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Camera placeholder
                    Container(
                      height: 300.h,
                      width: double.infinity,
                      color: Colors.black87,
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 64.sp,
                              color: Colors.white30,
                            ),
                          ),
                          // Corner guides
                          ..._buildCornerGuides(),
                          // Component outline
                          if (!_isVerified)
                            Center(
                              child: Container(
                                height: 120.h,
                                width: 200.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _isProcessing
                                        ? Colors.yellow
                                        : Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'Align:\n${widget.component}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info Card
            Container(
              padding: EdgeInsets.all(16.w),
              color: _isVerified ? Colors.green.shade50 : Colors.orange.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instruction: ${widget.instruction}',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  SizedBox(height: 12.h),
                  // Confidence Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: _confidence,
                      minHeight: 6.h,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isVerified
                            ? AppTheme.successColor
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Detection: ${(_confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (_isVerified)
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.successColor),
                        SizedBox(width: 8.w),
                        Text(
                          'Component verified successfully!',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Detecting component...',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  List<Widget> _buildCornerGuides() => [
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white, width: 2),
                left: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white, width: 2),
                right: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white, width: 2),
                left: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white, width: 2),
                right: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ];

  @override
  void dispose() {
    _visualLockService.dispose();
    super.dispose();
  }
}
