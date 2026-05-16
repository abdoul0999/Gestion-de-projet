import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user.dart';
import '../models/cv_analysis.dart';
import '../models/job_match.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    String detail = 'Request failed (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      detail = body['detail'] ?? detail;
    } catch (_) {}
    throw ApiException(detail, statusCode: response.statusCode);
  }

  Future<List<dynamic>> _handleListResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    }
    throw ApiException('Request failed (${response.statusCode})', statusCode: response.statusCode);
  }

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? educationLevel,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'education_level': educationLevel,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<User> setupProfile({
    required String targetJob,
    required String contractType,
    required String region,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/auth/profile'),
      headers: _headers,
      body: jsonEncode({
        'target_job': targetJob,
        'contract_type': contractType,
        'region': region,
      }),
    );
    return User.fromJson(await _handleResponse(response));
  }

  Future<User> getMe() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/auth/me'),
      headers: _headers,
    );
    return User.fromJson(await _handleResponse(response));
  }

  // ── CV Analysis ───────────────────────────────────────────────────────────

  Future<CVAnalysis> analyzeCV({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}/cv/analyze'),
    );
    request.headers['Authorization'] = 'Bearer $_token';
    request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return CVAnalysis.fromJson(await _handleResponse(response));
  }

  Future<List<CVAnalysis>> getCVAnalyses() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/cv/analyses'),
      headers: _headers,
    );
    final list = await _handleListResponse(response);
    return list.map((e) => CVAnalysis.fromJson(e)).toList();
  }

  // ── Job Matching ──────────────────────────────────────────────────────────

  Future<JobMatch> analyzeMatch({
    required String jobTitle,
    String? company,
    required String jobDescription,
    int? cvAnalysisId,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/matching/analyze'),
      headers: _headers,
      body: jsonEncode({
        'job_title': jobTitle,
        'company': company ?? '',
        'job_description': jobDescription,
        'cv_analysis_id': cvAnalysisId,
      }),
    );
    return JobMatch.fromJson(await _handleResponse(response));
  }

  Future<List<JobMatch>> getMatchHistory() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/matching/history'),
      headers: _headers,
    );
    final list = await _handleListResponse(response);
    return list.map((e) => JobMatch.fromJson(e)).toList();
  }

  // ── Chatbot ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/chatbot/message'),
      headers: _headers,
      body: jsonEncode({'message': message}),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getChatHistory() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/chatbot/history'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  Future<void> clearChatHistory() async {
    await http.delete(
      Uri.parse('${AppConstants.baseUrl}/chatbot/history'),
      headers: _headers,
    );
  }
}
