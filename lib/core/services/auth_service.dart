import '../constants/database_endpoints.dart';
import 'database_service.dart';
import '../../data/models/database_response.dart';
import '../../data/models/auth_response.dart';

class AuthService {

  // 🔐 LOGIN con retry automático
  static Future<AuthResponse> login({
    required String email,
    required String password,
    int maxRetries = 2, // ✅ Máximo 2 intentos
  }) async {
    int attemptCount = 0;

    while (attemptCount < maxRetries) {
      attemptCount++;

      try {
        print('🔐 AuthService: Intento $attemptCount/$maxRetries para $email');

        final response = await DatabaseService.post<Map<String, dynamic>>(
          DatabaseEndpoints.login,
          {
            "email": email.trim(),
            "password": password,
          },
        );

        if (response.success && response.data != null) {
          final data = response.data!;
          final success = data['success'] ?? false;
          final token = data['token'];
          final userId = data['userId'];

          if (success && token != null) {
            // Guardar token automáticamente
            DatabaseService.setAuthToken(token);
            print('✅ Login exitoso en intento $attemptCount');
            print('✅ Token guardado: ${token.substring(0, 20)}...');
            print('👤 ID de usuario: $userId');

            return AuthResponse.success(
              token: token,
              userId: userId,
              message: '¡Login exitoso! Bienvenido',
            );
          } else {
            return AuthResponse.failure(
              error: 'Login falló - respuesta inválida del servidor',
            );
          }
        } else {
          // Si es error de servidor (no de conexión), no reintentar
          if (response.statusCode != null && response.statusCode! >= 400 && response.statusCode! < 500) {
            print('❌ Error del servidor (${response.statusCode}): ${response.error}');
            return AuthResponse.failure(
              error: response.error ?? 'Credenciales inválidas',
              statusCode: response.statusCode,
            );
          }

          // Error de conexión, continuar con retry
          print('⚠️ Intento $attemptCount falló: ${response.error}');
          if (attemptCount >= maxRetries) {
            return AuthResponse.failure(
              error: response.error ?? 'Error de conexión después de $maxRetries intentos',
              statusCode: response.statusCode,
            );
          }
        }
      } catch (e) {
        print('❌ Error en intento $attemptCount: $e');

        // Si es el último intento, devolver error
        if (attemptCount >= maxRetries) {
          return AuthResponse.failure(
            error: 'Error de conexión después de $maxRetries intentos: $e',
          );
        }

        // Si no es el último intento, esperar un poco antes del retry
        if (attemptCount < maxRetries) {
          print('⏳ Esperando 1 segundo antes del retry...');
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    // Fallback (no debería llegar aquí)
    return AuthResponse.failure(
      error: 'Error inesperado en el login',
    );
  }

  // 🚪 LOGOUT - Limpiar sesión
  static void logout() {
    print('🚪 AuthService: Cerrando sesión');
    DatabaseService.clearAuthToken();
  }

  // ✅ VERIFICAR SI HAY TOKEN
  static bool isLoggedIn() {
    return DatabaseService.hasAuthToken();
  }

  // 🔑 OBTENER TOKEN ACTUAL
  static String? getCurrentToken() {
    return DatabaseService.getAuthToken();
  }
}
