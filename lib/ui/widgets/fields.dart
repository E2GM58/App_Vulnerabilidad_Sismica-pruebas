import 'package:flutter/material.dart';

class AppEmailField extends StatelessWidget {
  final TextEditingController controller;
  const AppEmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(hintText: 'Correo'),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Ingrese su correo';
        return null;
      },
    );
  }
}

class AppPasswordField extends StatefulWidget {
  final TextEditingController controller;
  const AppPasswordField({super.key, required this.controller});
  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        hintText: 'Contraseña',
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Ingrese su contraseña';
        return null;
      },
    );
  }
}
