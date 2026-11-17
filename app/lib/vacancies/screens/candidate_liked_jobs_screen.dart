import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/state/auth_provider.dart';
import '../../swipes/data/models.dart';
import '../../swipes/state/swipes_provider.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'job_detail_screen.dart';

class CandidateLikedJobsScreen extends StatefulWidget {
  const CandidateLikedJobsScreen({super.key});

  @override
  State<CandidateLikedJobsScreen> createState() =>
      _CandidateLikedJobsScreenState();
}

class _CandidateLikedJobsScreenState extends State<CandidateLikedJobsScreen> {
  bool _checkedInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_checkedInitialLoad) {
      _checkedInitialLoad = true;
      final swipes = context.read<SwipesProvider>();
      if (!swipes.initialized && !swipes.loading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _refresh();
        });
      }
    }
  }

  Future<void> _refresh() async {
    final candidate = context.read<AuthProvider>().candidate;
    if (candidate == null) return;
    await context.read<SwipesProvider>().cargarDeckYSwipes(
          usuarioId: candidate.id,
          candidate: candidate,
        );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Postulación reciente';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString().padLeft(4, '0');
    return 'Postulado el $d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    final swipes = context.watch<SwipesProvider>();
    final liked = swipes.likedSwipes;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrostedTop(
        title: const Text(
          'Mis postulaciones',
          style: TextStyle(
            color: DjColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('btn_liked_jobs_refresh'),
            icon: const Icon(Icons.refresh, color: DjColors.ink, size: 20),
            tooltip: 'Actualizar postulaciones',
            onPressed: swipes.loading ? null : _refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: DjColors.navy,
          onRefresh: _refresh,
          child: _buildBody(context, swipes, liked),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SwipesProvider swipes,
    List<SwipeRecord> liked,
  ) {
    if (swipes.loading && liked.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(DjColors.navy),
        ),
      );
    }

    if (swipes.error != null && liked.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: DjColors.errorInk,
          ),
          const SizedBox(height: 16),
          Text(
            swipes.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: DjColors.ink, fontSize: 15),
          ),
          const SizedBox(height: 20),
          Center(
            child: FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: DjColors.navy,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (liked.isEmpty) {
      return ListView(
        key: const Key('empty_liked_jobs_view'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: DjColors.wash,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.work_outline,
                size: 40,
                color: DjColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aún no tienes vacantes de interés',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DjColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Cuando deslices a la derecha o pulses Postular en una oferta del Deck, aparecerá aquí para hacerle seguimiento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DjColors.muted,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      key: const Key('liked_jobs_list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      itemCount: liked.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final swipe = liked[index];
        final vacante = swipe.vacante;
        if (vacante == null) {
          return const SizedBox.shrink();
        }
        final empresaNombre = vacante.empresa?.nombre ?? 'Empresa verificada';
        final empresaMono = vacante.empresa?.monograma ??
            (empresaNombre.isNotEmpty ? empresaNombre[0].toUpperCase() : 'E');

        return InkWell(
          key: Key('liked_job_card_${vacante.id ?? swipe.id}'),
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.pushNamed(
            context,
            '/vacancies/detail',
            arguments: JobDetailArguments(
              vacancy: vacante,
              showActions: false,
            ),
          ),
          child: DjCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CompanyMark(
                      company: empresaNombre,
                      mono: empresaMono,
                      size: 46,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            empresaNombre,
                            style: const TextStyle(
                              color: DjColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vacante.titulo,
                            style: const TextStyle(
                              color: DjColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const StatusPill(
                      label: 'En revisión',
                      fg: DjColors.sky,
                      bg: DjColors.tint,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.work_history_outlined,
                          size: 15,
                          color: DjColors.blue,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          vacante.modalidad,
                          style: const TextStyle(
                            color: DjColors.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: DjColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vacante.ubicacion,
                          style: const TextStyle(
                            color: DjColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: DjColors.line, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: DjColors.muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(swipe.createdAt),
                          style: const TextStyle(
                            color: DjColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: DjColors.muted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
