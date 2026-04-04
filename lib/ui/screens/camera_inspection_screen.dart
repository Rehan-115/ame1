import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../services/object_detection_service.dart';
import '../../services/database_service.dart';
import '../../core/theme/app_theme.dart';

class CameraInspectionScreen extends StatefulWidget {
  const CameraInspectionScreen({super.key});

  @override
  State<CameraInspectionScreen> createState() => _CameraInspectionScreenState();
}

class _CameraInspectionScreenState extends State<CameraInspectionScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final ObjectDetectionService _detectionService = ObjectDetectionService();
  late DatabaseService _db;

  CameraController? _cameraController;
  late Future<void> _initializeCameraFuture;
  XFile? _capturedImage;
  DetectionResult? _detectionResult;
  MaintenanceSolution? _solution;
  bool _isAnalyzing = false;
  bool _isCameraReady = false;
  bool _showLiveCamera = true;
  bool _isRectifying = false;
  String _userMode = 'technician'; // 'passenger' or 'technician'

  @override
  void initState() {
    super.initState();
    _db = Provider.of<DatabaseService>(context, listen: false);
    _initializeCameraFuture = _initializeCamera();
    _loadUserMode();
  }

  Future<void> _loadUserMode() async {
    // In a real app, this would load from preferences/database
    // For now, default to 'technician'
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
          });
        }
      }
    } catch (e) {
      print('Camera initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _capturePhoto() async {
    try {
      if (_cameraController == null || !_isCameraReady) return;

      final image = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = image;
        _detectionResult = null;
        _solution = null;
        _isAnalyzing = true;
        _showLiveCamera = false;
      });

      await _analyzeImage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Capture error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final photo = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        setState(() {
          _capturedImage = photo;
          _detectionResult = null;
          _solution = null;
          _isAnalyzing = true;
          _showLiveCamera = false;
        });
        await _analyzeImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gallery error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final issues = [
        ('Engine Oil Level', 'Low oil detected'),
        ('Landing Gear Strut', 'Corrosion detected'),
        ('Brake System', 'Fluid leak detected'),
        ('Hydraulic Lines', 'Pressure drop'),
        ('Electrical Connectors', 'Loose connection'),
      ];

      final random = issues[DateTime.now().millisecond % issues.length];

      final result = DetectionResult(
        componentName: random.$1,
        issueType: random.$2,
        confidence: 0.85 + (DateTime.now().millisecond % 15) / 100,
        severity: DateTime.now().millisecond % 2 == 0 ? 'warning' : 'critical',
        description: 'Issue detected in captured image',
      );

      final solution = _detectionService.getSolutionForIssue(
        result.componentName,
        result.issueType,
      );

      if (mounted) {
        setState(() {
          _detectionResult = result;
          _solution = solution;
          _isAnalyzing = false;
        });
        _showSolutionBottomSheet();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _rectifyImage() async {
    try {
      setState(() => _isRectifying = true);

      // Simulate image rectification/processing
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isRectifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Image rectified and enhanced'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRectifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rectification error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showSolutionBottomSheet() {
    if (_solution == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _detectionResult!.severity == 'critical'
                                ? AppTheme.errorColor.withOpacity(0.2)
                                : AppTheme.warningColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _detectionResult!.severity.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _detectionResult!.severity == 'critical'
                                  ? AppTheme.errorColor
                                  : AppTheme.warningColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _solution!.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _detectionResult!.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.precision_manufacturing,
                        color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detection Confidence',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _detectionResult!.confidence,
                              minHeight: 6,
                              backgroundColor: Colors.grey.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _detectionResult!.confidence > 0.8
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_detectionResult!.confidence * 100).toStringAsFixed(0)}% Match',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Detected Issue',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_detectionResult!.componentName,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Camera Inspection'),
          elevation: 0,
          backgroundColor: const Color(0xFF0A1929),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: _showModeSettings,
              tooltip: 'Inspection Mode',
            ),
          ],
        ),
        body:
            _showLiveCamera ? _buildLiveCameraView() : _buildImagePreviewView(),
      );

  void _showModeSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inspection Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select view complexity:',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 16.h),
            _buildModeOption(
              'Passenger',
              'Easy steps - Simple instructions',
              'passenger',
            ),
            SizedBox(height: 12.h),
            _buildModeOption(
              'Technician',
              'Technical terms - Detailed specs',
              'technician',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption(String title, String subtitle, String mode) {
    final isSelected = _userMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _userMode = mode;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mode changed to: $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00D4FF).withOpacity(0.2)
              : Colors.grey[900],
          border: Border.all(
            color: isSelected ? const Color(0xFF00D4FF) : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF00D4FF) : Colors.grey[600]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00D4FF),
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCameraView() => FutureBuilder<void>(
        future: _initializeCameraFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!_isCameraReady || _cameraController == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 48.sp, color: const Color(0xFF00D4FF)),
                    SizedBox(height: 12.h),
                    Text(
                      'Camera Not Available',
                      style:
                          TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.image),
                      label: const Text('Choose from Gallery'),
                    ),
                  ],
                ),
              );
            }
            return Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  bottom: 20.h,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton(
                            onPressed: _capturePhoto,
                            backgroundColor: const Color(0xFF00D4FF),
                            child: Icon(Icons.camera, size: 24.sp),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImageFromGallery,
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Gallery'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );

  Widget _buildImagePreviewView() => SingleChildScrollView(
        child: Column(
          children: [
            // Image Preview Section
            if (_capturedImage != null && !_isAnalyzing)
              Container(
                margin: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    File(_capturedImage!.path),
                    fit: BoxFit.cover,
                    height: 300.h,
                    width: double.infinity,
                  ),
                ),
              ),

            // Thumbnail with Rectify Option
            if (_capturedImage != null && !_isAnalyzing)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: const Color(0xFFE8E8E8),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: const Color(0xFF00D4FF),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.file(
                          File(_capturedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Image Info & Rectify Button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Image Captured',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF222222),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Ready for analysis',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF666666),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          // Rectify Button
                          SizedBox(
                            height: 32.h,
                            child: ElevatedButton.icon(
                              onPressed: _isRectifying ? null : _rectifyImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D4FF),
                                disabledBackgroundColor:
                                    const Color(0xFFCCCCCC),
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                              ),
                              icon: _isRectifying
                                  ? SizedBox(
                                      width: 14.w,
                                      height: 14.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Icon(Icons.tune, size: 14.sp),
                              label: Text(
                                'Rectify',
                                style: TextStyle(fontSize: 10.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Analysis Indicator
            if (_isAnalyzing)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60.w,
                        height: 60.h,
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Analyzing Image...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Performing AI detection',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Buttons Section
            Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Take Photo Button
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _capturedImage = null;
                        _showLiveCamera = true;
                        _isRectifying = false;
                      });
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Retake Photo'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4FF),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Upload from Gallery Button
                  OutlinedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.image),
                    label: const Text('Upload from Gallery'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF00D4FF),
                        width: 1.5,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
