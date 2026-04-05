import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/maintenance_models.dart';
import 'database_service.dart';
import 'ollama_service.dart';

class ChatService {
  late Map<String, dynamic> _maintenanceData;
  late Map<String, dynamic> _torqueSpecs;
  late DatabaseService _db;
  late OllamaService _ollamaService;

  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _ollamaInitialized = false;

  // User mode: 'engineer' or 'passenger'
  String userMode = 'engineer';

  // Public getter for Ollama connection status
  bool get ollamaInitialized => _ollamaInitialized;

  Future<void> init(DatabaseService db) async {
    _db = db;
    _ollamaService = OllamaService();

    if (!_isInitialized && !_isInitializing) {
      _isInitializing = true;
      await _loadOfflineData();

      // Try to initialize Ollama connection (non-blocking)
      try {
        _ollamaInitialized = await _ollamaService.checkAvailability();
        if (_ollamaInitialized) {
          print('✓ Ollama connected successfully');
          // Run diagnostics in background
          _runDiagnosticsInBackground();
        } else {
          print('⚠ Ollama not available - using keyword search fallback');
        }
      } catch (e) {
        print('Ollama initialization error: $e');
        _ollamaInitialized = false;
      }

      _isInitialized = true;
      _isInitializing = false;
    }
  }

  void _runDiagnosticsInBackground() {
    // Run diagnostics without blocking initialization
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        await _ollamaService.runDiagnostics();
      } catch (e) {
        print('Background diagnostics error: $e');
      }
    });
  }

  void initSync(DatabaseService db) {
    _db = db;
    // Initialize with empty data for now
    _maintenanceData = {'procedures': []};
    _torqueSpecs = {'specs': []};
    // Load data with priority - wait for completion silently
    _initializeDataWithWait();
  }

  /// Run diagnostics on all services
  Future<Map<String, dynamic>> runServiceDiagnostics() async {
    print('\n🔍 RUNNING SERVICE DIAGNOSTICS...\n');
    return await _ollamaService.runDiagnostics();
  }

  /// Ensure data is loaded with a timeout fallback
  Future<void> _initializeDataWithWait() async {
    if (!_isInitialized) {
      try {
        await _loadOfflineData().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('Data loading timeout - using defaults');
            _maintenanceData = {'procedures': []};
            _torqueSpecs = {'specs': []};
          },
        );
        _isInitialized = true;
      } catch (e) {
        print('Error in initialization: $e');
        _isInitialized = true;
      }
    }
  }

  Future<void> _loadOfflineData() async {
    try {
      final maintenanceJson = await rootBundle.loadString(
        'assets/data/maintenance_procedures.json',
      );
      final torqueJson = await rootBundle.loadString(
        'assets/data/torque_specs.json',
      );

      _maintenanceData = jsonDecode(maintenanceJson);
      _torqueSpecs = jsonDecode(torqueJson);
      _isInitialized = true;
    } catch (e) {
      print('Error loading offline data: $e');
      // Initialize with defaults if loading fails
      _maintenanceData = {'procedures': []};
      _torqueSpecs = {'specs': []};
    }
  }

  /// Save chat message to database
  Future<void> saveChatMessage(String userMessage, String response) async {
    try {
      final message = ChatMessage(
        text: userMessage,
        isUser: true,
        response: response,
      );
      await _db.saveChatMessage(message);
      print(
          '💾 Chat message saved: User="${userMessage.substring(0, userMessage.length > 30 ? 30 : userMessage.length)}..." Response="${response.substring(0, response.length > 30 ? 30 : response.length)}..."');

      // Auto-save to history for persistent tracking
      // Detect message type based on content
      String historyType = 'search';
      if (userMessage
          .contains(RegExp(r'error|fail|wrong|issue', caseSensitive: false))) {
        historyType = 'error';
      } else if (userMessage.contains(
          RegExp(r'torque|spec|rpm|volt|amp', caseSensitive: false))) {
        historyType = 'technical';
      } else if (userMessage
          .contains(RegExp(r'procedure|step|how|do', caseSensitive: false))) {
        historyType = 'procedure';
      }

      await _db.saveHistoryEntry(userMessage, historyType);
    } catch (e) {
      print('Error saving chat message: $e');
    }
  }

  /// Retrieve chat history
  Future<List<ChatMessage>> getChatHistory() async {
    try {
      return await _db.getChatHistory();
    } catch (e) {
      print('Error retrieving chat history: $e');
      return [];
    }
  }

  /// Keyword-based intelligent search for offline AI responses
  Future<String> getResponse(String query) async {
    // Ensure data is loaded
    if (!_isInitialized || _torqueSpecs.isEmpty) {
      await _loadOfflineData();
    }

    print('💬 User query: "$query"');
    print('🤖 Ollama initialized: $_ollamaInitialized');

    // Try Ollama first if available
    if (_ollamaInitialized) {
      try {
        print('⏳ Attempting Ollama response...');
        final context = _getRelevantContext(query);
        final prompt = _ollamaService.createMaintenancePrompt(
          query,
          userMode: userMode,
          context: context,
        );

        print('📝 Generated prompt: "$prompt"');

        final response = await _ollamaService.generateResponse(
          prompt,
          timeoutSeconds: 60, // Give Ollama full time to respond
        );

        // 🔥 STEP 4: FORCE PRINT - Confirms data exists and is sent correctly
        print('🚀 FINAL RESPONSE SENT TO UI: $response');

        if (response.trim().isNotEmpty) {
          print('✅ Ollama response successful!');
          print(
              '📊 Response stats - Length: ${response.length}, First 100 chars: "${response.substring(0, response.length > 100 ? 100 : response.length)}"');
          return response;
        } else {
          print('⚠️  Ollama returned empty response');
        }
      } catch (e) {
        print('⚠️  Ollama response error: $e, falling back to keyword search');
        // Fall through to keyword search
      }
    }

    // Fallback to keyword-based search
    print('🔍 Using keyword search fallback');
    final keywordResponse = await _getKeywordBasedResponse(query);
    print('🔑 Keyword response received: ${keywordResponse.length} characters');
    return keywordResponse;
  }

  /// Get relevant context from loaded data for Ollama prompt
  String _getRelevantContext(String query) {
    final searchResults = _comprehensiveSearch(query.toLowerCase());

    if (searchResults.isNotEmpty) {
      final type = searchResults['type'] as String?;
      final data = searchResults['data'] as Map<String, dynamic>?;

      if (type == 'torque' && data != null) {
        return 'Component: ${data['component']}, Torque: ${data['value']} Nm';
      } else if (type == 'procedure' && data != null) {
        return 'Procedure: ${data['name']}, ${data['description'] ?? ''}';
      }
    }

    return 'User mode: ${userMode == 'engineer' ? 'Engineer/Technical' : 'Passenger/Simple'}';
  }

  /// Get response using keyword-based search (original implementation)
  Future<String> _getKeywordBasedResponse(String query) async {
    final lowerQuery = query.toLowerCase();

    // Try to find relevant data by searching all sources first
    final searchResults = _comprehensiveSearch(lowerQuery);

    if (searchResults.isNotEmpty) {
      return _formatResponse(searchResults, lowerQuery);
    }

    // Handle general questions
    if (lowerQuery.contains('help') || lowerQuery.contains('what can you do')) {
      return _getModeHelpResponse();
    }

    if (lowerQuery.contains('emergency') ||
        lowerQuery.contains('urgent') ||
        lowerQuery.contains('critical')) {
      return _getEmergencyResponse();
    }

    if (lowerQuery.contains('warning') ||
        lowerQuery.contains('caution') ||
        lowerQuery.contains('danger')) {
      return _searchSafety(lowerQuery);
    }

    // If no specific match found, provide helpful generic response
    return _getGenericHelpResponse();
  }

  /// Comprehensive search across all data sources
  Map<String, dynamic> _comprehensiveSearch(String query) {
    // Search torque specs
    try {
      final specs = _torqueSpecs['specs'] as List<dynamic>? ?? [];
      for (final spec in specs) {
        final component = (spec['component'] as String? ?? '').toLowerCase();
        final bolt = (spec['bolt'] as String? ?? '').toLowerCase();
        if (component.contains(query) || bolt.contains(query)) {
          return {'type': 'torque', 'data': spec};
        }
      }
    } catch (e) {
      print('Error searching torque: $e');
    }

    // Search procedures
    try {
      final procedures = _maintenanceData['procedures'] as List<dynamic>? ?? [];
      for (final proc in procedures) {
        final name = (proc['name'] as String? ?? '').toLowerCase();
        final desc = (proc['description'] as String? ?? '').toLowerCase();
        if (name.contains(query) || desc.contains(query)) {
          return {'type': 'procedure', 'data': proc};
        }
      }
    } catch (e) {
      print('Error searching procedures: $e');
    }

    // Search components
    try {
      final components = _maintenanceData['components'] as List<dynamic>? ?? [];
      for (final comp in components) {
        final name = (comp['name'] as String? ?? '').toLowerCase();
        if (name.contains(query)) {
          return {'type': 'component', 'data': comp};
        }
      }
    } catch (e) {
      print('Error searching components: $e');
    }

    return {};
  }

  /// Format response based on search result and user mode
  String _formatResponse(Map<String, dynamic> result, String query) {
    final type = result['type'] as String;
    final data = result['data'] as Map<String, dynamic>;

    if (type == 'torque') {
      return _formatTorqueResponse(data);
    } else if (type == 'procedure') {
      return _formatProcedureResponse(data);
    } else if (type == 'component') {
      return _formatComponentResponse(data);
    }

    return 'Information found but couldn\'t format response.';
  }

  /// Format torque specification response
  String _formatTorqueResponse(Map<String, dynamic> spec) {
    final component = spec['component'] ?? 'Unknown';
    final bolt = spec['bolt'] ?? 'Unknown';
    final value = spec['value'] ?? 'N/A';
    final unit = spec['unit'] ?? '';
    final range = spec['range'] ?? 'N/A';
    final safety = spec['safety'] ?? 'Standard safety procedures apply';
    final ammRef = spec['ammRef'] ?? 'Support document available';
    final material = spec['material'] ?? 'Alloy';

    if (userMode == 'passenger') {
      return '''🔧 **$component** - Fastening Information

**Specification:** $bolt ($material)
**Recommended Tightness:** $value $unit
**Safe Range:** $range

**Why this matters:** This ensures the component is secured properly without being over-tightened, maintaining aircraft structural integrity.

⚠️ **Safety Note:** Only qualified personnel should perform this. $safety

📋 **Reference:** $ammRef''';
    }

    return '''**TORQUE SPECIFICATION - Per AMM Standards**

Component: $component
Bolt/Fastener: $bolt
Material: $material
Torque Value: $value $unit
Safe Range: $range

Reference: $ammRef (Aircraft Maintenance Manual)

⚠️ **Critical Safety Requirements:**
• Use only calibrated torque wrench (per TEM)
• Check torque again after 10 flight hours
• If torque deviates by ±5%, investigate fastener condition
• Never exceed upper range limit

$safety

**Tools Required:** Calibrated torque wrench (per TEM 05-00-00), Socket set''';
  }

  /// Format procedure response
  String _formatProcedureResponse(Map<String, dynamic> proc) {
    final name = proc['name'] ?? 'Unknown Procedure';
    final description = proc['description'] ?? 'No description';
    final aircraftType = proc['aircraftType'] ?? 'Unknown';
    final estimatedTime = proc['estimatedTime'] ?? 'N/A';
    final steps = proc['steps'] as List<dynamic>? ?? [];

    if (userMode == 'passenger') {
      return '''📋 **$name**

**Aircraft:** $aircraftType
**Time Required:** $estimatedTime
**Overview:** $description

**Key Steps:**
${steps.take(3).toList().asMap().entries.map((e) => '${e.key + 1}. ${(e.value as Map)['instruction'] ?? 'Step'}').join('\n')}

${steps.length > 3 ? '\n... and ${steps.length - 3} more steps' : ''}

**⚠️ Always contact an engineer if you're unsure about any step!**''';
    }

    var response = '''**MAINTENANCE PROCEDURE: $name**

Aircraft: $aircraftType
Description: $description
Estimated Time: $estimatedTime

**STEPS:**
''';
    for (var i = 0; i < (steps.length < 5 ? steps.length : 5); i++) {
      final step = steps[i] as Map<String, dynamic>;
      response += '\n${i + 1}. ${step['instruction']}';
      if (step['toolsRequired'] != null) {
        response += '\n   Tools: ${step['toolsRequired']}';
      }
    }

    if (steps.length > 5) {
      response += '\n\n... and ${steps.length - 5} more steps';
    }

    return response;
  }

  /// Format component response
  String _formatComponentResponse(Map<String, dynamic> comp) {
    final name = comp['name'] ?? 'Unknown';
    final type = comp['type'] ?? 'Unknown';
    final description = comp['description'] ?? 'No description';
    final location = comp['location'] ?? 'Unknown';
    final maintenance = comp['maintenance'] ?? 'Regular inspection recommended';

    if (userMode == 'passenger') {
      return '''🛩️ **$name**

**What it is:** $type
**Location:** $location

**Description:**
$description

**Maintenance:**
$maintenance

**If something seems wrong:** Contact cabin crew or ground maintenance immediately.''';
    }

    return '''**COMPONENT INFORMATION: $name**

Type: $type
Description: $description
Location: $location
Maintenance: $maintenance''';
  }

  /// Mode-specific help response
  String _getModeHelpResponse() {
    if (userMode == 'passenger') {
      return '''
👋 **AeroAssist - Passenger Mode**

I can help you understand aircraft systems and basic troubleshooting:

🛩️ **AIRCRAFT SYSTEMS**
• Learn how engines, hydraulics, brakes work
• Understand landing gear and other systems
• Get component information in simple terms

⚠️ **SAFETY & EMERGENCY**
• Understand safety features
• Know what to do in emergencies
• Learn proper procedures

🔊 **PROBLEM SOLVING**
• Identify what might be wrong
• Understand aircraft sounds
• Get basic troubleshooting help

❓ **GENERAL QUESTIONS**
• Ask anything about the aircraft
• Get easy-to-understand answers
• Learn aircraft operations

**Remember:** For actual repairs, always contact qualified engineers.

**What would you like to know?**
- "How does the engine work?"
- "What is landing gear?"
- "Is that sound normal?"
- "What are safety features?"''';
    }

    return '''
🤖 **AeroAssist AI Assistant - Engineer Mode**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**TECHNICAL SUPPORT CAPABILITIES:**

⚙️ **TORQUE SPECIFICATIONS**
• Exact fastening torque values
• Torque ranges and procedures
• Safety specifications

📋 **MAINTENANCE PROCEDURES**
• Complete step-by-step procedures
• Component replacement guides
• Inspection checklists

🔧 **COMPONENT INFORMATION**
• Technical specifications
• Assembly locations
• Material specifications

⚠️ **SAFETY PROTOCOLS**
• Critical safety warnings
• Hazard identification
• Compliance requirements

🛠️ **TOOLS & EQUIPMENT**
• Required tools per task
• Equipment specifications
• Special tools needed

📊 **DIAGNOSTICS**
• Troubleshooting procedures
• System diagnostics
• Issue resolution

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All data is **offline** and **instantly available**
✅ Up-to-date maintenance information
✅ Complete technical specifications
✅ Safety-critical information

**Ask me about specific:**
→ Torque specs, procedures, components, tools, safety, diagnostics

**What task do you need help with?**''';
  }

  /// Emergency response
  String _getEmergencyResponse() {
    if (userMode == 'passenger') {
      return '''
🚨 **EMERGENCY PROCEDURE**

If there is an emergency:
1. **Alert the cabin crew immediately** - Press the call button
2. **Follow crew instructions** - They are trained for this
3. **Stay calm** - The aircraft is safe
4. **Do NOT attempt repairs** - Leave it to professionals

The aircraft has multiple safety systems. You are in good hands.''';
    }

    return '''
🚨 **CRITICAL INCIDENT PROTOCOL**

1. Assess the situation
2. Check aircraft systems for failures
3. Consult emergency procedures  
4. Contact air traffic control if needed
5. Document all actions

Refer to emergency checklist in aircraft manual.''';
  }

  /// Generic help response when no match found
  String _getGenericHelpResponse() {
    if (userMode == 'passenger') {
      return '''
😊 I didn't find exactly what you asked about, but I'm here to help!

**Try asking about:**

🛩️ **Aircraft Systems**
• How do engines work?
• What is the landing gear?
• How does hydraulics work?
• What are the braking systems?

🔊 **Aircraft Sounds & Issues**
• What is that noise?
• What if something seems wrong?
• How do I report a problem?

📋 **General Information**
• Aircraft specifications
• Safety features explained
• Maintenance schedules
• Emergency procedures

**Example questions you can ask:**
- "Tell me about landing gear"
- "Are there safety issues I should know?"
- "What systems are in this aircraft?"
- "Explain the hydraulic system"

What would you like to learn?''';
    }

    return '''
🔍 **I didn't find an exact match, but here's what I can help with:**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️ **TORQUE SPECIFICATIONS**
Exact fastening requirements for all components
→ Try: "torque for wing attachment", "bolt tightness"

📋 **MAINTENANCE PROCEDURES**
Step-by-step maintenance guides and checklists
→ Try: "engine oil change", "brake maintenance"

🔧 **COMPONENTS & SYSTEMS**
Detailed technical specifications and locations
→ Try: "hydraulic system", "landing gear", "fuel system"

⚠️ **SAFETY PROTOCOLS**
Critical warnings, cautions, and safety procedures
→ Try: "safety warnings", "emergency procedures"

🛠️ **TOOLS & EQUIPMENT**
What tools you need for maintenance tasks
→ Try: "tools needed", "equipment required"

📊 **DIAGNOSTICS & TROUBLESHOOTING**
How to identify and resolve issues
→ Try: "pressure issue", "system diagnostic"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**💡 Try rephrasing with specific keywords or ask about:**
- Aircraft systems (engines, brakes, hydraulics, electrical)
- Component names (fastener, bolt, connector, plug)
- Actions (inspect, replace, check, tighten, drain)
- Numbers/specs (torque values, pressures, clearances)

**📌 Tips for better results:**
✓ Be specific about components
✓ Include action words (how to, check, repair)
✓ Mention aircraft systems
✓ Ask about tools or procedures

What specific maintenance task or system can I help with?''';
  }

  String _searchTorqueSpec(String query) {
    try {
      // Ensure data is loaded
      if (_torqueSpecs.isEmpty) {
        return '''
**TORQUE SPECIFICATIONS - Per Aircraft Maintenance Manual (AMM)**

📋 **Available Common Reference Torques:**
• Wing attachment fasteners: 150-200 Nm (AMM 57-00-00)
• Engine mounts: 80-120 Nm (AMM 70-00-00)
• Fuselage panels: 25-35 Nm (AMM 56-00-00)
• Door hinges: 40-60 Nm (AMM 61-00-00)
• Landing gear: 180-240 Nm (AMM 32-12-00)

🔧 **Tools Required (per TEM):**
- Digital/click torque wrench (±5% accuracy)
- Calibration block (per TEM 05-00-00)
- Socket set with extension bars

⚠️ **Critical:** Always verify torque wrench calibration before use per TSM guidelines.

Ask for specific component torque value like:
→ "What is torque for landing gear?"
→ "Wing attachment fastener torque"
→ "Engine mount bolt tightness"
''';
      }

      final specs = _torqueSpecs['specs'] as List<dynamic>? ?? [];

      // Clean query by removing common words
      final cleanedQuery = query
          .replaceAll('torque', '')
          .replaceAll('what is', '')
          .replaceAll('what\'s', '')
          .replaceAll('value', '')
          .replaceAll('for', '')
          .replaceAll('?', '')
          .trim();

      // Find matching specs - be lenient with matching
      var matches = <dynamic>[];
      if (cleanedQuery.isNotEmpty) {
        matches = specs.where((spec) {
          final component = (spec['component'] as String? ?? '').toLowerCase();
          final bolt = (spec['bolt'] as String? ?? '').toLowerCase();
          return component.contains(cleanedQuery) ||
              bolt.contains(cleanedQuery) ||
              cleanedQuery.contains('wing') && component.contains('wing') ||
              cleanedQuery.contains('attachment') &&
                  component.contains('attachment');
        }).toList();
      }

      // If no specific match, return all specs with AMM references
      if (matches.isEmpty) {
        var response = '''
**TORQUE SPECIFICATIONS - Quick Reference**

📋 **Per Aircraft Maintenance Manual (AMM):**\n''';
        for (final spec in specs.take(8)) {
          final ammSection = spec['ammRef'] ?? 'Standard reference';
          response +=
              '\n• ${spec['component']}: ${spec['value']} ${spec['unit']} ($ammSection)';
        }
        response +=
            '\n\n🔍 **For accurate values, ask for specific component:**\n• "Landing gear torque"\n• "Wing attachment torque"\n• "Brake assembly torque"';
        return response;
      }

      final spec = matches.first;
      final ammRef = spec['ammRef'] ?? 'AMM Support Document';
      final material = spec['material'] ?? 'Alloy Steel';

      return '''**TORQUE SPECIFICATION - Per AMM Standards**

✈️ Component: ${spec['component']}
🔩 Bolt/Fastener: ${spec['bolt']}
📊 Material: $material
⚡ Torque Value: ${spec['value']} ${spec['unit']}
📈 Safe Range: ${spec['range']}

🔧 **Procedure (per TEM):**
${spec['procedure'] ?? '1. Use calibrated torque wrench\n2. Apply torque gradually\n3. Verify range after installation\n4. Re-torque after first flight'}

📋 **Reference Documents:**
• $ammRef
• TEM 05-00-00 (Tools & Equipment)
• TSM (Troubleshooting Manual)

⚠️ **CRITICAL SAFETY NOTES:**
• Never use an uncalibrated wrench
• Verify range ±2.5 Nm from specified value  
• Re-check torque after 10 flight hour cycle
• Document in maintenance log per AMM 05-00-00

**Compliance:** FAA Part 43, AC 43-13 required''';
    } catch (e) {
      return 'Error searching torque specs: $e. Consult AMM directly.';
    }
  }

  String _searchProcedure(String query) {
    try {
      final procedures = _maintenanceData['procedures'] as List<dynamic>? ?? [];

      final matches = procedures.where((proc) {
        final name = (proc['name'] as String? ?? '').toLowerCase();
        final desc = (proc['description'] as String? ?? '').toLowerCase();
        return name.contains(query) || desc.contains(query);
      }).toList();

      if (matches.isNotEmpty) {
        final proc = matches.first;
        final steps = proc['steps'] as List<dynamic>? ?? [];
        final ammChapter = proc['ammChapter'] ?? '73-00-00';
        final estimatedTime = proc['estimatedTime'] ?? '2 hours';
        final safetyWarning =
            proc['safetyWarning'] ?? 'Standard precautions apply';

        var response = '''**📋 MAINTENANCE PROCEDURE - Per AMM**

**Procedure:** ${proc['name']}
**Aircraft:** ${proc['aircraftType'] ?? 'General'}
**AMM Section:** $ammChapter (Aircraft Maintenance Manual)
**Estimated Time:** $estimatedTime
**Tools Required:** ${proc['toolsRequired'] ?? 'Standard tool kit'}

**Description:**
${proc['description']}

⚠️ **CRITICAL SAFETY WARNING:**
$safetyWarning

**PROCEDURE STEPS:**
''';
        for (var i = 0; i < (steps.length < 8 ? steps.length : 8); i++) {
          final step = steps[i] as Map<String, dynamic>;
          response +=
              '\n**Step ${i + 1}:** ${step['instruction'] ?? 'No instruction'}';
          if (step['toolsRequired'] != null) {
            response += '\n   🔧 Tools: ${step['toolsRequired']}';
          }
          if (step['expectedResult'] != null) {
            response += '\n   ✓ Expected: ${step['expectedResult']}';
          }
        }

        if (steps.length > 8) {
          response +=
              '\n\n**... and ${steps.length - 8} more steps in full procedure**';
        }

        response += '''\n\n📚 **Reference Documents:**
• AMM Chapter $ammChapter (Pages available in Documentation Screen)
• TSM (Troubleshooting Manual)
• CMM (Component Maintenance Manual)
• SRM (Structural Repair Manual)

🔓 **View Full Procedure:**
→ Open Documentation Screen
→ Search for "$ammChapter"
→ View highlighted PDF pages with exact line numbers

✅ **Compliance:** FAA AC 43-13, Aircraft Maintenance Manual required''';

        return response;
      }

      return '''
**AVAILABLE MAINTENANCE PROCEDURES - Per AMM**

📋 **Standard Maintenance Tasks:**
• **Engine Inspection** (AMM 73-00-00)
• **Fuselage Panel Replacement** (AMM 56-00-00)
• **Brake System Maintenance** (AMM 32-00-00)
• **Hydraulic System Check** (AMM 29-00-00)
• **Landing Gear Service** (AMM 32-12-00)
• **General Systems Inspection** (AMM 51-00-00)

🔍 **To get full procedure details, ask about:**
→ "Engine oil change procedure"
→ "Brake maintenance steps"
→ "Landing gear service"

🔓 **For complete procedures with PDF references:**
→ Open Documentation Screen
→ Search for specific procedures
→ View exact pages and highlighted sections

📞 **For emergency issues, consult TSM (Troubleshooting Manual)**
''';
    } catch (e) {
      return 'Error searching procedures. Please consult AMM directly or try again.';
    }
  }

  String _searchComponent(String query) {
    try {
      final components = _maintenanceData['components'] as List<dynamic>? ?? [];

      final matches = components.where((comp) {
        final name = (comp['name'] as String? ?? '').toLowerCase();
        final type = (comp['type'] as String? ?? '').toLowerCase();
        return name.contains(query) || type.contains(query);
      }).toList();

      if (matches.isNotEmpty) {
        final comp = matches.first;
        return '''**COMPONENT INFORMATION: ${comp['name']}**

Type: ${comp['type']}
Description: ${comp['description']}
Location: ${comp['location']}
Material: ${comp['material']}
Maintenance: ${comp['maintenance']}''';
      }

      return 'Component information not found. Please ask about specific aircraft components.';
    } catch (e) {
      return 'Error searching components. Please try again.';
    }
  }

  String _searchSafety(String query) {
    try {
      final safety = _maintenanceData['safety'] as List<dynamic>? ?? [];

      final matches = safety.where((item) {
        final warning = (item['warning'] as String? ?? '').toLowerCase();
        return warning.contains(query);
      }).toList();

      if (matches.isNotEmpty) {
        final item = matches.first;
        return '''⚠️ **SAFETY WARNING**

${item['warning']}

Procedure: ${item['procedure']}
Consequence: ${item['consequence']}
Prevention: ${item['prevention']}''';
      }

      return '⚠️ Always follow safety protocols. Consult manual for detailed safety warnings.';
    } catch (e) {
      return 'Error searching safety information. Please try again.';
    }
  }

  String _searchTools(String query) {
    try {
      final tools = _maintenanceData['tools'] as List<dynamic>? ?? [];

      final matches = tools.where((tool) {
        final name = (tool['name'] as String? ?? '').toLowerCase();
        return name.contains(query);
      }).toList();

      if (matches.isNotEmpty) {
        var response = '**REQUIRED TOOLS:**\n';
        for (final tool in matches) {
          response += '\n• ${tool['name']}: ${tool['description']}';
        }
        return response;
      }

      return 'Tools information not found. Ask about specific tools needed for maintenance.';
    } catch (e) {
      return 'Error searching tools. Please try again.';
    }
  }

  String _searchDiagnostics(String query) {
    try {
      final diagnostics =
          _maintenanceData['diagnostics'] as List<dynamic>? ?? [];

      final matches = diagnostics.where((diag) {
        final symptom = (diag['symptom'] as String? ?? '').toLowerCase();
        final cause = (diag['cause'] as String? ?? '').toLowerCase();
        return symptom.contains(query) || cause.contains(query);
      }).toList();

      if (matches.isNotEmpty) {
        final diag = matches.first;
        return '''**DIAGNOSTIC RESULT**

Symptom: ${diag['symptom']}
Likely Cause: ${diag['cause']}
Solution: ${diag['solution']}
Steps:
${(diag['steps'] as List<dynamic>? ?? []).asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}''';
      }

      return 'Diagnostic information not found. Describe the issue in detail.';
    } catch (e) {
      return 'Error searching diagnostics. Please try again.';
    }
  }

  /// Get available topics
  List<String> getAvailableTopics() => [
        'Torque Specifications',
        'Maintenance Procedures',
        'Component Information',
        'Safety Warnings',
        'Tools & Equipment',
        'Diagnostics',
      ];
}
