import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/object_detection_service.dart';
import '../../core/theme/app_theme.dart';

class CameraInspectionScreen extends StatefulWidget {
  const CameraInspectionScreen({super.key});

  @override
  State<CameraInspectionScreen> createState() => _CameraInspectionScreenState();
}

class _CameraInspectionScreenState extends State<CameraInspectionScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final ObjectDetectionService _detectionService = ObjectDetectionService();

  XFile? _capturedImage;
  DetectionResult? _detectionResult;
  MaintenanceSolution? _solution;
  bool _isAnalyzing = false;

  Future<void> _capturePhoto() async {
    try {
      final photo = await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _capturedImage = photo;
          _detectionResult = null;
          _solution = null;
          _isAnalyzing = true;
        });
        await _analyzeImage();
      }
    } catch (e) {
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

  Future<void> _pickImageFromGallery() async {
    try {
      final photo = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        setState(() {
          _capturedImage = photo;
          _detectionResult = null;
          _solution = null;
          _isAnalyzing = true;
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
      // Simulate ML detection - randomly pick a component issue
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
              // Header
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

              // Confidence Score
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

              // Safety Warnings
              _buildSection(
                title: '⚠️ Safety Warnings',
                icon: Icons.warning_rounded,
                color: AppTheme.errorColor,
                children:
                    _solution!.safetyWarnings.map(_buildWarningItem).toList(),
              ),
              const SizedBox(height: 20),

              // Required Tools
              _buildSection(
                title: '🔧 Required Tools',
                icon: Icons.construction_rounded,
                color: const Color(0xFFF97316),
                children: _solution!.requiredTools.map(_buildListItem).toList(),
              ),
              const SizedBox(height: 20),

              // Required Parts
              _buildSection(
                title: '📦 Required Parts',
                icon: Icons.inventory_2_rounded,
                color: const Color(0xFF8B5CF6),
                children: _solution!.requiredParts.map(_buildListItem).toList(),
              ),
              const SizedBox(height: 20),

              // Step-by-Step Procedure
              _buildSection(
                title: '📋 Step-by-Step Procedure',
                icon: Icons.list_alt_rounded,
                color: AppTheme.primaryColor,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Estimated Time: ${_solution!.estimatedTime}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._solution!.steps.map(_buildStepCard),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Maintenance logged. Follow all safety warnings!',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Start Maintenance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Inspect Another Component'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      );

  Widget _buildWarningItem(String warning) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          border: Border(
            left: BorderSide(
              color: AppTheme.errorColor,
              width: 3,
            ),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          warning,
          style: const TextStyle(fontSize: 12, height: 1.5),
        ),
      );

  Widget _buildListItem(String item) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          item,
          style: const TextStyle(fontSize: 12),
        ),
      );

  Widget _buildStepCard(MaintenanceStep step) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.instruction,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('🔧 Tool:', step.tool),
                  const SizedBox(height: 8),
                  _buildInfoRow('✓ Expected:', step.expectedResult),
                  if (step.warnings.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...step.warnings
                        .map((w) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                w,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildInfoRow(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      );

  Widget _buildCameraReadyScreen() => Scaffold(
        appBar: AppBar(
          title: const Text('Camera Inspection'),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 60,
                          color: AppTheme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Camera Ready',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Point camera at aircraft\nto detect issues',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.camera),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.image),
                    label: const Text('Choose from Gallery'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildImagePreviewScreen() => Scaffold(
        body: Stack(
          children: [
            Image.file(
              File(_capturedImage!.path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            if (_isAnalyzing)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Analyzing...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton.small(
                onPressed: () => setState(() {
                  _capturedImage = null;
                  _detectionResult = null;
                }),
                backgroundColor: Colors.red,
                child: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_capturedImage == null) {
      return _buildCameraReadyScreen();
    }
    return _buildImagePreviewScreen();
  }
}
