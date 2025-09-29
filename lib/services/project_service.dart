import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';
import 'auth_service.dart';

class ProjectService {
  static const String _baseUrl = 'http://192.168.29.36:8080';
  static const String _projectsEndpoint = '/api/projects';
  
  static ProjectService? _instance;
  static ProjectService get instance => _instance ??= ProjectService._();
  
  ProjectService._();

  Future<List<Project>> getAllProjects() async {
    try {
      final headers = await AuthService.instance.getAuthHeaders();
      print('🔍 Fetching projects from: $_baseUrl$_projectsEndpoint');
      print('🔑 Auth headers: $headers');
      print('🎫 Full token: ${headers['Authorization']}');
      
      final response = await http.get(
        Uri.parse('$_baseUrl$_projectsEndpoint'),
        headers: headers,
      );
      
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response headers: ${response.headers}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('📊 Response data type: ${responseData.runtimeType}');
        print('📊 Response data keys: ${responseData is Map ? responseData.keys.toList() : 'Not a Map'}');
        
        // Handle the response format: {"projects": [...]}
        List<dynamic> projectsJson;
        if (responseData is Map<String, dynamic> && responseData.containsKey('projects')) {
          projectsJson = responseData['projects'] as List<dynamic>;
        } else if (responseData is List) {
          projectsJson = responseData;
        } else {
          print('❌ Unexpected response format');
          return [];
        }
        
        print('📊 Found ${projectsJson.length} projects');
        final projects = projectsJson.map((json) => Project.fromJson(json)).toList();
        print('✅ Successfully parsed ${projects.length} projects');
        return projects;
      } else {
        print('❌ Failed to load projects: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('💥 Error loading projects: $e');
      return [];
    }
  }

  Future<Project?> createProject(Project project) async {
    try {
      print('🚀 Creating project: ${project.projectName}');
      print('📤 Sending to: $_baseUrl$_projectsEndpoint');
      print('📋 Project data: ${project.toJson()}');
      
      final headers = await AuthService.instance.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl$_projectsEndpoint'),
        headers: headers,
        body: jsonEncode(project.toJson()),
      );
      
      print('📡 Create response status: ${response.statusCode}');
      print('📄 Create response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final createdProject = Project.fromJson(jsonDecode(response.body));
        print('✅ Project created successfully: ${createdProject.projectName}');
        return createdProject;
      } else {
        print('❌ Failed to create project: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Error creating project: $e');
      return null;
    }
  }

  Future<Project?> getProjectById(int projectId) async {
    try {
      final headers = await AuthService.instance.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_projectsEndpoint/$projectId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load project: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading project: $e');
      return null;
    }
  }

  Future<bool> updateProject(int projectId, Project project) async {
    try {
      final headers = await AuthService.instance.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl$_projectsEndpoint/$projectId'),
        headers: headers,
        body: jsonEncode(project.toJson()),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating project: $e');
      return false;
    }
  }

  // Test method to debug API calls
  Future<void> testApiCall() async {
    try {
      print('🧪 Testing API call...');
      
      // Test 1: Without any headers
      print('\n📋 Test 1: No headers');
      final response1 = await http.get(Uri.parse('$_baseUrl$_projectsEndpoint'));
      print('Status: ${response1.statusCode}');
      print('Body: ${response1.body}');
      
      // Test 2: With just Content-Type
      print('\n📋 Test 2: Content-Type only');
      final response2 = await http.get(
        Uri.parse('$_baseUrl$_projectsEndpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Status: ${response2.statusCode}');
      print('Body: ${response2.body}');
      
      // Test 3: With full auth headers
      print('\n📋 Test 3: Full auth headers');
      final headers = await AuthService.instance.getAuthHeaders();
      print('Headers: $headers');
      final response3 = await http.get(
        Uri.parse('$_baseUrl$_projectsEndpoint'),
        headers: headers,
      );
      print('Status: ${response3.statusCode}');
      print('Body: ${response3.body}');
      
    } catch (e) {
      print('💥 Test error: $e');
    }
  }
}
