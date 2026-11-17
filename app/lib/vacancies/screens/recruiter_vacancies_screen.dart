import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/state/auth_provider.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../data/models.dart';
import '../data/salary_formatter.dart';
import '../state/vacancies_provider.dart';

class RecruiterVacanciesScreen extends StatefulWidget {
  const RecruiterVacanciesScreen({super.key});

  @override
  State<RecruiterVacanciesScreen> createState() =>
      _RecruiterVacanciesScreenState();
}

class _RecruiterVacanciesScreenState extends State<RecruiterVacanciesScreen> {
  bool _initialLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoaded) {
      _initialLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadVacancies();
      });
    }
  }

  void _loadVacancies() {
    final auth = context.read<AuthProvider>();
    final empresaId = auth.recruiter?.empresa.id;
    if (empresaId != null && empresaId.isNotEmpty) {
      context.read<VacanciesProvider>().cargarVacantesEmpresa(empresaId);
    }
  }

  Future<void> _handleRefresh() async {
    final auth = context.read<AuthProvider>();
    final empresaId = auth.recruiter?.empresa.id;
    if (empresaId != null && empresaId.isNotEmpty) {
      await context.read<VacanciesProvider>().cargarVacantesEmpresa(empresaId);
    }
  }

  Future<void> _navigateToNew() async {
    final result = await Navigator.of(context).pushNamed('/vacancies/new');
    if (result == true && mounted) {
      _handleRefresh();
    }
  }

  Future<void> _navigateToEdit(Vacancy vacante) async {
    final result = await Navigator.of(
      context,
    ).pushNamed('/vacancies/edit', arguments: vacante);
    if (result == true && mounted) {
      _handleRefresh();
    }
  }

  Future<void> _cambiarEstado(Vacancy vacante, String nuevoEstado) async {
    if (vacante.estado == nuevoEstado) return;
    final success = await context.read<VacanciesProvider>().cambiarEstadoVacante(
      vacanteId: vacante.id!,
      nuevoEstado: nuevoEstado,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado de la vacante actualizado a "$nuevoEstado"'),
          backgroundColor: DjColors.navy,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final vacanciesProvider = context.watch<VacanciesProvider>();
    final vacantes = vacanciesProvider.vacantesEmpresa;
    final isLoading = vacanciesProvider.loading;
    final error = vacanciesProvider.error;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrostedTop(
        title: const Text(
          'Mis vacantes',
          style: TextStyle(
            color: DjColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('btn_appbar_publish_vacancy'),
            icon: const Icon(Icons.add_circle_outline, color: DjColors.navy),
            tooltip: 'Publicar vacante',
            onPressed: _navigateToNew,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('btn_publish_vacancy'),
        onPressed: _navigateToNew,
        backgroundColor: DjColors.navy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Publicar vacante',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: DjColors.navy,
          onRefresh: _handleRefresh,
          child: _buildBody(
            auth: auth,
            isLoading: isLoading,
            error: error,
            vacantes: vacantes,
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required AuthProvider auth,
    required bool isLoading,
    required String? error,
    required List<Vacancy> vacantes,
  }) {
    if (isLoading && vacantes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(DjColors.navy),
        ),
      );
    }

    if (error != null && vacantes.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: DjColors.errorBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: DjColors.errorInk,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DjColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _handleRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DjColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (vacantes.isEmpty) {
      return Center(
        key: const Key('empty_vacancies_view'),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: DjColors.wash,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business_center_outlined,
                  size: 42,
                  color: DjColors.navy,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No tienes vacantes publicadas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DjColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Publica tu primera oferta laboral para comenzar a atraer y evaluar candidatos compatibles.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DjColors.muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  key: const Key('btn_empty_publish_vacancy'),
                  onPressed: _navigateToNew,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Publicar primera vacante'),
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
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      key: const Key('recruiter_vacancies_list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      itemCount: vacantes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final vacante = vacantes[index];
        return _VacancyCard(
          key: Key('vacancy_card_${vacante.id ?? index}'),
          vacante: vacante,
          onEdit: () => _navigateToEdit(vacante),
          onStatusChange: (nuevoEstado) => _cambiarEstado(vacante, nuevoEstado),
        );
      },
    );
  }
}

class _VacancyCard extends StatelessWidget {
  final Vacancy vacante;
  final VoidCallback onEdit;
  final ValueChanged<String> onStatusChange;

  const _VacancyCard({
    super.key,
    required this.vacante,
    required this.onEdit,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(24),
      child: DjCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vacante.titulo,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: DjColors.ink,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: DjColors.muted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                vacante.ubicacion,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: DjColors.muted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: DjColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.work_outline,
                                size: 14,
                                color: DjColors.muted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                vacante.modalidad,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: DjColors.muted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  key: Key('status_menu_${vacante.id}'),
                  tooltip: 'Opciones de vacante',
                  icon: const Icon(Icons.more_vert, color: DjColors.muted),
                  onSelected: (val) {
                    if (val == 'editar') {
                      onEdit();
                    } else {
                      onStatusChange(val);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      enabled: false,
                      child: Text(
                        'CAMBIAR ESTADO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: DjColors.muted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: VacancyStatuses.activa,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: vacante.estado == VacancyStatuses.activa
                                ? DjColors.green
                                : DjColors.muted,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Activa',
                            style: TextStyle(
                              fontWeight:
                                  vacante.estado == VacancyStatuses.activa
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: vacante.estado == VacancyStatuses.activa
                                  ? DjColors.green
                                  : DjColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: VacancyStatuses.pausada,
                      child: Row(
                        children: [
                          Icon(
                            Icons.pause_circle_outline,
                            size: 18,
                            color: vacante.estado == VacancyStatuses.pausada
                                ? DjColors.amberInk
                                : DjColors.muted,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Pausada',
                            style: TextStyle(
                              fontWeight:
                                  vacante.estado == VacancyStatuses.pausada
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: vacante.estado == VacancyStatuses.pausada
                                  ? DjColors.amberInk
                                  : DjColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: VacancyStatuses.cerrada,
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            size: 18,
                            color: vacante.estado == VacancyStatuses.cerrada
                                ? DjColors.ink
                                : DjColors.muted,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Cerrada',
                            style: TextStyle(
                              fontWeight:
                                  vacante.estado == VacancyStatuses.cerrada
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: DjColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: DjColors.blue,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Editar vacante',
                            style: TextStyle(color: DjColors.blue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusBadge(
                  key: Key('status_badge_${vacante.id}'),
                  estado: vacante.estado,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DjColors.tint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vacante.seniority,
                    style: const TextStyle(
                      color: DjColors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 16,
                  color: DjColors.sky,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    formatVacancySalary(
                      vacante.salarioMin,
                      vacante.salarioMax,
                      vacante.moneda,
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: DjColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            if (vacante.tecnologias.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: vacante.tecnologias.map((tech) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: DjColors.wash,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: DjColors.line),
                    ),
                    child: Text(
                      tech.nombre,
                      style: const TextStyle(
                        color: DjColors.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 14),
            const Divider(color: DjColors.line, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: DjColors.tint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.thumb_up_alt_outlined,
                        size: 15,
                        color: DjColors.blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${vacante.candidatosInteresados} ${vacante.candidatosInteresados == 1 ? 'candidato interesado' : 'candidatos interesados'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: DjColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  key: Key('btn_edit_card_${vacante.id}'),
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Editar'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: DjColors.wash,
                    foregroundColor: DjColors.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String estado;

  const _StatusBadge({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    IconData icon;
    String label;

    switch (estado.toLowerCase()) {
      case 'activa':
        bg = DjColors.greenBg;
        fg = DjColors.green;
        border = DjColors.green.withValues(alpha: 0.3);
        icon = Icons.check_circle_outline;
        label = 'Activa';
        break;
      case 'pausada':
        bg = DjColors.amberBg;
        fg = DjColors.amberInk;
        border = DjColors.amberLine;
        icon = Icons.pause_circle_outline;
        label = 'Pausada';
        break;
      case 'cerrada':
      default:
        bg = DjColors.wash;
        fg = DjColors.muted;
        border = DjColors.line;
        icon = Icons.cancel_outlined;
        label = 'Cerrada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
