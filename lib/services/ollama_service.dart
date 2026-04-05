import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'platform_info.dart';

/// Service for interacting with Ollama local LLM
/// Requires Ollama to be running on localhost:11434
class OllamaService {
  // Allows override via: --dart-define=OLLAMA_BASE_URL=http://<ip>:11434
  static const String _envBaseUrl =
      String.fromEnvironment('OLLAMA_BASE_URL');

  // Base URL varies by platform (Android emulator cannot use 127.0.0.1)
  late String _baseUrl;
  late final List<String> _baseUrlCandidates;
  static const String _generateEndpoint = '/api/generate';
  static const Duration _timeout = Duration(seconds: 60);

  bool _isAvailable = false;
  String _selectedModel = 'gemma3:1b'; // Default to fastest model
  List<String> _availableModels = [];

  bool get isAvailable => _isAvailable;
  String get selectedModel => _selectedModel;
  List<String> get availableModels => _availableModels;

  OllamaService() {
    _baseUrlCandidates = _resolveBaseUrlCandidates();
    _baseUrl = _baseUrlCandidates.first;
  }

  List<String> _resolveBaseUrlCandidates() {
    if (_envBaseUrl.isNotEmpty) {
      return [_normalizeBaseUrl(_envBaseUrl)];
    }

    final candidates = <String>[];

    if (kIsWeb) {
      candidates.addAll(['http://127.0.0.1:11434', 'http://localhost:11434']);

      final host = Uri.base.host;
      if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
        candidates.add('http://$host:11434');
      }

      return _dedupeUrls(candidates);
    }

    if (isAndroid) {
      // Android emulator maps host machine to 10.0.2.2
      candidates.add('http://10.0.2.2:11434');
    }

    // iOS simulator, Windows, macOS, Linux
    candidates.addAll(['http://127.0.0.1:11434', 'http://localhost:11434']);
    return _dedupeUrls(candidates);
  }

  List<String> _dedupeUrls(List<String> urls) {
    final seen = <String>{};
    final result = <String>[];
    for (final url in urls) {
      final normalized = _normalizeBaseUrl(url);
      if (seen.add(normalized)) {
        result.add(normalized);
      }
    }
    return result.isNotEmpty ? result : ['http://127.0.0.1:11434'];
  }

  String _normalizeBaseUrl(String input) {
    var value = input.trim();
    if (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  /// Check if Ollama is running and available
  Future<bool> checkAvailability() async {
    for (final candidate in _baseUrlCandidates) {
      try {
        final response = await http
            .get(
              Uri.parse('$candidate/api/tags'),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final models = data['models'] as List<dynamic>? ?? [];
          _availableModels = models
              .map((m) => (m as Map<String, dynamic>)['name'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList();

          _isAvailable = _availableModels.isNotEmpty;

          if (_isAvailable) {
            _baseUrl = candidate;
            // Prefer fastest models: gemma3:1b > orca-mini > others
            if (_availableModels.contains('gemma3:1b')) {
              _selectedModel = 'gemma3:1b';
              print('Using fastest model: gemma3:1b');
            } else if (_availableModels.contains('orca-mini:latest')) {
              _selectedModel = 'orca-mini:latest';
              print('Using fast model: orca-mini:latest');
            } else if (!_availableModels.contains(_selectedModel)) {
              _selectedModel = _availableModels.first;
              print('Using available model: $_selectedModel');
            }
          }

          print('Ollama available: $_isAvailable, Models: $_availableModels');
          return _isAvailable;
        }
      } catch (e) {
        print('Ollama check failed for $candidate: $e');
        if (kIsWeb) {
          print(
              'Web hint: add OLLAMA_ORIGINS to include ${Uri.base.origin} and restart Ollama.');
        }
        // Try next candidate
      }
    }

    print('Ollama not available on any candidate URL: $_baseUrlCandidates');
    _isAvailable = false;
    return false;
  }


  /// Generate response from Ollama
  Future<String> generateResponse(
    String prompt, {
    String? model,
    int? timeoutSeconds,
  }) async {
    if (!_isAvailable) {
      throw Exception('Ollama service is not available');
    }

    final useModel = model ?? _selectedModel;
    final timeout = Duration(
        seconds: timeoutSeconds ?? 60); // Wait up to 60 seconds for response

    try {
      final payload = {
        'model': useModel,
        'prompt': prompt,
        'stream': false,
        'temperature': 0.7,
        'top_p': 0.9,
        // Limit output length to avoid very long generations and timeouts.
        'options': {'num_predict': 256},
        'keep_alive': '5m', // Keep model loaded for 5 minutes
      };

      print('🔵 Sending to Ollama: URL=$_baseUrl$_generateEndpoint');
      print('📤 Request payload size: ${jsonEncode(payload).length} bytes');

      final stopwatch = Stopwatch()..start();
      final response = await http
          .post(
            Uri.parse('$_baseUrl$_generateEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(timeout);
      stopwatch.stop();

      print('⏱️  Response received in: ${stopwatch.elapsedMilliseconds}ms');
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText = data['response'] as String? ?? '';
        // 🔥 STEP 5: CHECK RAW RESPONSE
        print('🔥 RAW OLLAMA RESPONSE: ${response.body}');
        print('✅ Ollama response extracted: ${generatedText.length} chars');
        return generatedText.trim();
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print(
            '📝 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        throw Exception('Ollama error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Failed to generate response: $e');
    }
  }

  /// Stream response from Ollama (for real-time response display)
  Stream<String> streamResponse(
    String prompt, {
    String? model,
  }) async* {
    if (!_isAvailable) {
      throw Exception('Ollama service is not available');
    }

    final useModel = model ?? _selectedModel;

    try {
      final payload = {
        'model': useModel,
        'prompt': prompt,
        'stream': true,
        'temperature': 0.7,
      };

      final request = http.StreamedRequest(
        'POST',
        Uri.parse('$_baseUrl$_generateEndpoint'),
      );

      request.headers.addAll({'Content-Type': 'application/json'});
      request.sink.add(utf8.encode(jsonEncode(payload)));
      await request.sink.close();

      final response = await request.send().timeout(_timeout);

      if (response.statusCode == 200) {
        await for (final chunk in response.stream.transform(utf8.decoder)) {
          final lines = chunk.split('\n');
          for (final line in lines) {
            if (line.isEmpty) continue;
            try {
              final data = jsonDecode(line);
              final responseChunk = data['response'] as String? ?? '';
              if (responseChunk.isNotEmpty) {
                yield responseChunk;
              }
              if (data['done'] == true) {
                break;
              }
            } catch (e) {
              // Skip malformed JSON lines
              print('JSON parse error: $e');
            }
          }
        }
      } else {
        throw Exception('Ollama stream error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to stream response: $e');
    }
  }

  /// Set the model to use
  void setModel(String model) {
    if (_availableModels.contains(model)) {
      _selectedModel = model;
    }
  }

  /// Get list of available models
  Future<List<String>> listModels() async {
    await checkAvailability();
    return _availableModels;
  }

  /// Create maintenance-specific prompt
  String createMaintenancePrompt(
    String userQuery, {
    required String userMode,
    required String context,
  }) {
    final hasSpecificContext =
        context.startsWith('Component:') || context.startsWith('Procedure:');

    if (!hasSpecificContext) {
      return '''You are AeroAssist, an aircraft maintenance assistant.

Mode: $userMode
${userMode == 'passenger' ? 'Explain in simple, non-technical language.' : 'Use technical terms, be concise, and ask for the specific component/system if needed.'}

Question:
$userQuery

Answer briefly and stay within aircraft maintenance context.''';
    }

    return '''You are AeroAssist AI, an Aircraft Maintenance Engineer assistant.

Your role: Provide accurate, aircraft maintenance-specific information.

Context Information:
$context

User Mode: $userMode
${userMode == 'passenger' ? 'Instructions: Explain in simple, non-technical language for a passenger' : 'Instructions: Use technical terms, include specific values, references, and procedures per AMM standards'}

User Question:
$userQuery

Response Guidelines:
- Answer ONLY based on aircraft maintenance context
- Be specific and accurate (not general knowledge)
- If asking about components, include type, location, and maintenance info
- If about torque/fasteners, include bolt type, torque value in Nm, and safe range if available
- If about procedures, provide step-by-step instructions
- Keep response clear, structured, and professional
- DO NOT give generic or unrelated answers
- Reference AMM (Aircraft Maintenance Manual) standards when applicable
- For warnings, emphasize critical safety requirements

Provide your answer now:''';
  }

  /// Comprehensive diagnostic test for Ollama connection
  Future<Map<String, dynamic>> runDiagnostics() async {
    final diagnostics = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'baseUrl': _baseUrl,
      'tests': <String, dynamic>{},
    };

    try {
      // Test 1: Network connectivity
      print('\n🔧 OLLAMA DIAGNOSTICS - Starting tests...\n');

      print('📡 Test 1: Basic connectivity to $_baseUrl');
      try {
        final pingResponse = await http
            .get(Uri.parse('$_baseUrl/api/tags'))
            .timeout(const Duration(seconds: 5));

        diagnostics['tests']['connectivity'] = {
          'status': pingResponse.statusCode == 200 ? 'PASS' : 'FAIL',
          'statusCode': pingResponse.statusCode,
          'responseTime': 'completed',
        };
        print('   ✅ Connected - Status: ${pingResponse.statusCode}');
      } catch (e) {
        diagnostics['tests']['connectivity'] = {
          'status': 'FAIL',
          'error': '$e',
        };
        print('   ❌ Failed: $e');
      }

      // Test 2: Get available models
      print('\n📋 Test 2: Fetching available models');
      try {
        final response = await http
            .get(Uri.parse('$_baseUrl/api/tags'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final models = data['models'] as List<dynamic>? ?? [];
          final modelNames = models
              .map((m) => (m as Map<String, dynamic>)['name'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList();

          diagnostics['tests']['models'] = {
            'status': modelNames.isNotEmpty ? 'PASS' : 'FAIL',
            'count': modelNames.length,
            'models': modelNames,
          };
          print('   ✅ Found ${modelNames.length} models: $modelNames');
        } else {
          diagnostics['tests']['models'] = {
            'status': 'FAIL',
            'statusCode': response.statusCode,
          };
          print('   ❌ Status: ${response.statusCode}');
        }
      } catch (e) {
        diagnostics['tests']['models'] = {
          'status': 'FAIL',
          'error': '$e',
        };
        print('   ❌ Error: $e');
      }

      // Test 3: Test actual generation (short prompt, 10 sec timeout)
      print('\n🤖 Test 3: Testing response generation (10 sec timeout)');
      print('   Model: $_selectedModel');
      try {
        final testPayload = {
          'model': _selectedModel,
          'prompt': 'Say "OK" only.',
          'stream': false,
          'temperature': 0.1,
        };

        final response = await http
            .post(
              Uri.parse('$_baseUrl$_generateEndpoint'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(testPayload),
            )
            .timeout(const Duration(seconds: 20));

        diagnostics['tests']['generation'] = {
          'status': response.statusCode == 200 ? 'PASS' : 'FAIL',
          'statusCode': response.statusCode,
          'responseLength': response.body.length,
        };
        print(
            '   ✅ Response received - Status: ${response.statusCode}, Size: ${response.body.length} bytes');
      } catch (e) {
        diagnostics['tests']['generation'] = {
          'status': 'FAIL',
          'error': '$e',
        };
        print('   ❌ Generation failed: $e');
      }

      // Summary
      print('\n📊 DIAGNOSTIC SUMMARY:');
      diagnostics['tests'].forEach((key, value) {
        final status = value is Map ? value['status'] : 'UNKNOWN';
        print('   $key: $status');
      });
      print('\n');
    } catch (e) {
      diagnostics['error'] = '$e';
      print('❌ Diagnostics failed: $e');
    }

    return diagnostics;
  }
}
