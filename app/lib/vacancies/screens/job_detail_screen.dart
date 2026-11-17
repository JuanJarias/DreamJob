import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/state/auth_provider.dart';
import '../../swipes/data/models.dart';
import '../../swipes/state/swipes_provider.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../data/affinity.dart';
import '../data/models.dart';
import '../data/salary_formatter.dart';

class JobDetailArguments {
  final Vacancy vacancy;
  final bool showActions;

  const JobDetailArguments({
    required this.vacancy,
    this.showActions = true,
  });
}

class JobDetailScreen extends StatelessWidget {
  final Vacancy vacancy;
  final bool showActions;

  const JobDetailScreen({
    super.key,
    required this.vacancy,
    this.showActions = true,
  });

  Future<void> _registrarDecision(
    BuildContext context,
    String direccion,
  ) async {
    final auth = context.read<AuthProvider>();
    final swipes = context.read<SwipesProvider>();
    final userId = auth.candidate?.id;
    if (userId == null) return;

    final ok = await swipes.registrarSwipe(
      usuarioId: userId,
      vacante: vacancy,
      direccion: direccion,
    );

    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context, direccion);
    } else if (swipes.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(swipes.error!),
          backgroundColor: DjColors.errorInk,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidate = context.watch<AuthProvider>().candidate;
    final swipes = context.watch<SwipesProvider>();
    final affinity = calculateVacancyAffinity(
      vacante: vacancy,
      candidate: candidate,
    );

    final empresaNombre = vacancy.empresa?.nombre ?? 'Empresa verificada';
    final empresaMono = vacancy.empresa?.monograma ??
        (empresaNombre.isNotEmpty ? empresaNombre[0].toUpperCase() : 'E');
    final empresaDesc = vacancy.empresa?.descripcion ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrostedTop(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(child: CircleBack(onTap: () => Navigator.pop(context))),
        ),
        title: const Text(
          'Detalle de la vacante',
          style: TextStyle(
            color: DjColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DjCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CompanyMark(
                          company: empresaNombre,
                          mono: empresaMono,
                          size: 52,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                empresaNombre,
                                style: const TextStyle(
                                  color: DjColors.muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vacancy.titulo,
                                style: const TextStyle(
                                  color: DjColors.ink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (empresaDesc.trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Divider(color: DjColors.line, height: 1),
                      const SizedBox(height: 12),
                      Text(
                        empresaDesc,
                        style: const TextStyle(
                          color: DjColors.muted,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DjCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusPill(
                          label: vacancy.modalidad,
                          fg: DjColors.blue,
                          bg: DjColors.tint,
                        ),
                        StatusPill(
                          label: vacancy.seniority,
                          fg: DjColors.ink,
                          bg: DjColors.wash,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _DetailInfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Ubicación',
                      value: vacancy.ubicacion,
                    ),
                    const SizedBox(height: 12),
                    _DetailInfoRow(
                      icon: Icons.payments_outlined,
                      label: 'Compensación',
                      value: formatVacancySalary(
                        vacancy.salarioMin,
                        vacancy.salarioMax,
                        vacancy.moneda,
                      ),
                    ),
                  ],
                ),
              ),
              if (affinity.razones.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DjColors.greenBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: DjColors.green.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 18,
                            color: DjColors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Afinidad con tu perfil',
                            style: TextStyle(
                              color: DjColors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...affinity.razones.map(
                        (razon) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $razon',
                            style: const TextStyle(
                              color: DjColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              DjCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tecnologías requeridas',
                      style: TextStyle(
                        color: DjColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (vacancy.tecnologias.isEmpty)
                      const Text(
                        'Sin tecnologías especificadas',
                        style: TextStyle(color: DjColors.muted, fontSize: 13),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: vacancy.tecnologias.map((tech) {
                          final isMatch =
                              affinity.matchingTechIds.contains(tech.id);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isMatch ? DjColors.navy : DjColors.wash,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isMatch ? DjColors.navy : DjColors.line,
                              ),
                            ),
                            child: Text(
                              tech.nombre,
                              style: TextStyle(
                                color: isMatch ? Colors.white : DjColors.ink,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DjCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descripción del puesto',
                      style: TextStyle(
                        color: DjColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      vacancy.descripcion,
                      style: const TextStyle(
                        color: DjColors.ink,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: showActions
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: DjColors.line)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          key: const Key('btn_detail_skip'),
                          onPressed: swipes.submitting
                              ? null
                              : () => _registrarDecision(
                                    context,
                                    SwipeDirections.izquierda,
                                  ),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Omitir'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DjColors.errorInk,
                            side: const BorderSide(color: DjColors.errorLine),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: FilledButton.icon(
                          key: const Key('btn_detail_apply'),
                          onPressed: swipes.submitting
                              ? null
                              : () => _registrarDecision(
                                    context,
                                    SwipeDirections.derecha,
                                  ),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Postular'),
                          style: FilledButton.styleFrom(
                            backgroundColor: DjColors.navy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: DjColors.sky),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: DjColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: DjColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
