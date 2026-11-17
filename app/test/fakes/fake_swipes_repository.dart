import 'package:dreamjob/swipes/data/models.dart';
import 'package:dreamjob/swipes/data/swipes_repository.dart';
import 'package:dreamjob/vacancies/data/models.dart';

class FakeSwipesRepository implements SwipesRepository {
  FakeSwipesRepository({List<SwipeRecord>? swipesIniciales})
      : _swipes = List<SwipeRecord>.from(swipesIniciales ?? const []);

  final List<SwipeRecord> _swipes;
  int _secuenciaId = 1;

  bool shouldThrow = false;
  Object? errorToThrow;

  bool registrarSwipeLlamado = false;
  bool eliminarSwipeLlamado = false;
  SwipeRecord? ultimoSwipeRegistrado;
  String? ultimoSwipeEliminadoId;

  void _checkError() {
    if (shouldThrow) {
      throw errorToThrow ?? Exception('Error simulado en FakeSwipesRepository');
    }
  }

  @override
  Future<List<SwipeRecord>> obtenerSwipesCandidato(String usuarioId) async {
    _checkError();
    return _swipes.where((s) => s.usuarioId == usuarioId).toList();
  }

  @override
  Future<SwipeRecord> registrarSwipe({
    required String usuarioId,
    required String vacanteId,
    required String direccion,
  }) async {
    _checkError();
    registrarSwipeLlamado = true;
    final created = SwipeRecord(
      id: 'fake-swipe-${_secuenciaId++}',
      usuarioId: usuarioId,
      vacanteId: vacanteId,
      direccion: direccion,
      createdAt: DateTime.now(),
    );
    _swipes.insert(0, created);
    ultimoSwipeRegistrado = created;
    return created;
  }

  @override
  Future<void> eliminarSwipe(String swipeId) async {
    _checkError();
    eliminarSwipeLlamado = true;
    ultimoSwipeEliminadoId = swipeId;
    _swipes.removeWhere((s) => s.id == swipeId);
  }

  List<SwipeRecord> get snapshot => List<SwipeRecord>.unmodifiable(_swipes);

  void seedSwipe(SwipeRecord swipe, {Vacancy? vacante}) {
    _swipes.add(swipe.copyWith(vacante: vacante));
  }
}
