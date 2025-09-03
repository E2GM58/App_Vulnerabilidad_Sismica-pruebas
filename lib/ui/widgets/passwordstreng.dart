import 'package:flutter/material.dart';

class PasswordStrengthWidget extends StatelessWidget {
  final String password;
  final double height;
  final double borderRadius;

  const PasswordStrengthWidget({
    super.key,
    required this.password,
    this.height = 6.0,
    this.borderRadius = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(password);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: Colors.grey[300],
                ),
                child: Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        height: height,
                        margin: EdgeInsets.only(
                          right: index < 3 ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          color: index < strength.level
                              ? strength.color
                              : Colors.transparent,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              strength.icon,
              color: strength.color,
              size: 16,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          strength.text,
          style: TextStyle(
            fontSize: 12,
            color: strength.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        level: 0,
        text: '',
        color: Colors.grey,
        icon: Icons.info_outline,
      );
    }

    int score = 0;
    List<String> feedback = [];

    // Longitud mínima
    if (password.length >= 8) {
      score++;
    } else {
      feedback.add('Al menos 8 caracteres');
    }

    // Contiene letras mayúsculas - CORREGIDO
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    } else {
      feedback.add('Incluir mayúsculas');
    }

    // Contiene letras minúsculas - AGREGADO
    if (RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    } else {
      feedback.add('Incluir minúsculas');
    }

    // Contiene números
    if (RegExp(r'[0-9]').hasMatch(password)) {
      score++;
    } else {
      feedback.add('Incluir números');
    }

    // Contiene símbolos
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      score++;
    } else {
      feedback.add('Incluir símbolos (!@#\$&*~)');
    }

    return _getStrengthFromScore(score, feedback);
  }

  PasswordStrength _getStrengthFromScore(int score, List<String> feedback) {
    switch (score) {
      case 0:
      case 1:
        return PasswordStrength(
          level: 1,
          text: 'Muy débil',
          color: Colors.red,
          icon: Icons.error,
        );
      case 2:
        return PasswordStrength(
          level: 2,
          text: 'Débil',
          color: Colors.orange,
          icon: Icons.warning,
        );
      case 3:
        return PasswordStrength(
          level: 3,
          text: 'Buena',
          color: Colors.yellow[700]!,
          icon: Icons.check_circle_outline,
        );
      case 4:
      case 5:
        return PasswordStrength(
          level: 4,
          text: 'Muy fuerte',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      default:
        return PasswordStrength(
          level: 0,
          text: '',
          color: Colors.grey,
          icon: Icons.info_outline,
        );
    }
  }
}

class PasswordStrength {
  final int level;
  final String text;
  final Color color;
  final IconData icon;

  PasswordStrength({
    required this.level,
    required this.text,
    required this.color,
    required this.icon,
  });
}

// Funciones auxiliares para usar en otros widgets
class PasswordStrengthHelper {
  static IconData getPasswordStrengthIcon(String password) {
    final strength = _calculatePasswordStrength(password);
    return strength.icon;
  }

  static Color getPasswordStrengthColor(String password) {
    final strength = _calculatePasswordStrength(password);
    return strength.color;
  }

  static PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        level: 0,
        text: '',
        color: Colors.grey,
        icon: Icons.info_outline,
      );
    }

    int score = 0;

    // Longitud mínima
    if (password.length >= 8) score++;

    // Contiene letras mayúsculas - CORREGIDO
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;

    // Contiene letras minúsculas - AGREGADO
    if (RegExp(r'[a-z]').hasMatch(password)) score++;

    // Contiene números
    if (RegExp(r'[0-9]').hasMatch(password)) score++;

    // Contiene símbolos
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score++;

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength(
          level: 1,
          text: 'Muy débil',
          color: Colors.red,
          icon: Icons.error,
        );
      case 2:
        return PasswordStrength(
          level: 2,
          text: 'Débil',
          color: Colors.orange,
          icon: Icons.warning,
        );
      case 3:
        return PasswordStrength(
          level: 3,
          text: 'Buena',
          color: Colors.yellow[700]!,
          icon: Icons.check_circle_outline,
        );
      case 4:
      case 5:
        return PasswordStrength(
          level: 4,
          text: 'Muy fuerte',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      default:
        return PasswordStrength(
          level: 0,
          text: '',
          color: Colors.grey,
          icon: Icons.info_outline,
        );
    }
  }
}