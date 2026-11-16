import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../auth/state/auth_provider.dart';
import '../../auth/widgets/auth_error_banner.dart';
import '../../auth/widgets/auth_primary_button.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../../core/validators.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../data/models.dart';
import '../state/vacancies_provider.dart';

class VacancyFormScreen extends StatefulWidget {
  final Vacancy? vacancy;

  const VacancyFormScreen({super.key, this.vacancy});

  @override
  State<VacancyFormScreen> createState() => _VacancyFormScreenState();
}

class _VacancyFormScreenState extends State<VacancyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloController;
  late final TextEditingController _ubicacionController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _salarioMinController;
  late final TextEditingController _salarioMaxController;

  late String _modalidad;
  late String _seniority;
  final Set<String> _selectedTecnologiaIds = {};

  String? _technologiesError;
  bool _initialized = false;

  bool get isEditing => widget.vacancy != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vacancy;
    _tituloController = TextEditingController(text: v?.titulo ?? '');
    _ubicacionController = TextEditingController(text: v?.ubicacion ?? '');
    _descripcionController = TextEditingController(text: v?.descripcion ?? '');
    _salarioMinController = TextEditingController(
      text: v?.salarioMin != null ? v!.salarioMin.toString() : '',
    );
    _salarioMaxController = TextEditingController(
      text: v?.salarioMax != null ? v!.salarioMax.toString() : '',
    );

    _modalidad = v?.modalidad ?? JobModalities.remoto;
    _seniority = v?.seniority ?? JobSeniorities.junior;

    if (v != null) {
      _selectedTecnologiaIds.addAll(v.tecnologias.map((t) => t.id));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<VacanciesProvider>().cargarCatalogoTecnologias();
      });
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _ubicacionController.dispose();
    _descripcionController.dispose();
    _salarioMinController.dispose();
    _salarioMaxController.dispose();
    super.dispose();
  }

  void _onToggleTechnology(String techId) {
    setState(() {
      if (_selectedTecnologiaIds.contains(techId)) {
        _selectedTecnologiaIds.remove(techId);
      } else {
        _selectedTecnologiaIds.add(techId);
      }
      if (_selectedTecnologiaIds.isNotEmpty) {
        _technologiesError = null;
      }
    });
  }

  String? _validateSalarioMin(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return 'Ingresa un valor numérico válido';
    }
    return null;
  }

  String? _validateSalarioMax(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final maxParsed = int.tryParse(value.trim());
    if (maxParsed == null || maxParsed < 0) {
      return 'Ingresa un valor numérico válido';
    }

    final minText = _salarioMinController.text.trim();
    if (minText.isNotEmpty) {
      final minParsed = int.tryParse(minText);
      if (minParsed != null && maxParsed < minParsed) {
        return 'El salario máximo no puede ser menor al salario mínimo';
      }
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    final vacanciesProvider = context.read<VacanciesProvider>();
    vacanciesProvider.clearError();

    final isFormValid = _formKey.currentState!.validate();
    final hasTechnologies = _selectedTecnologiaIds.isNotEmpty;

    if (!hasTechnologies) {
      setState(() {
        _technologiesError = 'Debes seleccionar al menos una tecnología';
      });
    } else {
      setState(() {
        _technologiesError = null;
      });
    }

    if (!isFormValid || !hasTechnologies) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final empresaId =
        auth.recruiter?.empresa.id ?? widget.vacancy?.empresaId ?? '';
    final reclutadorId = auth.recruiter?.id ?? widget.vacancy?.reclutadorId ?? '';

    if (empresaId.isEmpty || reclutadorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes haber iniciado sesión como reclutador para guardar vacantes',
          ),
          backgroundColor: DjColors.errorInk,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final salarioMinParsed = _salarioMinController.text.trim().isNotEmpty
        ? int.tryParse(_salarioMinController.text.trim())
        : null;
    final salarioMaxParsed = _salarioMaxController.text.trim().isNotEmpty
        ? int.tryParse(_salarioMaxController.text.trim())
        : null;

    final vacantePayload = Vacancy(
      id: widget.vacancy?.id,
      empresaId: empresaId,
      reclutadorId: reclutadorId,
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      ubicacion: _ubicacionController.text.trim(),
      modalidad: _modalidad,
      seniority: _seniority,
      salarioMin: salarioMinParsed,
      salarioMax: salarioMaxParsed,
      moneda: widget.vacancy?.moneda ?? 'COP',
      estado: widget.vacancy?.estado ?? VacancyStatuses.activa,
    );

    final resultado = await vacanciesProvider.guardarVacante(
      vacante: vacantePayload,
      tecnologiaIds: _selectedTecnologiaIds.toList(),
    );

    if (!mounted) return;

    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Vacante actualizada correctamente'
                : 'Vacante publicada correctamente',
          ),
          backgroundColor: DjColors.navy,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: DjColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: DjColors.ink, fontSize: 15),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, color: DjColors.muted, size: 20),
            filled: true,
            fillColor: DjColors.wash,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: DjColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: DjColors.blue, width: 1.5),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: DjColors.muted),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildTechnologiesSection(List<Technology> tecnologias) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Tecnologías requeridas',
              style: TextStyle(
                color: DjColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '(mínimo una)',
              style: TextStyle(
                color: DjColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (_selectedTecnologiaIds.isNotEmpty)
              Text(
                '${_selectedTecnologiaIds.length} seleccionada(s)',
                style: const TextStyle(
                  color: DjColors.sky,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (tecnologias.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'Cargando catálogo de tecnologías...',
                  style: TextStyle(color: DjColors.muted, fontSize: 13),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tecnologias.map((tech) {
              final isSelected = _selectedTecnologiaIds.contains(tech.id);
              return FilterChip(
                label: Text(tech.nombre),
                selected: isSelected,
                onSelected: (_) => _onToggleTechnology(tech.id),
                selectedColor: DjColors.navy,
                backgroundColor: DjColors.wash,
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : DjColors.ink,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? DjColors.navy : DjColors.line,
                  ),
                ),
              );
            }).toList(),
          ),
        if (_technologiesError != null) ...[
          const SizedBox(height: 8),
          Text(
            _technologiesError!,
            style: const TextStyle(
              color: DjColors.errorInk,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vacanciesProvider = context.watch<VacanciesProvider>();
    final catalogo = vacanciesProvider.catalogoTecnologias;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrostedTop(
        title: Text(
          isEditing ? 'Editar vacante' : 'Publicar vacante',
          style: const TextStyle(
            color: DjColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DjColors.ink, size: 22),
          tooltip: 'Volver',
          onPressed: () {
            vacanciesProvider.clearError();
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
                if (vacanciesProvider.error != null) ...[
                  AuthErrorBanner(error: vacanciesProvider.error),
                  const SizedBox(height: 16),
                ],
                DjCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthTextField(
                        label: 'Título del cargo',
                        hint: 'Ej. Desarrollador Flutter Semi-Senior',
                        controller: _tituloController,
                        prefixIcon: Icons.badge_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            Validators.required(value, 'El título del cargo'),
                      ),
                      const SizedBox(height: 18),
                      AuthTextField(
                        label: 'Ubicación / Ciudad',
                        hint: 'Ej. Cali, Colombia (o Remoto Latam)',
                        controller: _ubicacionController,
                        prefixIcon: Icons.location_on_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            Validators.required(value, 'La ubicación'),
                      ),
                      const SizedBox(height: 18),
                      _buildDropdownField(
                        label: 'Modalidad de trabajo',
                        value: _modalidad,
                        items: JobModalities.values,
                        onChanged: (val) {
                          if (val != null) setState(() => _modalidad = val);
                        },
                        prefixIcon: Icons.work_outline,
                      ),
                      const SizedBox(height: 18),
                      _buildDropdownField(
                        label: 'Nivel de experiencia',
                        value: _seniority,
                        items: JobSeniorities.values,
                        onChanged: (val) {
                          if (val != null) setState(() => _seniority = val);
                        },
                        prefixIcon: Icons.trending_up_outlined,
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: DjColors.line, height: 1),
                      const SizedBox(height: 18),
                      const Text(
                        'Rango salarial opcional (COP)',
                        style: TextStyle(
                          color: DjColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ingresa valores numéricos. El salario máximo no debe ser inferior al mínimo.',
                        style: TextStyle(
                          color: DjColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AuthTextField(
                              label: 'Salario mínimo',
                              hint: 'Ej. 3500000',
                              controller: _salarioMinController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.next,
                              validator: _validateSalarioMin,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AuthTextField(
                              label: 'Salario máximo',
                              hint: 'Ej. 5000000',
                              controller: _salarioMaxController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.next,
                              validator: _validateSalarioMax,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: DjColors.line, height: 1),
                      const SizedBox(height: 18),
                      AuthTextField(
                        label: 'Descripción del puesto',
                        hint:
                            'Describe las responsabilidades principales, requisitos y beneficios del cargo...',
                        controller: _descripcionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        maxLength: 1000,
                        textInputAction: TextInputAction.newline,
                        validator: (value) =>
                            Validators.required(value, 'La descripción'),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: DjColors.line, height: 1),
                      const SizedBox(height: 18),
                      _buildTechnologiesSection(catalogo),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  label: isEditing ? 'Guardar cambios' : 'Publicar vacante',
                  icon: isEditing ? Icons.save_outlined : Icons.add_circle_outline,
                  loading: vacanciesProvider.loading,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: vacanciesProvider.loading
                        ? null
                        : () {
                            vacanciesProvider.clearError();
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
