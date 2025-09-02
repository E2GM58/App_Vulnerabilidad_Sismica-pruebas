import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/forgot_password_screen.dart';
import 'ui/screens/register_screen.dart';
import 'ui/screens/recovery_password.dart';

void main() {
  runApp(const SismosApp());
}

class SismosApp extends StatelessWidget {
  const SismosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SismosApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/', // 👈 Pantalla inicial
      routes: {
        '/': (_) => const LoginScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/register': (context) => const RegisterScreen(),
        '/recovery': (context) => const RecoveryPasswordScreen(),
      },
    );
  }
}
