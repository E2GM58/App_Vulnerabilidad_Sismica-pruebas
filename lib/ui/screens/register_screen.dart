import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../../core/services/register_service.dart';
import '../../data/models/register_response.dart';
import '../widgets/passwordstreng.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedula = TextEditingController(); // Controlador para la cédula
  final _username = TextEditingController();
  final _role = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _isLoading = false;
  bool _isCheckingAvailability = false;
  String? _completePhoneNumber;
  String? _usernameError;
  String? _emailError;

  @override
  void dispose() {
    _cedula.dispose(); // Limpiar controlador de cédula
    _username.dispose();
    _role.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.length < 3) {
      setState(() {
        _usernameError = null;
      });
      return;
    }

    setState(() {
      _isCheckingAvailability = true;
      _usernameError = null;
    });

    try {
      final isAvailable = await RegisterService.checkUsernameAvailability(username);
      if (mounted) {
        setState(() {
          _usernameError = isAvailable ? null : 'Este nombre de usuario ya está en uso';
          _isCheckingAvailability = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _usernameError = null;
          _isCheckingAvailability = false;
        });
      }
    }
  }

  Future<void> _checkEmailAvailability(String email) async {
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailError = null;
      });
      return;
    }

    setState(() {
      _emailError = null;
    });

    try {
      final isAvailable = await RegisterService.checkEmailAvailability(email);
      if (mounted) {
        setState(() {
          _emailError = isAvailable ? null : 'Este correo electrónico ya está registrado';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _emailError = null;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_usernameError != null || _emailError != null) {
      _showErrorMessage('Por favor corrija los errores antes de continuar');
      return;
    }

    if (_completePhoneNumber == null || _completePhoneNumber!.isEmpty) {
      _showErrorMessage('Por favor ingrese un número de teléfono válido');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Agregar impresión de datos
    print('Datos a enviar:');
    print('Cédula: ${_cedula.text.trim()}');
    print('Nombre: ${_username.text.trim()}'); // Cambia esto si usas _nombre
    print('Rol: ${_role.text.trim()}');
    print('Email: ${_email.text.trim()}');
    print('Teléfono: $_completePhoneNumber');
    print('Contraseña: ${_password.text}');

    try {
      final registerResponse = await RegisterService.registerUser(
        cedula: _cedula.text.trim(),
        username: _username.text.trim(), // Cambia esto si usas _nombre
        role: _role.text.trim(),
        email: _email.text.trim(),
        phone: _completePhoneNumber!,
        password: _password.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (registerResponse.success) {
          _showSuccessMessage(registerResponse.message ?? '¡Registro exitoso!');
          _showSuccessDialog(registerResponse);
        } else {
          _handleRegistrationError(registerResponse);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Error inesperado: $e');
      }
    }
  }

  void _handleRegistrationError(RegisterResponse response) {
    String errorMessage = response.error ?? 'Error desconocido';

    if (response.isValidationError) {
      errorMessage = '📋 $errorMessage';
    } else if (response.isConflictError) {
      errorMessage = '⚠️ $errorMessage';
    } else if (response.isServerError) {
      errorMessage = '🔧 $errorMessage';
    } else if (response.isConnectionError) {
      errorMessage = '🌐 $errorMessage';
    }

    _showErrorMessage(errorMessage);
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessDialog(RegisterResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.celebration, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('¡Bienvenido a SismosApp!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Su cuenta ha sido creada exitosamente.'),
              const SizedBox(height: 10),
              if (response.hasUserData) ...[
                Text('👤 Usuario: ${response.username}'),
                Text('📧 Email: ${response.email}'),
                Text('🏷️ Rol: ${response.role}'),
              ],
              const SizedBox(height: 10),
              const Text(
                'Ya puede comenzar a usar todas las funciones de la aplicación.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
                Navigator.of(context).pushReplacementNamed('/home');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continuar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SismosApp',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(child: AppLogo()),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Registro de usuario',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Complete los campos para crear su cuenta',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Campo de cédula
                        TextFormField(
                          controller: _cedula,
                          decoration: InputDecoration(
                            labelText: 'Cédula',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.credit_card),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su cédula';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Campo de usuario con verificación en tiempo real
                        TextFormField(
                          controller: _username,
                          decoration: InputDecoration(
                            labelText: 'Usuario',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: _isCheckingAvailability
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                                : _usernameError == null && _username.text.length >= 3
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                            errorText: _usernameError,
                          ),
                          enabled: !_isLoading,
                          onChanged: (value) {
                            if (value.length >= 3) {
                              Future.delayed(const Duration(milliseconds: 500), () {
                                if (_username.text == value) {
                                  _checkUsernameAvailability(value);
                                }
                              });
                            } else {
                              setState(() {
                                _usernameError = null;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese un usuario';
                            }
                            if (value.length < 3) {
                              return 'El usuario debe tener al menos 3 caracteres';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                              return 'Solo letras, números y guión bajo permitidos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Campo de selección de rol
                        DropdownButtonFormField<String>(
                          value: _role.text.isNotEmpty ? _role.text : null,
                          decoration: const InputDecoration(
                            labelText: 'Rol',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('👑 Admin', style: TextStyle(color: Colors.black)),
                            ),
                            DropdownMenuItem(
                              value: 'inspector',
                              child: Text('🔍 Inspector', style: TextStyle(color: Colors.black)),
                            ),
                            DropdownMenuItem(
                              value: 'ayudante',
                              child: Text('🤝 Ayudante', style: TextStyle(color: Colors.black)),
                            ),
                            DropdownMenuItem(
                              value: 'cliente',
                              child: Text('👤 Cliente', style: TextStyle(color: Colors.black)),
                            ),
                          ],
                          onChanged: _isLoading ? null : (value) {
                            setState(() {
                              _role.text = value ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Seleccione un rol';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Campo de correo electrónico con verificación
                        TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.email),
                            suffixIcon: _emailError == null &&
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email.text)
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                            errorText: _emailError,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoading,
                          onChanged: (value) {
                            if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              Future.delayed(const Duration(milliseconds: 800), () {
                                if (_email.text == value) {
                                  _checkEmailAvailability(value);
                                }
                              });
                            } else {
                              setState(() {
                                _emailError = null;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese un correo electrónico';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Ingrese un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Campo de teléfono con país
                        IntlPhoneField(
                          controller: _phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(),
                          ),
                          initialCountryCode: 'EC',
                          enabled: !_isLoading,
                          onChanged: (phone) {
                            _completePhoneNumber = phone.completeNumber;
                          },
                          validator: (value) {
                            final phoneNumber = value?.number ?? '';
                            if (phoneNumber.isEmpty) {
                              return 'Ingrese su número de teléfono';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
                              return 'Solo se permiten números';
                            }
                            if (phoneNumber.length < 7) {
                              return 'Número de teléfono muy corto';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Campo de contraseña con indicador de fortaleza usando el helper
                        TextFormField(
                          controller: _password,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: _password.text.isNotEmpty
                                ? Icon(
                              PasswordStrengthHelper.getPasswordStrengthIcon(_password.text),
                              color: PasswordStrengthHelper.getPasswordStrengthColor(_password.text),
                            )
                                : null,
                          ),
                          obscureText: true,
                          enabled: !_isLoading,
                          onChanged: (value) {
                            setState(() {}); // Actualizar indicador de fortaleza
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese una contraseña';
                            }
                            if (value.length < 8) {
                              return 'Debe tener al menos 8 caracteres';
                            }
                            if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return 'Debe contener al menos una letra mayúscula';
                            }
                            if (!RegExp(r'[a-z]').hasMatch(value)) {
                              return 'Debe contener al menos una letra minúscula';
                            }
                            if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return 'Debe contener números';
                            }
                            if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
                              return 'Debe contener al menos un símbolo (!@#\$&*~)';
                            }
                            return null;
                          },
                        ),

                        // Indicador de fortaleza de contraseña usando el widget separado
                        if (_password.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          PasswordStrengthWidget(
                            password: _password.text,
                          ),
                          const SizedBox(height: 4),
                        ],

                        const SizedBox(height: 12),

                        // Campo de confirmar contraseña
                        TextFormField(
                          controller: _confirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirmar contraseña',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: _confirmPassword.text.isNotEmpty &&
                                _confirmPassword.text == _password.text
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                          ),
                          obscureText: true,
                          enabled: !_isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirme su contraseña';
                            }
                            if (value != _password.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Botón de registro
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading || _isCheckingAvailability ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.gray300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Registrando...',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            )
                                : const Text(
                              'Crear Cuenta',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Link para ir al login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes una cuenta? ',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.gray500,
                              ),
                            ),
                            GestureDetector(
                              onTap: _isLoading ? null : () {
                                Navigator.of(context).pushReplacementNamed('/login');
                              },
                              child: Text(
                                'Inicia sesión',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}