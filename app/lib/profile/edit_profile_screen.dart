import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../auth/data/models.dart';
import '../auth/state/auth_provider.dart';
import '../auth/widgets/auth_error_banner.dart';
import '../auth/widgets/auth_primary_button.dart';
import '../auth/widgets/auth_text_field.dart';
import '../core/validators.dart';
import '../theme.dart';
import '../widgets/common.dart';

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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Campos comunes y de candidato
  late final TextEditingController _nombreController;
  late final TextEditingController _ciudadController;
  late final TextEditingController _resumenController;

  // Campos de empresa (reclutador)
  late final TextEditingController _empresaNombreController;
  late final TextEditingController _empresaDescripcionController;
  late final TextEditingController _empresaMonogramaController;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final auth = context.read<AuthProvider>();
      if (auth.role == UserRole.candidato && auth.candidate != null) {
        final c = auth.candidate!;
        _nombreController = TextEditingController(text: c.nombre);
        _ciudadController = TextEditingController(text: c.ciudad);
        _resumenController = TextEditingController(text: c.resumenPerfil ?? '');
        _empresaNombreController = TextEditingController();
        _empresaDescripcionController = TextEditingController();
        _empresaMonogramaController = TextEditingController();
      } else if (auth.role == UserRole.reclutador && auth.recruiter != null) {
        final r = auth.recruiter!;
        _nombreController = TextEditingController(text: r.nombre);
        _ciudadController = TextEditingController();
        _resumenController = TextEditingController();
        _empresaNombreController = TextEditingController(text: r.empresa.nombre);
        _empresaDescripcionController =
            TextEditingController(text: r.empresa.descripcion);
        _empresaMonogramaController =
            TextEditingController(text: r.empresa.monograma);
        _empresaNombreController.addListener(_onCompanyFieldChanged);
        _empresaMonogramaController.addListener(_onCompanyFieldChanged);
      } else {
        _nombreController = TextEditingController();
        _ciudadController = TextEditingController();
        _resumenController = TextEditingController();
        _empresaNombreController = TextEditingController();
        _empresaDescripcionController = TextEditingController();
        _empresaMonogramaController = TextEditingController();
      }
      _initialized = true;
    }
  }

  void _onCompanyFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _empresaNombreController.removeListener(_onCompanyFieldChanged);
    _empresaMonogramaController.removeListener(_onCompanyFieldChanged);
    _nombreController.dispose();
    _ciudadController.dispose();
    _resumenController.dispose();
    _empresaNombreController.dispose();
    _empresaDescripcionController.dispose();
    _empresaMonogramaController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool success = false;
    if (auth.role == UserRole.candidato) {
      success = await auth.updateCandidateProfile(
        nombre: _nombreController.text.trim(),
        ciudad: _ciudadController.text.trim(),
        resumenPerfil: _resumenController.text.trim(),
      );
    } else if (auth.role == UserRole.reclutador) {
      success = await auth.updateRecruiterProfile(
        nombre: _nombreController.text.trim(),
        empresaNombre: _empresaNombreController.text.trim(),
        empresaDescripcion: _empresaDescripcionController.text.trim(),
        empresaMonograma: _empresaMonogramaController.text.trim().toUpperCase(),
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: DjColors.navy,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildCandidateFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: 'Nombre completo',
          hint: 'Ej. Ana María Torres',
          controller: _nombreController,
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          validator: (value) => Validators.required(value, 'El nombre completo'),
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: 'Ciudad',
          hint: 'Ej. Cali, Colombia',
          controller: _ciudadController,
          prefixIcon: Icons.location_on_outlined,
          textInputAction: TextInputAction.next,
          validator: (value) => Validators.required(value, 'La ciudad'),
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: 'Resumen profesional (máximo 280 caracteres)',
          hint: 'Describe tu perfil profesional, logros o intereses laborales...',
          controller: _resumenController,
          maxLines: 4,
          maxLength: 280,
          textInputAction: TextInputAction.done,
          validator: (value) =>
              Validators.maxLength(value, 280, 'El resumen profesional'),
        ),
      ],
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
                  mono.isEmpty ? 'Monograma: —' : 'Monograma: $mono',
                  style: const TextStyle(
                    color: DjColors.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruiterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: 'Nombre completo',
          hint: 'Ej. Carlos Restrepo',
          controller: _nombreController,
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          validator: (value) => Validators.required(value, 'El nombre completo'),
        ),
        const SizedBox(height: 22),
        const Divider(color: DjColors.line, height: 1),
        const SizedBox(height: 18),
        const Text(
          'Datos de la empresa',
          style: TextStyle(
            color: DjColors.ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Actualiza la información visible en tus ofertas de empleo',
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
          textInputAction: TextInputAction.next,
          validator: (value) =>
              Validators.required(value, 'El nombre de la empresa'),
        ),
        const SizedBox(height: 18),
        AuthTextField(
          label: 'Descripción de la empresa (máx. 280 caracteres)',
          hint: 'Describe a qué se dedica la empresa...',
          controller: _empresaDescripcionController,
          maxLines: 4,
          maxLength: 280,
          textInputAction: TextInputAction.next,
          validator: (value) {
            final req = Validators.required(value, 'La descripción de la empresa');
            if (req != null) return req;
            return Validators.maxLength(
              value,
              280,
              'La descripción de la empresa',
            );
          },
        ),
        const SizedBox(height: 18),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isCandidato = auth.role == UserRole.candidato;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrostedTop(
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: DjColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DjColors.ink, size: 22),
          tooltip: 'Volver',
          onPressed: () {
            auth.clearError();
            Navigator.of(context).pop();
          },
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
                if (auth.error != null) ...[
                  AuthErrorBanner(error: auth.error),
                  const SizedBox(height: 16),
                ],
                DjCard(
                  padding: const EdgeInsets.all(20),
                  child: isCandidato
                      ? _buildCandidateFields()
                      : _buildRecruiterFields(),
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  label: 'Guardar cambios',
                  icon: Icons.save_outlined,
                  loading: auth.loading,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: auth.loading
                        ? null
                        : () {
                            auth.clearError();
                            Navigator.of(context).pop();
                          },
                    child: const Text(
                      'Cancelar',
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
