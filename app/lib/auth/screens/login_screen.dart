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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: OwlBadge(size: 72)),
                const SizedBox(height: 20),
                const Text(
                  'Te damos la bienvenida a DreamJob',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DjColors.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Inicia sesión con tu correo y contraseña para continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DjColors.muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                DjCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (auth.error != null) ...[
                        AuthErrorBanner(error: auth.error),
                        const SizedBox(height: 16),
                      ],
                      AuthTextField(
                        label: 'Correo electrónico',
                        hint: 'nombre@correo.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.mail_outline,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      AuthPasswordField(
                        label: 'Contraseña',
                        hint: 'Ingresa tu contraseña',
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        validator: Validators.required,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 24),
                      AuthPrimaryButton(
                        label: 'Iniciar sesión',
                        loading: auth.loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed:
                        auth.loading
                            ? null
                            : () {
                              auth.clearError();
                              context.go('/register');
                            },
                    child: const Text(
                      '¿No tienes cuenta? Crear cuenta',
                      style: TextStyle(
                        color: DjColors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
