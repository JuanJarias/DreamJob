import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _UpperCaseTextFormatter extends TextInputFormatter {
  const _UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class RegisterRecruiterScreen extends StatefulWidget {
  const RegisterRecruiterScreen({super.key});

  @override
  State<RegisterRecruiterScreen> createState() =>
      _RegisterRecruiterScreenState();
}

class _RegisterRecruiterScreenState extends State<RegisterRecruiterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _empresaNombreController = TextEditingController();
  final _empresaDescripcionController = TextEditingController();
  final _empresaMonogramaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _empresaNombreController.addListener(_onCompanyFieldChanged);
    _empresaMonogramaController.addListener(_onCompanyFieldChanged);
  }

  void _onCompanyFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _empresaNombreController.removeListener(_onCompanyFieldChanged);
    _empresaMonogramaController.removeListener(_onCompanyFieldChanged);
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _empresaNombreController.dispose();
    _empresaDescripcionController.dispose();
    _empresaMonogramaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await auth.signUpRecruiter(
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      empresaNombre: _empresaNombreController.text.trim(),
      empresaDescripcion: _empresaDescripcionController.text.trim(),
      empresaMonograma: _empresaMonogramaController.text.trim().toUpperCase(),
    );
  }

  Widget _buildMonogramPreview() {
    final companyName = _empresaNombreController.text.trim();
    final mono = _empresaMonogramaController.text.trim().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DjColors.wash,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DjColors.line),
      ),
      child: Row(
        children: [
          CompanyMark(
            company: companyName,
            mono: mono,
            size: 54,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vista previa del monograma',
                  style: TextStyle(
                    color: DjColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  companyName.isEmpty ? 'Nombre de la empresa' : companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DjColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mono.isEmpty
                      ? 'Monograma: —'
                      : 'Monograma: $mono',
                  style: const TextStyle(
                    color: DjColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          'Registro de reclutador',
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
                  title: 'Crea tu perfil de reclutador',
                  sub:
                      'Completa tus datos y crea tu empresa para conectar con el mejor talento.',
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
                      const Text(
                        'Tus datos',
                        style: TextStyle(
                          color: DjColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Información de tu cuenta personal',
                        style: TextStyle(
                          color: DjColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Nombre completo',
                        hint: 'Ej. Carolina Gómez',
                        controller: _nombreController,
                        prefixIcon: Icons.person_outline,
                        validator: Validators.required,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Correo electrónico',
                        hint: 'carolina@empresa.com',
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
                      const SizedBox(height: 24),
                      const Divider(color: DjColors.line, height: 1),
                      const SizedBox(height: 20),
                      const Text(
                        'Tu empresa',
                        style: TextStyle(
                          color: DjColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Registra la empresa para tus publicaciones',
                        style: TextStyle(
                          color: DjColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Nombre de la empresa',
                        hint: 'Ej. Tech Solutions',
                        controller: _empresaNombreController,
                        prefixIcon: Icons.business_outlined,
                        validator: Validators.required,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Descripción de la empresa',
                        hint:
                            'Describe brevemente a qué se dedica la empresa (máx. 280 caracteres)',
                        controller: _empresaDescripcionController,
                        maxLines: 3,
                        maxLength: 280,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final req = Validators.required(value);
                          if (req != null) return req;
                          if (value != null && value.trim().length > 280) {
                            return 'La descripción no puede superar los 280 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: 'Monograma (1 a 3 letras)',
                        hint: 'Ej. TS',
                        controller: _empresaMonogramaController,
                        maxLength: 3,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          const _UpperCaseTextFormatter(),
                          LengthLimitingTextInputFormatter(3),
                        ],
                        prefixIcon: Icons.badge_outlined,
                        validator: Validators.monogram,
                      ),
                      const SizedBox(height: 12),
                      _buildMonogramPreview(),
                      const SizedBox(height: 24),
                      AuthPrimaryButton(
                        label: 'Crear cuenta',
                        loading: auth.loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                      'Volver',
                      style: TextStyle(
                        color: DjColors.muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
