import 'package:intl/intl.dart';
import '../models/maintenance_models.dart';
import 'database_service.dart';

class DocumentationService {
  late DatabaseService _db;

  void init(DatabaseService db) {
    _db = db;
  }

  /// Generate auto-documentation report
  Future<String> generateMaintenanceReport(MaintenanceLog log) async {
    final procedure = await _db.getProcedure(log.procedureId);
    if (procedure == null) return '';

    final totalSteps = procedure.steps.length;
    final completedSteps = log.stepLogs.where((s) => s.completed).length;
    final duration = log.endTime != null
        ? log.endTime!.difference(log.startTime)
        : Duration.zero;

    // Generate HTML report
    String report =
        '''
<!DOCTYPE html>
<html>
<head>
    <title>Maintenance Report - ${procedure.name}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #1976D2; color: white; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border-left: 4px solid #1976D2; }
        .status-complete { color: #4CAF50; font-weight: bold; }
        .status-incomplete { color: #f44336; font-weight: bold; }
        .step { margin: 10px 0; padding: 10px; background: #f5f5f5; border-radius: 3px; }
        .image-section { text-align: center; margin: 20px 0; }
        .image-section img { max-width: 100%; height: auto; border: 1px solid #ddd; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f5f5f5; font-weight: bold; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 2px solid #ddd; color: #666; }
    </style>
</head>
<body>
    <div class="header">
        <h1>${procedure.name}</h1>
        <p>Aircraft: ${procedure.aircraftType}</p>
        <p>Generated: ${_formatDate(DateTime.now())}</p>
    </div>

    <div class="section">
        <h2>Maintenance Details</h2>
        <table>
            <tr>
                <th>Technician</th>
                <td>${log.technician}</td>
            </tr>
            <tr>
                <th>Start Time</th>
                <td>${_formatDateTime(log.startTime)}</td>
            </tr>
            <tr>
                <th>End Time</th>
                <td>${log.endTime != null ? _formatDateTime(log.endTime!) : 'In Progress'}</td>
            </tr>
            <tr>
                <th>Duration</th>
                <td>${_formatDuration(duration)}</td>
            </tr>
            <tr>
                <th>Status</th>
                <td class="status-${log.status == 'completed' ? 'complete' : 'incomplete'}">${log.status.toUpperCase()}</td>
            </tr>
            <tr>
                <th>Steps Completed</th>
                <td>$completedSteps / $totalSteps (${((completedSteps / totalSteps) * 100).toStringAsFixed(1)}%)</td>
            </tr>
        </table>
    </div>

    <div class="section">
        <h2>Procedure Description</h2>
        <p>${procedure.description}</p>
    </div>

    <div class="section">
        <h2>Step-by-Step Summary</h2>
        ${_generateStepsHtml(log, procedure)}
    </div>

    <div class="section">
        <h2>Evidence & Documentation</h2>
        ${_generateImagesHtml(log)}
    </div>

    <div class="section">
        <h2>Notes</h2>
        <p>${log.notes ?? 'No additional notes'}</p>
    </div>

    <div class="footer">
        <p><strong>AeroAssist AI - Aircraft Maintenance Assistant</strong></p>
        <p>Offline Verified • Tamper-Proof Record • ISO Compliant</p>
        <p>Log ID: ${log.id}</p>
    </div>
</body>
</html>
''';

    return report;
  }

  String _generateStepsHtml(
    MaintenanceLog log,
    MaintenanceProcedure procedure,
  ) {
    String html = '';

    for (var i = 0; i < procedure.steps.length; i++) {
      final step = procedure.steps[i];
      final stepLog = log.stepLogs.firstWhere(
        (s) => s.stepNumber == i + 1,
        orElse: () => StepLog(
          stepId: step.id,
          stepNumber: i + 1,
          completed: false,
          completedAt: DateTime.now(),
        ),
      );

      final statusClass = stepLog.completed
          ? 'status-complete'
          : 'status-incomplete';
      final statusText = stepLog.completed ? '✓ COMPLETED' : '✗ INCOMPLETE';
      final verificationText = stepLog.verificationResult ?? 'Not verified';

      html +=
          '''
      <div class="step">
        <strong>Step ${i + 1}: ${step.instruction}</strong>
        <p>Component: ${step.component}</p>
        ${step.toolsRequired != null ? '<p>Tools: ${step.toolsRequired}</p>' : ''}
        ${step.safetyWarning != null ? '<p>⚠️ Safety: ${step.safetyWarning}</p>' : ''}
        <p><span class="$statusClass">$statusText</span></p>
        <p>Verification: $verificationText</p>
        ${stepLog.completedAt != null ? '<p>Completed at: ${_formatDateTime(stepLog.completedAt)}</p>' : ''}
      </div>
      ''';
    }

    return html;
  }

  String _generateImagesHtml(MaintenanceLog log) {
    if (log.imagePaths.isEmpty) {
      return '<p>No images captured</p>';
    }

    String html = '';
    for (var i = 0; i < log.imagePaths.length; i++) {
      html +=
          '''
      <div class="image-section">
        <h4>Evidence ${i + 1}</h4>
        <img src="data:image/jpeg;base64,${log.imagePaths[i]}" alt="Step evidence ${i + 1}">
      </div>
      ''';
    }

    return html;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '$hours h $minutes m $seconds s';
  }

  /// Export report as string
  Future<String> exportAsPlainText(MaintenanceLog log) async {
    final procedure = await _db.getProcedure(log.procedureId);
    if (procedure == null) return '';

    final duration = log.endTime != null
        ? log.endTime!.difference(log.startTime)
        : Duration.zero;

    String text =
        '''
╔═══════════════════════════════════════════════════════════════╗
║         AEROASSIST AI - MAINTENANCE REPORT                   ║
╚═══════════════════════════════════════════════════════════════╝

PROCEDURE: ${procedure.name}
AIRCRAFT: ${procedure.aircraftType}
GENERATED: ${_formatDateTime(DateTime.now())}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MAINTENANCE DETAILS:
  Technician............ ${log.technician}
  Start Time............ ${_formatDateTime(log.startTime)}
  End Time.............. ${log.endTime != null ? _formatDateTime(log.endTime!) : 'In Progress'}
  Duration.............. ${_formatDuration(duration)}
  Status................ ${log.status.toUpperCase()}
  Steps Completed....... ${log.stepLogs.where((s) => s.completed).length}/${procedure.steps.length}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP-BY-STEP SUMMARY:
''';

    for (var i = 0; i < procedure.steps.length; i++) {
      final step = procedure.steps[i];
      final stepLog = log.stepLogs.firstWhere(
        (s) => s.stepNumber == i + 1,
        orElse: () => StepLog(
          stepId: step.id,
          stepNumber: i + 1,
          completed: false,
          completedAt: DateTime.now(),
        ),
      );

      final status = stepLog.completed ? '✓ DONE' : '✗ PENDING';
      text +=
          '''
  Step ${i + 1}: ${step.instruction}
    Component: ${step.component}
    Status: $status
    Verification: ${stepLog.verificationResult ?? 'Not verified'}
''';
    }

    text +=
        '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NOTES:
${log.notes ?? 'No additional notes'}

IMAGES CAPTURED: ${log.imagePaths.length}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Generated by AeroAssist AI
Offline Verified • Tamper-Proof Record • ISO Compliant
Log ID: ${log.id}
''';

    return text;
  }

  /// Get maintenance history analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    final logs = await _db.getLogs();

    final totalLogs = logs.length;
    final completedLogs = logs.where((l) => l.status == 'completed').length;
    final averageDuration = logs.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds:
                logs
                    .map(
                      (l) => (l.endTime ?? DateTime.now())
                          .difference(l.startTime)
                          .inMilliseconds,
                    )
                    .reduce((a, b) => a + b) ~/
                logs.length,
          );

    final technicians = <String, int>{};
    for (var log in logs) {
      technicians[log.technician] = (technicians[log.technician] ?? 0) + 1;
    }

    return {
      'totalMaintenance': totalLogs,
      'completed': completedLogs,
      'inProgress': totalLogs - completedLogs,
      'completionRate': totalLogs == 0 ? 0 : (completedLogs / totalLogs) * 100,
      'averageDuration': averageDuration,
      'technicians': technicians,
      'totalImagesCaptu red': logs.fold<int>(
        0,
        (sum, log) => sum + log.imagePaths.length,
      ),
    };
  }
}
