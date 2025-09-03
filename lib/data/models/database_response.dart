class DatabaseResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  DatabaseResponse._({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  // En DatabaseService, agrega este metodo helper:
  static Future<DatabaseResponse<T>> _retryRequest<T>(
      Future<DatabaseResponse<T>> Function() request,
      {int maxRetries = 2}
      ) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      attempts++;
      try {
        final result = await request();
        if (result.success || result.statusCode != null && result.statusCode! >= 400 && result.statusCode! < 500) {
          return result; // Éxito o error del servidor (no reintentar)
        }

        if (attempts >= maxRetries) {
          return result; // Último intento
        }

        print('⏳ Retry en ${attempts + 1} segundos...');
        await Future.delayed(Duration(seconds: attempts));

      } catch (e) {
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(Duration(seconds: attempts));
      }
    }

    throw Exception('Max retries reached');
  }

  factory DatabaseResponse.error(String error, [int? statusCode]) {
    return DatabaseResponse._(success: false, error: error, statusCode: statusCode);
  }

  factory DatabaseResponse.success(T data, {int? statusCode}) {
    return DatabaseResponse._(success: true, data: data, statusCode: statusCode);
  }


  DatabaseResponse.failure({required this.error, this.statusCode, this.data})
      : success = false;
  }
