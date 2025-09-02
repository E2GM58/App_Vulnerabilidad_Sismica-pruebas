class AuthResponse {
  final bool success;
  final String? token;
  final int? userId; // Tu servidor devuelve userId en lugar de user completo
  final String message;
  final String? error;
  final int? statusCode;

  AuthResponse._({
    required this.success,
    this.token,
    this.userId,
    required this.message,
    this.error,
    this.statusCode,
  });

  // ✅ Respuesta exitosa
  factory AuthResponse.success({
    String? token,
    int? userId,
    required String message,
  }) {
    return AuthResponse._(
      success: true,
      token: token,
      userId: userId,
      message: message,
    );
  }

  // ❌ Respuesta de error
  factory AuthResponse.failure({
    required String error,
    int? statusCode,
  }) {
    return AuthResponse._(
      success: false,
      message: error,
      error: error,
      statusCode: statusCode,
    );
  }

  // 🆔 Obtener ID del usuario
  int? get userIdValue => userId;

  // 🔑 Verificar si tiene token válido
  bool get hasValidToken => token != null && token!.isNotEmpty;
}