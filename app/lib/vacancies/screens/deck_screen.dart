import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/data/models.dart';
import '../../auth/state/auth_provider.dart';
import '../../swipes/data/models.dart';
import '../../swipes/state/swipes_provider.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../data/affinity.dart';
import '../data/models.dart';
import '../data/salary_formatter.dart';

class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  bool _initialLoaded = false;
  double _dragDx = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoaded) {
      _initialLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _cargarDeck();
      });
    }
  }

  Future<void> _cargarDeck() async {
    final auth = context.read<AuthProvider>();
    final candidate = auth.candidate;
    if (candidate == null) return;
    await context.read<SwipesProvider>().cargarDeckYSwipes(
          usuarioId: candidate.id,
          candidate: candidate,
        );
  }

  Future<void> _handleSwipe(Vacancy vacante, String direccion) async {
    final auth = context.read<AuthProvider>();
    final swipes = context.read<SwipesProvider>();
    final userId = auth.candidate?.id;
    if (userId == null || swipes.submitting) return;

    setState(() => _dragDx = 0);

    final ok = await swipes.registrarSwipe(
      usuarioId: userId,
      vacante: vacante,
      direccion: direccion,
    );

    if (!mounted) return;
    if (!ok) {
      if (swipes.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(swipes.error!),
            backgroundColor: DjColors.errorInk,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (direccion == SwipeDirections.izquierda) {
      _mostrarUndoSnackBar(vacante.titulo);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  void _mostrarUndoSnackBar(String titulo) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Omitiste $titulo'),
        backgroundColor: DjColors.navy,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 92),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: DjColors.skySoft,
          onPressed: _handleUndo,
        ),
      ),
    );
  }

  Future<void> _handleUndo() async {
    final swipes = context.read<SwipesProvider>();
    if (!swipes.canUndo || swipes.submitting) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => _dragDx = 0);
    await swipes.deshacerUltimoDescarte();
  }

  Future<void> _openDetail(Vacancy vacante) async {
    final result = await Navigator.pushNamed(
      context,
      '/vacancies/detail',
      arguments: vacante,
    );
    if (!mounted) return;
    if (result == SwipeDirections.izquierda) {
      _mostrarUndoSnackBar(vacante.titulo);
    }
  }

  void _onDragEnd(DragEndDetails details, Vacancy vacante) {
    const distanceThreshold = 90.0;
    final velocityX = details.primaryVelocity ?? 0;

    if (_dragDx >= distanceThreshold || velocityX > 500) {
      _handleSwipe(vacante, SwipeDirections.derecha);
    } else if (_dragDx <= -distanceThreshold || velocityX < -500) {
      _handleSwipe(vacante, SwipeDirections.izquierda);
    } else {
      setState(() => _dragDx = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidate = context.watch<AuthProvider>().candidate;
    final swipes = context.watch<SwipesProvider>();
    final deck = swipes.deck;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrostedTop(
        title: const Text(
          'Explorar vacantes',
          style: TextStyle(
            color: DjColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('btn_deck_appbar_prefs'),
            icon: const Icon(Icons.tune, color: DjColors.ink, size: 20),
            tooltip: 'Preferencias laborales',
            onPressed: () =>
                Navigator.pushNamed(context, '/profile/preferences'),
          ),
          IconButton(
            key: const Key('btn_deck_appbar_reload'),
            icon: const Icon(Icons.refresh, color: DjColors.ink, size: 20),
            tooltip: 'Recargar vacantes',
            onPressed: swipes.loading ? null : _cargarDeck,
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(swipes, deck, candidate),
      ),
    );
  }

  Widget _buildBody(
    SwipesProvider swipes,
    List<Vacancy> deck,
    CandidateProfile? candidate,
  ) {
    if (swipes.loading && deck.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(DjColors.navy),
        ),
      );
    }

    if (swipes.error != null && deck.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              FilledButton.icon(
                onPressed: _cargarDeck,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: DjColors.navy,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (deck.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            key: const Key('empty_deck_view'),
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: DjColors.wash,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.style_outlined,
                  size: 40,
                  color: DjColors.navy,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No quedan vacantes por explorar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DjColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ya evaluaste todas las ofertas activas disponibles o puedes ajustar tus preferencias para mejorar tu afinidad.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DjColors.muted,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  key: const Key('btn_deck_reload'),
                  onPressed: _cargarDeck,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Recargar vacantes'),
                  style: FilledButton.styleFrom(
                    backgroundColor: DjColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  key: const Key('btn_deck_preferences'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/profile/preferences'),
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Ajustar preferencias'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DjColors.navy,
                    side: const BorderSide(color: DjColors.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              if (swipes.canUndo) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  key: const Key('btn_deck_empty_undo'),
                  onPressed: _handleUndo,
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('Deshacer último descarte'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final topVacante = deck.first;
    final affinity = calculateVacancyAffinity(
      vacante: topVacante,
      candidate: candidate,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                deck.length == 1
                    ? '1 vacante pendiente'
                    : '${deck.length} vacantes pendientes',
                style: const TextStyle(
                  color: DjColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Toca la tarjeta para ver el detalle',
                style: TextStyle(
                  color: DjColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: GestureDetector(
              key: Key('deck_card_${topVacante.id ?? 'top'}'),
              onTap: () => _openDetail(topVacante),
              onHorizontalDragUpdate: (details) {
                if (swipes.submitting) return;
                setState(() => _dragDx += details.delta.dx);
              },
              onHorizontalDragEnd: (details) => _onDragEnd(details, topVacante),
              onHorizontalDragCancel: () => setState(() => _dragDx = 0),
              child: Transform.translate(
                offset: Offset(_dragDx, 0),
                child: Transform.rotate(
                  angle: (_dragDx / 600).clamp(-0.18, 0.18),
                  child: Stack(
                    children: [
                      _DeckVacancyCard(
                        vacante: topVacante,
                        affinity: affinity,
                      ),
                      if (_dragDx > 24)
                        Positioned(
                          top: 20,
                          left: 20,
                          child: _SwipeStamp(
                            label: 'POSTULAR',
                            color: DjColors.green,
                            bg: DjColors.greenBg,
                          ),
                        ),
                      if (_dragDx < -24)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: _SwipeStamp(
                            label: 'OMITIR',
                            color: DjColors.errorInk,
                            bg: DjColors.errorBg,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DeckActionButton(
                key: const Key('btn_deck_undo'),
                icon: Icons.undo,
                label: 'Deshacer',
                color: DjColors.amberInk,
                bg: DjColors.amberBg,
                onPressed:
                    (swipes.canUndo && !swipes.submitting) ? _handleUndo : null,
              ),
              _DeckActionButton(
                key: const Key('btn_deck_skip'),
                icon: Icons.close,
                label: 'Omitir',
                color: DjColors.errorInk,
                bg: DjColors.errorBg,
                size: 62,
                onPressed: swipes.submitting
                    ? null
                    : () => _handleSwipe(
                          topVacante,
                          SwipeDirections.izquierda,
                        ),
              ),
              _DeckActionButton(
                key: const Key('btn_deck_apply'),
                icon: Icons.favorite_outline,
                label: 'Postular',
                color: DjColors.green,
                bg: DjColors.greenBg,
                size: 62,
                onPressed: swipes.submitting
                    ? null
                    : () => _handleSwipe(
                          topVacante,
                          SwipeDirections.derecha,
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeckVacancyCard extends StatelessWidget {
  final Vacancy vacante;
  final VacancyAffinity affinity;

  const _DeckVacancyCard({
    required this.vacante,
    required this.affinity,
  });

  @override
  Widget build(BuildContext context) {
    final empresaNombre = vacante.empresa?.nombre ?? 'Empresa verificada';
    final empresaMono = vacante.empresa?.monograma ??
        (empresaNombre.isNotEmpty ? empresaNombre[0].toUpperCase() : 'E');

    return DjCard(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CompanyMark(
                  company: empresaNombre,
                  mono: empresaMono,
                  size: 50,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vacante.titulo,
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
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusPill(
                  label: vacante.modalidad,
                  fg: DjColors.blue,
                  bg: DjColors.tint,
                ),
                StatusPill(
                  label: vacante.seniority,
                  fg: DjColors.ink,
                  bg: DjColors.wash,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: DjColors.muted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    vacante.ubicacion,
                    style: const TextStyle(
                      color: DjColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                      color: DjColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (vacante.tecnologias.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Tecnologías requeridas',
                style: TextStyle(
                  color: DjColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vacante.tecnologias.map((tech) {
                  final isMatch = affinity.matchingTechIds.contains(tech.id);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isMatch ? DjColors.navy : DjColors.wash,
                      borderRadius: BorderRadius.circular(14),
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
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: affinity.razones.isNotEmpty
                    ? DjColors.greenBg
                    : DjColors.wash,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: affinity.razones.isNotEmpty
                      ? DjColors.green.withValues(alpha: 0.25)
                      : DjColors.line,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    affinity.razones.isNotEmpty
                        ? 'Por qué te puede interesar'
                        : 'Afinidad con tu perfil',
                    style: TextStyle(
                      color: affinity.razones.isNotEmpty
                          ? DjColors.green
                          : DjColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (affinity.razones.isEmpty)
                    const Text(
                      'Configura tus preferencias y tecnologías para ver tu compatibilidad con esta vacante.',
                      style: TextStyle(
                        color: DjColors.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    )
                  else
                    ...affinity.razones.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '• $r',
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
        ),
      ),
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _SwipeStamp({
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DeckActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final double size;
  final VoidCallback? onPressed;

  const _DeckActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    this.size = 52,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: enabled ? bg : DjColors.wash,
              shape: BoxShape.circle,
              border: Border.all(
                color: enabled ? color.withValues(alpha: 0.35) : DjColors.line,
              ),
            ),
            child: Icon(
              icon,
              color: enabled ? color : DjColors.muted,
              size: size * 0.44,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: enabled ? DjColors.ink : DjColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
