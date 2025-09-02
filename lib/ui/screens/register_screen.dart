import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_logo.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _role = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _fakeLogin() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login (UI demo).')));
    }
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
                        // Campo de usuario. Enviar como 'username' al backend (API de registro)
                        TextFormField(
                          controller: _username,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese un usuario';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Campo de selección de rol (enviar como role al backend)
                        // Campo de selección de rol. Enviar como 'role' al backend (API de registro)
                        DropdownButtonFormField<String>(
                          value: _role.text.isNotEmpty ? _role.text : null,
                          decoration: const InputDecoration(
                            labelText: 'Rol',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text(
                                'Admin',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'inspector',
                              child: Text(
                                'Inspector',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'ayudante',
                              child: Text(
                                'Ayudante',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'cliente',
                              child: Text(
                                'Cliente',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                          onChanged: (value) {
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
                        // Campo de correo electrónico. Enviar como 'email' al backend (API de registro)
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese un correo electrónico';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Ingrese un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Campo de teléfono con país. Enviar como 'phone' al backend (API de registro)
                        IntlPhoneField(
                          controller: _phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(),
                          ),
                          initialCountryCode: 'EC',
                          onChanged: (phone) {
                            // phone.completeNumber contiene el número completo con país
                          },
                          validator: (value) {
                            final phoneNumber = value?.number ?? '';
                            if (phoneNumber.isEmpty) {
                              return 'Ingrese su número de teléfono';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
                              return 'Solo se permiten números';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Campo de contraseña. Enviar como 'password' al backend (API de registro)
                        TextFormField(
                          controller: _password,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese una contraseña';
                            }
                            // Debe tener al menos 8 caracteres, un símbolo y un carácter especial
                            if (value.length < 8) {
                              return 'Debe tener al menos 8 caracteres';
                            }
                            if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
                              return 'Debe contener al menos un símbolo (!@#\$&*~)';
                            }
                            if (!RegExp(r'[A-Za-z0-9]').hasMatch(value)) {
                              return 'Debe contener letras y números';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Campo de confirmar contraseña. Solo para validación local, no se envía al backend
                        TextFormField(
                          controller: _confirmPassword,
                          decoration: const InputDecoration(
                            labelText: 'Confirmar contraseña',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
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
                        const SizedBox(height: 12),
                        // ...existing code...
                        // Botón para enviar datos al backend (API de registro)
                        ElevatedButton(
                          onPressed:
                              _fakeLogin, // Aquí se debe conectar la lógica de registro con el backend
                          child: const Text('Registrar'),
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
