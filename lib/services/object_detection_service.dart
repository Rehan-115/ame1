import 'dart:typed_data';

class DetectionResult {
  final String componentName;
  final String issueType;
  final double confidence;
  final String severity; // 'critical', 'warning', 'info'
  final String description;

  DetectionResult({
    required this.componentName,
    required this.issueType,
    required this.confidence,
    required this.severity,
    required this.description,
  });
}

class MaintenanceSolution {
  final String title;
  final String componentName;
  final String issueType;
  final List<String> safetyWarnings;
  final List<String> requiredTools;
  final List<String> requiredParts;
  final List<MaintenanceStep> steps;
  final String estimatedTime;

  MaintenanceSolution({
    required this.title,
    required this.componentName,
    required this.issueType,
    required this.safetyWarnings,
    required this.requiredTools,
    required this.requiredParts,
    required this.steps,
    required this.estimatedTime,
  });
}

class MaintenanceStep {
  final int stepNumber;
  final String instruction;
  final String tool;
  final String expectedResult;
  final List<String> warnings;

  MaintenanceStep({
    required this.stepNumber,
    required this.instruction,
    required this.tool,
    required this.expectedResult,
    required this.warnings,
  });
}

class ObjectDetectionService {
  // ML-based component detection from camera images
  Future<List<DetectionResult>> detectComponentsFromImage(
      Uint8List imageData) async {
    // Simulate TensorFlow Lite detection
    // In production: load actual ML model and run inference

    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock detections based on image analysis
    return [
      DetectionResult(
        componentName: 'Engine Oil Level',
        issueType: 'Low oil detected',
        confidence: 0.92,
        severity: 'warning',
        description: 'Engine oil level is below minimum mark',
      ),
    ];
  }

  /// Get maintenance solution for detected issue
  MaintenanceSolution getSolutionForIssue(String component, String issueType) {
    final solutions = {
      'Engine Oil Level|Low oil detected': MaintenanceSolution(
        title: 'Engine Oil Refill - AMM 73-00-00',
        componentName: 'Engine Oil System',
        issueType: 'Low oil level',
        safetyWarnings: [
          '⚠️ CRITICAL: Engine must be completely shut down for minimum 30 minutes',
          '⚠️ Never open oil drain plug on hot engine - burn hazard',
          '⚠️ Use only approved aviation oil (Mobil Jet Oil II)',
          '⚠️ Improper oil type can cause engine damage',
          '🛡️ Always wear protective gloves and eye protection',
        ],
        requiredTools: [
          '• Oil drain pan (8L capacity)',
          '• Torque wrench (35-45 Nm)',
          '• Oil filter wrench (adjustable 2.75-3.5")',
          '• Level indicator/dipstick',
          '• Funnel',
          '• Rags/absorbent material',
        ],
        requiredParts: [
          '• Mobil Jet Oil II (8L container)',
          '• Fram PH3965 oil filter',
          '• Oil drain plug gasket',
        ],
        steps: [
          MaintenanceStep(
            stepNumber: 1,
            instruction: 'Shut down engines',
            tool: 'N/A',
            expectedResult: 'All engines stopped, safe to work',
            warnings: ['⚠️ Wait minimum 30 minutes for engine cooling'],
          ),
          MaintenanceStep(
            stepNumber: 2,
            instruction: 'Locate oil drain plug (starboard side, below engine)',
            tool: 'Flashlight',
            expectedResult: 'Oil drain plug clearly visible',
            warnings: ['⚠️ Do not touch if still warm'],
          ),
          MaintenanceStep(
            stepNumber: 3,
            instruction: 'Place oil drain pan underneath',
            tool: 'Oil drain pan',
            expectedResult: 'Pan positioned to catch all draining oil',
            warnings: ['⚠️ Ensure container is large enough (8L+)'],
          ),
          MaintenanceStep(
            stepNumber: 4,
            instruction: 'Remove oil drain plug slowly',
            tool: 'Wrench (19mm)',
            expectedResult: 'Oil flowing smoothly into pan',
            warnings: [
              '⚠️ Be prepared for oil flow - have rags ready',
              '⚠️ Do not force if stuck - use penetrant oil'
            ],
          ),
          MaintenanceStep(
            stepNumber: 5,
            instruction: 'Wait for oil to fully drain (5-10 minutes)',
            tool: 'Timer',
            expectedResult: 'Only drops remaining',
            warnings: ['⚠️ Do not rush this step - ensure complete drainage'],
          ),
          MaintenanceStep(
            stepNumber: 6,
            instruction: 'Remove oil filter with wrench',
            tool: 'Oil filter wrench',
            expectedResult: 'Old filter removed, surface clean',
            warnings: ['⚠️ Oil may still be warm - use gloves'],
          ),
          MaintenanceStep(
            stepNumber: 7,
            instruction: 'Install new oil filter (hand-tight)',
            tool: 'Fram PH3965 filter',
            expectedResult: 'Filter snug but not over-tightened',
            warnings: ['⚠️ Do not use wrench to tighten - hand-tight only'],
          ),
          MaintenanceStep(
            stepNumber: 8,
            instruction: 'Replace drain plug and torque to 40 Nm',
            tool: 'Torque wrench (35-45 Nm)',
            expectedResult: 'Plug secure, no leaks',
            warnings: ['⚠️ Do not exceed torque specification'],
          ),
          MaintenanceStep(
            stepNumber: 9,
            instruction: 'Fill with new Mobil Jet Oil II',
            tool: 'Oil container + funnel',
            expectedResult: 'Oil level between MIN and MAX markers',
            warnings: [
              '⚠️ Use ONLY Mobil Jet Oil II - automotive oil causes damage'
            ],
          ),
          MaintenanceStep(
            stepNumber: 10,
            instruction: 'Start engine and check for leaks',
            tool: 'N/A',
            expectedResult: 'Engine starts smoothly, no drips visible',
            warnings: ['⚠️ Check oil level again after 5 minutes run time'],
          ),
        ],
        estimatedTime: '45 minutes',
      ),
      'Landing Gear|Corrosion detected': MaintenanceSolution(
        title: 'Landing Gear Inspection & Corrosion Treatment - AMM 32-12-00',
        componentName: 'Landing Gear Strut',
        issueType: 'Surface corrosion',
        safetyWarnings: [
          '⚠️ CRITICAL: Aircraft must be on certified landing gear support stands',
          '⚠️ Never work under lifted aircraft without positive locking',
          '⚠️ Use electrical continuity test before touching (static hazard)',
          '🛡️ Wear protective gloves and safety glasses',
          '⚠️ Ensure landing gear uplocks are engaged',
        ],
        requiredTools: [
          '• Landing gear support stands (certified)',
          '• Soft-bristle brush',
          '• Corrosion remover fluid',
          '• Clean rags',
          '• Wire brush (non-metallic)',
          '• Torque wrench (150-190 Nm)',
        ],
        requiredParts: [
          '• Corrosion inhibitor spray',
          '• Protective boot sealant',
          '• Fastener replacement kit (if needed)',
        ],
        steps: [
          MaintenanceStep(
            stepNumber: 1,
            instruction: 'Position aircraft on certified landing gear stands',
            tool: 'Stands',
            expectedResult: 'Gear fully supported, no movement',
            warnings: [
              '⚠️ Get Safety Officer approval before starting',
              '⚠️ Use minimum 4 stands per main gear'
            ],
          ),
          MaintenanceStep(
            stepNumber: 2,
            instruction: 'Visually inspect full length of gear strut',
            tool: 'Flashlight',
            expectedResult: 'All corrosion areas identified and marked',
            warnings: ['⚠️ Look for pitting, discoloration, white deposits'],
          ),
          MaintenanceStep(
            stepNumber: 3,
            instruction: 'Clean corroded areas with soft brush',
            tool: 'Non-metallic wire brush',
            expectedResult: 'Loose corrosion removed, surface exposed',
            warnings: [
              '⚠️ Do not use steel brush - can damage underlying metal'
            ],
          ),
          MaintenanceStep(
            stepNumber: 4,
            instruction: 'Apply corrosion remover fluid',
            tool: 'Corrosion remover',
            expectedResult: 'Chemical reaction begins, corrosion dissolves',
            warnings: ['⚠️ Follow product safety instructions - wear gloves'],
          ),
          MaintenanceStep(
            stepNumber: 5,
            instruction: 'Let treatment sit for specified time',
            tool: 'Timer (follow product)',
            expectedResult: 'Corrosion fully softened',
            warnings: ['⚠️ Do not skip this step - ensure complete treatment'],
          ),
          MaintenanceStep(
            stepNumber: 6,
            instruction: 'Clean treated area with fresh cloth',
            tool: 'Clean rag',
            expectedResult: 'Surface clean and dry',
            warnings: [
              '⚠️ Remove all residue - incomplete cleaning causes re-corrosion'
            ],
          ),
          MaintenanceStep(
            stepNumber: 7,
            instruction: 'Apply protective corrosion inhibitor',
            tool: 'Corrosion inhibitor spray',
            expectedResult: 'Protective coating applied evenly',
            warnings: ['⚠️ Use thin, even coats - do not saturate'],
          ),
          MaintenanceStep(
            stepNumber: 8,
            instruction: 'Check all fasteners for tightness',
            tool: 'Torque wrench (170-190 Nm)',
            expectedResult: 'All fasteners within specification',
            warnings: ['⚠️ Re-torque after treatment (thermal cycling)'],
          ),
          MaintenanceStep(
            stepNumber: 9,
            instruction: 'Inspect rod boot for cracks',
            tool: 'Flashlight',
            expectedResult: 'Boot intact, no damage visible',
            warnings: ['⚠️ If damaged, replace per SRM 32-12-00'],
          ),
          MaintenanceStep(
            stepNumber: 10,
            instruction: 'Document work and verify safety pins installed',
            tool: 'Inspection log',
            expectedResult: 'Work logged, landing gear safe for flight',
            warnings: [
              '⚠️ Do not remove support stands until gear deployed test passed'
            ],
          ),
        ],
        estimatedTime: '90 minutes',
      ),
      'Brake System|Fluid leak detected': MaintenanceSolution(
        title: 'Brake System Fluid Leak Inspection - AMM 32-41-00',
        componentName: 'Brake System',
        issueType: 'Hydraulic fluid leak',
        safetyWarnings: [
          '⚠️ CRITICAL: Brake failure can cause aircraft accident - DO NOT FLY',
          '⚠️ Hydraulic fluid is pressurized - never remove fittings under pressure',
          '⚠️ Brake system must be depressurized before opening any connections',
          '🛡️ Wear goggles - pressurized fluid can cause serious eye injury',
          '⚠️ High-pressure hose rupture can cause permanent damage',
        ],
        requiredTools: [
          '• Pressure relief valve (depressurization)',
          '• Wrench set (metric)',
          '• Hydraulic fluid identification kit',
          '• Brake pressure test gauge',
          '• Absorbent material',
          '• Safety glasses/goggles',
        ],
        requiredParts: [
          '• Replacement hydraulic fluid (Skydrol LD-4)',
          '• Hydraulic hose assemblies (if needed)',
          '• Seals and O-ring kit',
          '• Quick-disconnect fittings',
        ],
        steps: [
          MaintenanceStep(
            stepNumber: 1,
            instruction: 'Issue GROUNDED ORDER - Aircraft not airworthy',
            tool: 'N/A',
            expectedResult: 'Flight crew notified, aircraft grounded',
            warnings: ['⚠️ Mandatory - safety critical'],
          ),
          MaintenanceStep(
            stepNumber: 2,
            instruction: 'Depressurize brake system completely',
            tool: 'Pressure relief valve',
            expectedResult: 'Pressure gauge reads zero',
            warnings: ['⚠️ Do not skip - failure can cause severe injuries'],
          ),
          MaintenanceStep(
            stepNumber: 3,
            instruction: 'Locate source of leak visually',
            tool: 'Flashlight',
            expectedResult: 'Leak point identified (hose, fitting, wheel)',
            warnings: [
              '⚠️ Trace leak path to source - may be distance from pool'
            ],
          ),
          MaintenanceStep(
            stepNumber: 4,
            instruction: 'Place absorbent material under leak area',
            tool: 'Absorbent pads',
            expectedResult: 'Leak contained, prevents fluid spread',
            warnings: ['⚠️ Environmental containment required'],
          ),
          MaintenanceStep(
            stepNumber: 5,
            instruction: 'Inspect hose for cracks, cuts, or kinks',
            tool: 'Magnifying glass',
            expectedResult: 'Damage location clearly visible',
            warnings: ['⚠️ Small cuts visible at special angle only'],
          ),
          MaintenanceStep(
            stepNumber: 6,
            instruction: 'Check fitting tightness with wrench',
            tool: 'Wrench',
            expectedResult: 'Fitting snug or clearly loose',
            warnings: [
              '⚠️ Over-tightening can damage fitting - use calibrated wrench'
            ],
          ),
          MaintenanceStep(
            stepNumber: 7,
            instruction: 'If loose fitting: tighten to spec',
            tool: 'Torque wrench (65 Nm for M14)',
            expectedResult: 'Leak stops, no fluid dripping',
            warnings: ['⚠️ Wait 5 minutes to confirm leak stopped'],
          ),
          MaintenanceStep(
            stepNumber: 8,
            instruction: 'If damaged hose: remove and replace',
            tool: 'Wrench set, new hose assembly',
            expectedResult: 'New hose installed and tight',
            warnings: ['⚠️ Use exact pressure rating replacement - critical'],
          ),
          MaintenanceStep(
            stepNumber: 9,
            instruction: 'Refill brake system with new fluid',
            tool: 'Skydrol LD-4 + bleeder valve',
            expectedResult: 'System full, no air in lines',
            warnings: ['⚠️ Bleed air completely - air compress under pressure'],
          ),
          MaintenanceStep(
            stepNumber: 10,
            instruction: 'Perform functional brake test on ground',
            tool: 'Test checklist',
            expectedResult: 'Brakes firm, no spongy feel, equal pressure',
            warnings: [
              '⚠️ Do NOT fly until confirmed - safety critical system'
            ],
          ),
        ],
        estimatedTime: '120 minutes',
      ),
    };

    final key = '$component|$issueType';
    return solutions[key] ??
        MaintenanceSolution(
          title: 'General Inspection - $component',
          componentName: component,
          issueType: issueType,
          safetyWarnings: [
            '⚠️ Always consult AMM before starting maintenance',
            '⚠️ Ensure proper tools and PPE available',
            '⚠️ Follow all safety procedures',
          ],
          requiredTools: ['• Standard tool kit', '• Inspection equipment'],
          requiredParts: ['• Replacement components (if identified)'],
          steps: [
            MaintenanceStep(
              stepNumber: 1,
              instruction: 'Visual inspection of component',
              tool: 'Flashlight',
              expectedResult: 'Issue clearly identified',
              warnings: ['⚠️ Document findings with photos'],
            ),
            MaintenanceStep(
              stepNumber: 2,
              instruction: 'Consult Aircraft Maintenance Manual',
              tool: 'AMM (Documentation Screen)',
              expectedResult: 'Proper procedure identified',
              warnings: ['⚠️ Do not deviate from official procedures'],
            ),
          ],
          estimatedTime: 'Varies',
        );
  }

  /// Get list of detectable components
  List<String> getDetectableComponents() => [
        'Engine Oil Level',
        'Landing Gear',
        'Brake System',
        'Hydraulic Lines',
        'Electrical Connectors',
        'Fuel System',
        'Oxygen System',
        'Flight Controls',
        'Structural Panels',
        'Door Seals',
      ];
}
