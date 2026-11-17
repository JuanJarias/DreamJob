import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/state/auth_provider.dart';
import '../auth/widgets/auth_error_banner.dart';
import '../auth/widgets/auth_primary_button.dart';
import '../auth/widgets/auth_text_field.dart';
import '../swipes/state/swipes_provider.dart';
import '../theme.dart';
import '../vacancies/data/models.dart';
import '../vacancies/state/vacancies_provider.dart';
import '../widgets/common.dart';

class CandidatePreferencesScreen extends StatefulWidget {
  const CandidatePreferencesScreen({super.key});

  @override
  State<CandidatePreferencesScreen> createState() =>
      _CandidatePreferencesScreenState();
}

class _CandidatePreferencesScreenState
    extends State<CandidatePreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _salarioController = TextEditingController();

  String _modalidad = JobModalities.remoto;
  String _seniority = JobSeniorities.junior;
  final Set<String> _selectedTechIds = {};
  bool _initialized = false;
  String? _techError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final candidate = context.read<AuthProvider>().candidate;
      if (candidate != null) {
        if (candidate.modalidadPreferida != null &&
            JobModalities.values.contains(candidate.modalidadPreferida)) {
          _modalidad = candidate.modalidadPreferida!;
        }
        if (candidate.seniority != null &&
            JobSeniorities.values.contains(candidate.seniority)) {
          _seniority = candidate.seniority!;
        }
        if (candidate.salarioMinimo != null) {
          _salarioController.text = candidate.salarioMinimo.toString();
        }
        _selectedTechIds.addAll(candidate.tecnologias.map((t) => t.id));
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<VacanciesProvider>().cargarCatalogoTecnologias();
      });
    }
  }

  @override
  void dispose() {
    _salarioController.dispose();
    super.dispose();
  }

  String? _validateSalary(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return 'Ingresa un salario numérico válido';
    }
    return null;
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final vacancies = context.read<VacanciesProvider>();
    auth.clearError();

    final formValid = _formKey.currentState?.validate() ?? false;
    if (_selectedTechIds.isEmpty) {
      setState(() {
        _techError = 'Debes seleccionar al menos una tecnología';
      });
    } else {
      setState(() {
        _techError = null;
      });
    }

    if (!formValid || _selectedTechIds.isEmpty) return;

    final trimmedSalary = _salarioController.text.trim();
    final salarioMinimo =
        trimmedSalary.isEmpty ? null : int.parse(trimmedSalary);

    final selectedTechs = vacancies.catalogoTecnologias
        .where((t) => _selectedTechIds.contains(t.id))
        .toList();

    final ok = await auth.updateCandidatePreferences(
      modalidadPreferida: _modalidad,
      salarioMinimo: salarioMinimo,
      seniority: _seniority,
      tecnologias: selectedTechs,
    );

    if (!mounted) return;
    if (ok) {
      context.read<SwipesProvider>().reordenarDeckPorAfinidad(auth.candidate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferencias laborales actualizadas'),
          backgroundColor: DjColors.navy,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final vacancies = context.watch<VacanciesProvider>();
    final catalogo = vacancies.catalogoTecnologias;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrostedTop(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(child: CircleBack(onTap: () => Navigator.pop(context))),
        ),
        title: const Text(
          'Preferencias laborales',
          style: TextStyle(
            color: DjColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHead(
                  title: 'Tu perfil ideal de vacante',
                  sub:
                      'Usamos estas preferencias para resaltar tu compatibilidad y priorizar mejores ofertas en tu deck.',
                ),
                const SizedBox(height: 20),
                if (auth.error != null) ...[
                  AuthErrorBanner(error: auth.error),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Modalidad preferida',
                  style: TextStyle(
                    color: DjColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: JobModalities.values.map((mod) {
                    final selected = _modalidad == mod;
                    return ChoiceChip(
                      key: Key('chip_pref_modalidad_$mod'),
                      label: Text(mod),
                      selected: selected,
                      onSelected: (isSelected) {
                        if (isSelected) setState(() => _modalidad = mod);
                      },
                      selectedColor: DjColors.navy,
                      backgroundColor: DjColors.wash,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : DjColors.ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: selected ? DjColors.navy : DjColors.line,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nivel de experiencia',
                  style: TextStyle(
                    color: DjColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: JobSeniorities.values.map((sen) {
                    final selected = _seniority == sen;
                    return ChoiceChip(
                      key: Key('chip_pref_seniority_$sen'),
                      label: Text(sen),
                      selected: selected,
                      onSelected: (isSelected) {
                        if (isSelected) setState(() => _seniority = sen);
                      },
                      selectedColor: DjColors.navy,
                      backgroundColor: DjColors.wash,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : DjColors.ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: selected ? DjColors.navy : DjColors.line,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  label: 'Expectativa salarial mínima (COP, opcional)',
                  hint: 'Ej. 4000000',
                  controller: _salarioController,
                  prefixIcon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  validator: _validateSalary,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tecnologías que dominas',
                  style: TextStyle(
                    color: DjColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (vacancies.loading && catalogo.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(DjColors.navy),
                      ),
                    ),
                  )
                else if (catalogo.isEmpty)
                  Text(
                    vacancies.error ?? 'No se pudo cargar el catálogo',
                    style: const TextStyle(color: DjColors.errorInk),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: catalogo.map((tech) {
                      final isSelected = _selectedTechIds.contains(tech.id);
                      return FilterChip(
                        key: Key('chip_pref_tech_${tech.nombre}'),
                        label: Text(tech.nombre),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTechIds.add(tech.id);
                            } else {
                              _selectedTechIds.remove(tech.id);
                            }
                            if (_selectedTechIds.isNotEmpty) {
                              _techError = null;
                            }
                          });
                        },
                        selectedColor: DjColors.tint,
                        checkmarkColor: DjColors.navy,
                        backgroundColor: DjColors.wash,
                        labelStyle: TextStyle(
                          color: isSelected ? DjColors.navy : DjColors.ink,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
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
                if (_techError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _techError!,
                    style: const TextStyle(
                      color: DjColors.errorInk,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                AuthPrimaryButton(
                  key: const Key('btn_save_preferences'),
                  label: 'Guardar preferencias',
                  loading: auth.loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
