import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/validators.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../state/auth_provider.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class RegisterCandidateScreen extends StatefulWidget {
  const RegisterCandidateScreen({super.key});

  @override
  State<RegisterCandidateScreen> createState() =>
      _RegisterCandidateScreenState();
}

class _RegisterCandidateScreenState extends State<RegisterCandidateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _fechaController = TextEditingController();
  final _resumenController = TextEditingController();

  DateTime? _selectedBirthDate;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ciudadController.dispose();
    _fechaController.dispose();
    _resumenController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial =
        _selectedBirthDate ?? DateTime(now.year - 21, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _fechaController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final birthDate =
        _selectedBirthDate ?? DateTime.parse(_fechaController.text.trim());

    await auth.signUpCandidate(
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      ciudad: _ciudadController.text.trim(),
      fechaNacimiento: birthDate,
      resumenPerfil: _resumenController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrostedTop(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(
            child: CircleBack(
              onTap: () {
                auth.clearError();
                context.go('/register');
              },
            ),
          ),
        ),
        title: const Text(
          'Registro de candidato',
          style: TextStyle(
            color: DjColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHead(
                  title: 'Crea tu perfil de candidato',
                  sub: 'Completa tus datos básicos para explorar oportunidades.',
                ),
                const SizedBox(height: 20),
                DjCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (auth.error != null) ...[
                        AuthErrorBanner(error: auth.error),
                        const SizedBox(height: 16),
                      ],
                      AuthTextField(
                        label: 'Nombre completo',
                        hint: 'Ej. Valentina Rodríguez',
                        controller: _nombreController,
                        prefixIcon: Icons.person_outline,
                        validator: Validators.required,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Correo electrónico',
                        hint: 'valentina@correo.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      AuthPasswordField(
                        label: 'Contraseña',
                        hint: 'Mínimo 8 caracteres',
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 16),
                      AuthPasswordField(
                        label: 'Confirmar contraseña',
                        hint: 'Repite tu contraseña',
                        controller: _confirmPasswordController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final req = Validators.required(value);
                          if (req != null) return req;
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Ciudad',
                        hint: 'Ej. Cali',
                        controller: _ciudadController,
                        prefixIcon: Icons.location_on_outlined,
                        validator: Validators.required,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Fecha de nacimiento',
                        hint: 'AAAA-MM-DD',
                        controller: _fechaController,
                        readOnly: true,
                        onTap: _pickBirthDate,
                        prefixIcon: Icons.calendar_today_outlined,
                        validator: Validators.date,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Resumen de perfil (opcional)',
                        hint:
                            'Cuéntanos brevemente sobre tus intereses y proyectos (máx. 280 caracteres)',
                        controller: _resumenController,
                        maxLines: 3,
                        maxLength: 280,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value != null && value.length > 280) {
                            return 'El resumen no puede superar los 280 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      AuthPrimaryButton(
                        label: 'Crear cuenta',
                        loading: auth.loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
