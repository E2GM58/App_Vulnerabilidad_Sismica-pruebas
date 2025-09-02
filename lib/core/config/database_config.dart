class DatabaseConfig {
  // 🤖 Para Android establaces la ip de tu compu ↓ antes del puerto
  static const String baseUrl = 'http://192.168.100.19:3000';

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // 🔍 Método para obtener la IP correcta dinámicamente
  static String getServerUrl() {
    // En desarrollo, puedes cambiar esto fácilmente
    const bool useEmulator = false; // Cambia a false si usas dispositivo físico
    // Cambia esta IP
    if (useEmulator) {
      return 'http://10.0.2.2:3000';
    } else {
       return 'http://192.168.100.19:3000';
    }
  }
}