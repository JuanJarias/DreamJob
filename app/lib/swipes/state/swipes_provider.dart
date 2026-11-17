import 'package:flutter/foundation.dart';
import '../../auth/data/models.dart';
import '../../vacancies/data/affinity.dart';
import '../../vacancies/data/models.dart';
import '../../vacancies/data/vacancies_error_mapper.dart';
import '../../vacancies/data/vacancies_repository.dart';
import '../data/models.dart';
import '../data/swipes_repository.dart';

class SwipesProvider extends ChangeNotifier {
  SwipesProvider({
    SwipesRepository? swipesRepository,
    VacanciesRepository? vacanciesRepository,
  })  : _swipesRepository = swipesRepository ?? SupabaseSwipesRepository(),
        _vacanciesRepository =
            vacanciesRepository ?? SupabaseVacanciesRepository();

  final SwipesRepository _swipesRepository;
  final VacanciesRepository _vacanciesRepository;

  bool _loading = false;
  bool _submitting = false;
  bool _initialized = false;
  String? _error;
  List<Vacancy> _deck = [];
  List<SwipeRecord> _swipes = [];
  SwipeRecord? _lastSkippedSwipe;
  Vacancy? _lastSkippedVacancy;

  bool get loading => _loading;
  bool get submitting => _submitting;
  bool get initialized => _initialized;
  String? get error => _error;
  List<Vacancy> get deck => _deck;
  List<SwipeRecord> get swipes => _swipes;
  List<SwipeRecord> get likedSwipes {
    final liked = _swipes
        .where((s) => s.direccion == SwipeDirections.derecha)
        .toList();
    liked.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return liked;
  }
  SwipeRecord? get lastSkippedSwipe => _lastSkippedSwipe;
  bool get canUndo => _lastSkippedSwipe != null && _lastSkippedVacancy != null;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> cargarDeckYSwipes({
    required String usuarioId,
    CandidateProfile? candidate,
  }) async {
    _loading = true;
    _initialized = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _vacanciesRepository.obtenerVacantesActivas(),
        _swipesRepository.obtenerSwipesCandidato(usuarioId),
      ]);

      final activas = results[0] as List<Vacancy>;
      final swipesCandidato = results[1] as List<SwipeRecord>;

      final evaluadasIds = swipesCandidato.map((s) => s.vacanteId).toSet();
      final pendientes = activas
          .where((v) => v.id != null && !evaluadasIds.contains(v.id))
          .toList();

      _swipes = swipesCandidato;
      _deck = _ordenarPorAfinidad(pendientes, candidate);
      _loading = false;
      _error = null;
    } catch (e) {
      _loading = false;
      _error = VacanciesErrorMapper.map(e);
    }
    notifyListeners();
  }

  void reordenarDeckPorAfinidad(CandidateProfile? candidate) {
    if (_deck.isEmpty) return;
    _deck = _ordenarPorAfinidad(_deck, candidate);
    notifyListeners();
  }

  Future<bool> registrarSwipe({
    required String usuarioId,
    required Vacancy vacante,
    required String direccion,
  }) async {
    final vacanteId = vacante.id;
    if (vacanteId == null || vacanteId.isEmpty) {
      _error = 'La vacante seleccionada no es válida';
      notifyListeners();
      return false;
    }

    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _swipesRepository.registrarSwipe(
        usuarioId: usuarioId,
        vacanteId: vacanteId,
        direccion: direccion,
      );
      final recordWithVacancy = created.copyWith(vacante: vacante);

      _swipes = [recordWithVacancy, ..._swipes];
      _deck = _deck.where((v) => v.id != vacanteId).toList();

      if (direccion == SwipeDirections.izquierda) {
        _lastSkippedSwipe = recordWithVacancy;
        _lastSkippedVacancy = vacante;
      } else {
        _lastSkippedSwipe = null;
        _lastSkippedVacancy = null;
      }

      _submitting = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _submitting = false;
      _error = VacanciesErrorMapper.map(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deshacerUltimoDescarte() async {
    final swipe = _lastSkippedSwipe;
    final vacante = _lastSkippedVacancy;
    if (swipe == null || vacante == null) {
      return false;
    }

    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await _swipesRepository.eliminarSwipe(swipe.id);

      _swipes = _swipes.where((s) => s.id != swipe.id).toList();
      _deck = [vacante, ..._deck.where((v) => v.id != vacante.id)];
      _lastSkippedSwipe = null;
      _lastSkippedVacancy = null;
      _submitting = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _submitting = false;
      _error = VacanciesErrorMapper.map(e);
      notifyListeners();
      return false;
    }
  }

  List<Vacancy> _ordenarPorAfinidad(
    List<Vacancy> vacantes,
    CandidateProfile? candidate,
  ) {
    final list = List<Vacancy>.from(vacantes);
    if (candidate == null) return list;

    list.sort((a, b) {
      final scoreA =
          calculateVacancyAffinity(vacante: a, candidate: candidate).score;
      final scoreB =
          calculateVacancyAffinity(vacante: b, candidate: candidate).score;
      return scoreB.compareTo(scoreA);
    });
    return list;
  }
}
