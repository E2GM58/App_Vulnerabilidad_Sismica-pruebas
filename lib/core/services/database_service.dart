import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../config/database_config.dart';
import '../../data/models/database_response.dart';

class DatabaseService {
  static String? _authToken;

  // 🎯 Usar la URL dinámica
  static String get _baseUrl => DatabaseConfig.getServerUrl();

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  static Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> get _authHeaders => {
    ..._baseHeaders,
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ✅ MÉTODO PARA VERIFICAR CONEXIÓN
  static Future<DatabaseResponse<Map<String, dynamic>>> checkConnection() async {
    try {
      print('🔍 Intentando conectar a: $_baseUrl/health');

      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: _baseHeaders,
      ).timeout(Duration(milliseconds: DatabaseConfig.connectionTimeout));

      print('📡 Respuesta del servidor: ${response.statusCode}');
      print('📄 Contenido: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DatabaseResponse.success({
          'connected': true,
          'message': 'Conexión exitosa con Android',
          'server': _baseUrl,
          'serverResponse': data,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        return DatabaseResponse.error('Servidor respondió con código ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('❌ Error de red: $e');
      return DatabaseResponse.error('Sin conexión de red. Verifica que el servidor esté corriendo.');
    } on TimeoutException catch (e) {
      print('⏰ Timeout: $e');
      return DatabaseResponse.error('Timeout: El servidor no responde en $_baseUrl');
    } catch (e) {
      print('❌ Error general: $e');
      return DatabaseResponse.error('Error de conexión: $e');
    }
  }



  // GET Request actualizado
  static Future<DatabaseResponse<T>> get<T>(
      String endpoint, {
        bool requiresAuth = false,
      }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: requiresAuth ? _authHeaders : _baseHeaders,
      ).timeout(Duration(milliseconds: DatabaseConfig.connectionTimeout));

      return _handleResponse<T>(response);
    } catch (e) {
      return DatabaseResponse.error('Error de conexión: $e');
    }
  }

  // POST Request actualizado
  static Future<DatabaseResponse<T>> post<T>(
      String endpoint,
      Map<String, dynamic> data, {
        bool requiresAuth = false,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: requiresAuth ? _authHeaders : _baseHeaders,
        body: json.encode(data),
      ).timeout(Duration(milliseconds: DatabaseConfig.connectionTimeout));

      return _handleResponse<T>(response);
    } catch (e) {
      return DatabaseResponse.error('Error de conexión: $e');
    }
  }

  // POST con archivo actualizado
  static Future<DatabaseResponse<T>> postWithFile<T>(
      String endpoint,
      Map<String, String> fields,
      File? file,
      String fileFieldName, {
        bool requiresAuth = false,
      }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));

      if (requiresAuth && _authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      request.fields.addAll(fields);

      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
        ));
      }

      final streamedResponse = await request.send()
          .timeout(Duration(milliseconds: DatabaseConfig.connectionTimeout));
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response);
    } catch (e) {
      return DatabaseResponse.error('Error al subir archivo: $e');
    }
  }

  // Manejo centralizado de respuestas
  static DatabaseResponse<T> _handleResponse<T>(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        final data = json.decode(response.body);
        return DatabaseResponse.success(data);
      } catch (e) {
        return DatabaseResponse.success(response.body as T);
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        return DatabaseResponse.error(
          errorData['message'] ?? errorData['error'] ?? 'Error del servidor',
          statusCode,
        );
      } catch (e) {
        return DatabaseResponse.error('Error HTTP $statusCode', statusCode);
      }
    }
  }

  static bool hasAuthToken() {
    return _authToken != null && _authToken!.isNotEmpty;
  }

  static String? getAuthToken() {
    return _authToken;
  }
}