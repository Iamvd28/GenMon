import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Use your computer's IP address instead of localhost for mobile devices
  // You can find your IP by running 'ipconfig' in Windows
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // For Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // For web
  // static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api'; // For physical device
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // Leaderboard API calls
  Future<Map<String, dynamic>> getOverallLeaderboard({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/overall?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load overall leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getContestLeaderboard(String contestId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/contest/$contestId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load contest leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getCategoryLeaderboard(String category, {int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/category/$category?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load category leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Contest API calls
  Future<List<Map<String, dynamic>>> getContests({
    String? status,
    String? type,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;

      final uri = Uri.parse('$baseUrl/contests').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load contests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getContest(String contestId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/contests/$contestId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load contest: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> createContest(Map<String, dynamic> contestData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/contests'),
        headers: _headers,
        body: json.encode(contestData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create contest: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> joinContest(String contestId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/contests/$contestId/join'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to join contest: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Submission API calls
  Future<Map<String, dynamic>> submitCode(Map<String, dynamic> submissionData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submissions'),
        headers: _headers,
        body: json.encode(submissionData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getContestSubmissions(String contestId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/contests/$contestId/submissions'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load submissions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // User API calls
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Authentication API calls
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          setAuthToken(data['token']);
        }
        return data;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          setAuthToken(data['token']);
        }
        return data;
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
} 