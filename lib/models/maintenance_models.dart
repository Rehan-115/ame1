import 'package:uuid/uuid.dart';

class MaintenanceProcedure {
  // pending, in-progress, completed

  MaintenanceProcedure({
    required this.name,
    required this.description,
    required this.aircraftType,
    required this.steps,
    String? id,
    DateTime? createdAt,
    String? technician,
    String? status,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toUtc(),
        technician = technician ?? 'Unknown',
        status = status ?? 'pending';

  factory MaintenanceProcedure.fromMap(Map<String, dynamic> map) =>
      MaintenanceProcedure(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        aircraftType: map['aircraftType'],
        steps: List<MaintenanceStep>.from(
          map['steps']?.map((x) => MaintenanceStep.fromMap(x)) ?? [],
        ),
        createdAt: _parseDateTime(map['createdAt']),
        technician: map['technician'],
        status: map['status'],
      );
  final String id;
  final String name;
  final String description;
  final String aircraftType;
  final List<MaintenanceStep> steps;
  final DateTime createdAt;
  final String technician;
  final String status;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'aircraftType': aircraftType,
        'steps': steps.map((s) => s.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'technician': technician,
        'status': status,
      };
}

class MaintenanceStep {
  MaintenanceStep({
    required this.stepNumber,
    required this.instruction,
    required this.component,
    required this.requiresVerification,
    String? id,
    this.toolsRequired,
    this.safetyWarning,
    this.expectedResult,
    this.isCompleted = false,
    this.imagePath,
    this.completedAt,
  }) : id = id ?? const Uuid().v4();

  factory MaintenanceStep.fromMap(Map<String, dynamic> map) => MaintenanceStep(
        id: map['id'],
        stepNumber: map['stepNumber'],
        instruction: map['instruction'],
        component: map['component'],
        toolsRequired: map['toolsRequired'],
        safetyWarning: map['safetyWarning'],
        expectedResult: map['expectedResult'],
        requiresVerification: map['requiresVerification'],
        isCompleted: map['isCompleted'] ?? false,
        imagePath: map['imagePath'],
        completedAt: map['completedAt'] != null
            ? _parseDateTime(map['completedAt'])
            : null,
      );
  final String id;
  final int stepNumber;
  final String instruction;
  final String component;
  final String? toolsRequired;
  final String? safetyWarning;
  final String? expectedResult;
  final bool requiresVerification;
  bool isCompleted;
  String? imagePath; // Path to captured image
  DateTime? completedAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'stepNumber': stepNumber,
        'instruction': instruction,
        'component': component,
        'toolsRequired': toolsRequired,
        'safetyWarning': safetyWarning,
        'expectedResult': expectedResult,
        'requiresVerification': requiresVerification,
        'isCompleted': isCompleted,
        'imagePath': imagePath,
        'completedAt': completedAt?.toIso8601String(),
      };
}

class MaintenanceLog {
  MaintenanceLog({
    required this.procedureId,
    required this.technician,
    String? id,
    DateTime? startTime,
    this.endTime,
    List<StepLog>? stepLogs,
    String? status,
    List<String>? imagePaths,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now().toUtc(),
        stepLogs = stepLogs ?? [],
        status = status ?? 'in-progress',
        imagePaths = imagePaths ?? [];

  factory MaintenanceLog.fromMap(Map<String, dynamic> map) => MaintenanceLog(
        id: map['id'],
        procedureId: map['procedureId'],
        technician: map['technician'],
        startTime: _parseDateTime(map['startTime']),
        endTime: map['endTime'] != null ? _parseDateTime(map['endTime']) : null,
        stepLogs: List<StepLog>.from(
          map['stepLogs']?.map((x) => StepLog.fromMap(x)) ?? [],
        ),
        status: map['status'],
        imagePaths: List<String>.from(map['imagePaths'] ?? []),
        notes: map['notes'],
      );
  final String id;
  final String procedureId;
  final String technician;
  final DateTime startTime;
  DateTime? endTime;
  final List<StepLog> stepLogs;
  final String status; // in-progress, completed
  final List<String> imagePaths;
  String? notes;

  Map<String, dynamic> toMap() => {
        'id': id,
        'procedureId': procedureId,
        'technician': technician,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'stepLogs': stepLogs.map((s) => s.toMap()).toList(),
        'status': status,
        'imagePaths': imagePaths,
        'notes': notes,
      };
}

class StepLog {
  // passed, failed, skipped

  StepLog({
    required this.stepId,
    required this.stepNumber,
    required this.completed,
    DateTime? completedAt,
    this.imagePath,
    this.verificationResult,
  }) : completedAt = completedAt ?? DateTime.now().toUtc();

  factory StepLog.fromMap(Map<String, dynamic> map) => StepLog(
        stepId: map['stepId'],
        stepNumber: map['stepNumber'],
        completed: map['completed'],
        completedAt: _parseDateTime(map['completedAt']),
        imagePath: map['imagePath'],
        verificationResult: map['verificationResult'],
      );
  final String stepId;
  final int stepNumber;
  final bool completed;
  final DateTime completedAt;
  final String? imagePath;
  final String? verificationResult;

  Map<String, dynamic> toMap() => {
        'stepId': stepId,
        'stepNumber': stepNumber,
        'completed': completed,
        'completedAt': completedAt.toIso8601String(),
        'imagePath': imagePath,
        'verificationResult': verificationResult,
      };
}

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    String? id,
    DateTime? timestamp,
    this.response,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now().toUtc();

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'],
        text: map['text'],
        isUser: map['isUser'],
        timestamp: _parseDateTime(map['timestamp']),
        response: map['response'],
      );
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  String? response;

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'response': response,
      };
}

class TechSpec {
  TechSpec({
    required this.component,
    required this.specification,
    required this.value,
    required this.unit,
    this.range,
    this.procedure,
  });

  factory TechSpec.fromMap(Map<String, dynamic> map) => TechSpec(
        component: map['component'],
        specification: map['specification'],
        value: map['value'],
        unit: map['unit'],
        range: map['range'],
        procedure: map['procedure'],
      );
  final String component;
  final String specification;
  final String value;
  final String unit;
  final String? range;
  final String? procedure;

  Map<String, dynamic> toMap() => {
        'component': component,
        'specification': specification,
        'value': value,
        'unit': unit,
        'range': range,
        'procedure': procedure,
      };
}

/// Safe DateTime parsing with validation and UTC conversion
DateTime _parseDateTime(dynamic value) {
  try {
    if (value == null) {
      return DateTime.now().toUtc();
    }
    if (value is DateTime) {
      return value.isUtc ? value : value.toUtc();
    }
    if (value is String) {
      final parsed = DateTime.parse(value);
      return parsed.isUtc ? parsed : parsed.toUtc();
    }
    return DateTime.now().toUtc();
  } catch (e) {
    print('Error parsing datetime: $value - $e');
    return DateTime.now().toUtc();
  }
}
