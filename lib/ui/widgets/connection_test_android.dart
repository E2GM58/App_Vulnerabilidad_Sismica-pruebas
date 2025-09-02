import 'package:flutter/material.dart';
import '../../core/services/database_service.dart';

class ConnectionTestAndroid extends StatefulWidget {
  const ConnectionTestAndroid({super.key});

  @override
  State<ConnectionTestAndroid> createState() => _ConnectionTestAndroidState();
}

class _ConnectionTestAndroidState extends State<ConnectionTestAndroid> {
  bool _isConnected = false;
  bool _isTesting = false;
  String _statusMessage = 'Sin probar';
  String _detailsMessage = '';

  @override
  void initState() {
    super.initState();
    // Probar automáticamente al cargar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testConnection();
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _statusMessage = 'Probando conexión...';
      _detailsMessage = '';
    });

    try {
      final response = await DatabaseService.checkConnection();

      setState(() {
        _isConnected = response.success;
        _statusMessage = response.success
            ? '✅ CONECTADO'
            : '❌ SIN CONEXIÓN';

        if (response.success) {
          _detailsMessage = 'Servidor: ${response.data?['server']}\n'
              'Mensaje: ${response.data?['message']}\n'
              'Respuesta del servidor: ${response.data?['serverResponse']?['message'] ?? 'OK'}';
        } else {
          _detailsMessage = 'Error: ${response.error}';
        }
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _statusMessage = '❌ ERROR';
        _detailsMessage = 'Excepción: $e';
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                if (_isTesting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_detailsMessage.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isConnected ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                ),
                child: Text(
                  _detailsMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnected ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isTesting ? null : _testConnection,
                child: Text(_isTesting ? 'Probando...' : '🔄 Probar conexión'),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'URL: ${DatabaseService.checkConnection}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}