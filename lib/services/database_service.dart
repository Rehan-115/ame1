import 'package:flutter/foundation.dart';
import '../models/maintenance_models.dart';

// Mock database for web platform
class MockDatabase {
  final Map<String, List<Map<String, dynamic>>> _tables = {
    'maintenance_procedures': [],
    'maintenance_logs': [],
    'chat_messages': [],
    'tech_specs': [],
  };

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List? whereArgs, String? orderBy}) async {
    final results = _tables[table] ?? [];
    return results;
  }

  Future<int> insert(String table, Map<String, dynamic> values,
      {dynamic conflictAlgorithm}) async {
    _tables.putIfAbsent(table, () => []).add(values);
    return 1;
  }

  Future<int> delete(String table, {String? where, List? whereArgs}) async => 1;

  Future<int> update(String table, Map<String, dynamic> values,
          {String? where, List? whereArgs}) async =>
      1;

  Future<void> execute(String sql, [List? arguments]) async {
    // No-op for mock
  }

  Future<void> close() async {
    // No-op for mock
  }
}

class DatabaseService {
  static dynamic _database;
  static const String _dbName = 'aeroassist_ai.db';

  Future<dynamic> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<dynamic> _initDatabase() async {
    if (kIsWeb) {
      // Use mock database for web
      return MockDatabase();
    }

    // Use sqflite for mobile/desktop
    // For now, use mock database for all platforms
    return MockDatabase();
  }

  Future<void> _createTables(dynamic db, int version) async {
    if (db is MockDatabase) return;

    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS maintenance_procedures (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          aircraftType TEXT,
          steps TEXT NOT NULL,
          createdAt TEXT,
          technician TEXT,
          status TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS maintenance_logs (
          id TEXT PRIMARY KEY,
          procedureId TEXT,
          technician TEXT,
          startTime TEXT,
          endTime TEXT,
          stepLogs TEXT,
          status TEXT,
          imagePaths TEXT,
          notes TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS chat_messages (
          id TEXT PRIMARY KEY,
          text TEXT,
          isUser INTEGER,
          timestamp TEXT,
          response TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS tech_specs (
          id TEXT PRIMARY KEY,
          component TEXT,
          specification TEXT,
          value TEXT,
          unit TEXT,
          range TEXT,
          procedure TEXT
        )
      ''');
    } catch (e) {
      // Ignore errors in web context
    }
  }

  Future<void> init() async {
    await database;
  }

  // Maintenance Procedures
  Future<String> saveProcedure(MaintenanceProcedure procedure) async {
    final db = await database;
    try {
      await db.insert(
        'maintenance_procedures',
        {
          'id': procedure.id,
          'name': procedure.name,
          'description': procedure.description,
          'aircraftType': procedure.aircraftType,
          'steps': procedure.steps.map((s) => s.toMap()).toString(),
          'createdAt': procedure.createdAt.toUtc().toIso8601String(),
          'technician': procedure.technician,
          'status': procedure.status,
        },
        conflictAlgorithm: !kIsWeb ? 1 : null, // ConflictAlgorithm.replace == 1
      );
    } catch (e) {
      // Ignore in web context
    }
    return procedure.id;
  }

  Future<List<MaintenanceProcedure>> getProcedures() async {
    final db = await database;
    try {
      final result = await db.query('maintenance_procedures');
      return result
          .map((map) =>
              MaintenanceProcedure.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<MaintenanceProcedure?> getProcedure(String id) async {
    final db = await database;
    try {
      final result = await db.query(
        'maintenance_procedures',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return MaintenanceProcedure.fromMap(
            result.first as Map<String, dynamic>);
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  // Maintenance Logs
  Future<String> saveLog(MaintenanceLog log) async {
    final db = await database;
    try {
      await db.insert(
        'maintenance_logs',
        {
          'id': log.id,
          'procedureId': log.procedureId,
          'technician': log.technician,
          'startTime': log.startTime.toUtc().toIso8601String(),
          'endTime': log.endTime?.toUtc().toIso8601String(),
          'stepLogs': log.stepLogs.map((s) => s.toMap()).toString(),
          'status': log.status,
          'imagePaths': log.imagePaths.toString(),
          'notes': log.notes,
        },
        conflictAlgorithm: !kIsWeb ? 1 : null,
      );
    } catch (e) {
      // Ignore
    }
    return log.id;
  }

  Future<List<MaintenanceLog>> getLogs() async {
    final db = await database;
    try {
      final result = await db.query('maintenance_logs');
      return result
          .map((map) => MaintenanceLog.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<MaintenanceLog?> getLog(String id) async {
    final db = await database;
    try {
      final result = await db.query(
        'maintenance_logs',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return MaintenanceLog.fromMap(result.first as Map<String, dynamic>);
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  // Chat Messages
  Future<void> saveChatMessage(ChatMessage message) async {
    final db = await database;
    try {
      await db.insert(
        'chat_messages',
        {
          'id': message.id,
          'text': message.text,
          'isUser': message.isUser ? 1 : 0,
          'timestamp': message.timestamp.toUtc().toIso8601String(),
          'response': message.response,
        },
        conflictAlgorithm: !kIsWeb ? 1 : null,
      );
    } catch (e) {
      // Ignore
    }
  }

  Future<List<ChatMessage>> getChatHistory() async {
    final db = await database;
    try {
      final result = await db.query(
        'chat_messages',
        orderBy: 'timestamp DESC',
        limit: 100,
      );
      return result
          .map((map) => ChatMessage.fromMap(map as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Tech Specs
  Future<void> saveTechSpec(TechSpec spec) async {
    final db = await database;
    try {
      await db.insert(
        'tech_specs',
        {
          'id': '${spec.component}_${spec.specification}',
          'component': spec.component,
          'specification': spec.specification,
          'value': spec.value,
          'unit': spec.unit,
          'range': spec.range,
          'procedure': spec.procedure,
        },
        conflictAlgorithm: !kIsWeb ? 1 : null,
      );
    } catch (e) {
      // Ignore
    }
  }

  Future<List<TechSpec>> searchTechSpecs(String query) async {
    final db = await database;
    try {
      final result = await db.query(
        'tech_specs',
        where: 'component LIKE ? OR specification LIKE ? OR value LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
      );
      return result
          .map((map) => TechSpec.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db is! MockDatabase) {
      try {
        await db.close();
      } catch (e) {
        // Ignore
      }
    }
  }
}
