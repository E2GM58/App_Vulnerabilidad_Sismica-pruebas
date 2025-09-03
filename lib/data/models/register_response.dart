class RegisterResponse {
  final bool success;
  final String? token;
  final dynamic userId;
  final Map<String, dynamic>? user;
  final String? message;
  final String? error;
  final int? statusCode;

  RegisterResponse({
    required this.success,
    this.token,
    this.userId,
    this.user,
    this.message,
    this.error,
    this.statusCode,
  });

  // ✅ Constructor para respuesta exitosa - CORREGIDO
  factory RegisterResponse.success({
    String? token,        // ✅ Agregar parámetro token
    dynamic userId,
    Map<String, dynamic>? user,
    String? message,
  }) {
    return RegisterResponse(
      success: true,
      token: token,       // ✅ Asignar el token
      userId: userId,
      user: user,
      message: message,
    );
  }

  // ❌ Constructor para respuesta con error
  factory RegisterResponse.failure({
    required String error,
    int? statusCode,
  }) {
    return RegisterResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  // Constructor desde JSON (si necesitas deserialización)
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      token: json['token'],
      userId: json['userId'] ?? json['user']?['id_usuario'],
      user: json['user'],
      message: json['message'],
      error: json['error'],
      statusCode: json['statusCode'],
    );
  }

  // Convertir a JSON (si necesitas serialización)
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'token': token,
      'userId': userId,
      'user': user,
      'message': message,
      'error': error,
      'statusCode': statusCode,
    };
  }

  // ✅ GETTERS ÚTILES

  // Getter para verificar si hay datos de usuario
  bool get hasUserData => user != null && user!.isNotEmpty;

  // ✅ Getter para verificar si tiene token válido
  bool get hasValidToken => token != null && token!.isNotEmpty;

  // Getter para obtener información específica del usuario
  String? get username => user?['username'] ?? user?['nombre_usuario'] ?? user?['nombre'];
  String? get email => user?['email'] ?? user?['correo'];
  String? get role => user?['role'] ?? user?['rol'];
  String? get phone => user?['phone'] ?? user?['telefono'];
  String? get cedula => user?['cedula'];

  // ✅ Getter para obtener ID del usuario de forma consistente
  int? get userIdValue {
    if (userId is int) return userId;
    if (userId is String) return int.tryParse(userId);
    return null;
  }

  // Método para logging/debug - MEJORADO
  @override
  String toString() {
    if (success) {
      return 'RegisterResponse.success(token: ${token?.substring(0, 10)}..., userId: $userId, message: $message)';
    } else {
      return 'RegisterResponse.failure(error: $error, statusCode: $statusCode)';
    }
  }

  // ✅ MÉTODOS DE VALIDACIÓN DE ERRORES

  // Método para verificar si es un error específico
  bool isError(String errorType) {
    if (!success && error != null) {
      return error!.toLowerCase().contains(errorType.toLowerCase());
    }
    return false;
  }

  // Método para verificar errores de validación
  bool get isValidationError {
    return statusCode == 400 || statusCode == 422;
  }

  // Método para verificar errores de conflicto (usuario/email ya existe)
  bool get isConflictError {
    return statusCode == 409;
  }

  // Método para verificar errores del servidor
  bool get isServerError {
    return statusCode != null && statusCode! >= 500;
  }

  // Método para verificar errores de conexión
  bool get isConnectionError {
    return !success && statusCode == null && error != null &&
        (error!.contains('conexión') || error!.contains('connection'));
  }

  // ✅ NUEVOS MÉTODOS ÚTILES

  // Verificar si el registro fue exitoso Y tiene token (login automático exitoso)
  bool get isCompleteSuccess => success && hasValidToken;

  // Verificar si el registro fue exitoso pero sin login automático
  bool get isPartialSuccess => success && !hasValidToken;

  // Obtener un mensaje de estado amigable
  String get statusMessage {
    if (isCompleteSuccess) {
      return message ?? 'Registro y login exitosos';
    } else if (isPartialSuccess) {
      return message ?? 'Registro exitoso, inicia sesión manualmente';
    } else {
      return error ?? 'Error desconocido';
    }
  }

  // ✅ Método para copiar con nuevos valores (útil para updates)
  RegisterResponse copyWith({
    bool? success,
    String? token,
    dynamic userId,
    Map<String, dynamic>? user,
    String? message,
    String? error,
    int? statusCode,
  }) {
    return RegisterResponse(
      success: success ?? this.success,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      message: message ?? this.message,
      error: error ?? this.error,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}