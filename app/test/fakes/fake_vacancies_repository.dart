import 'package:dreamjob/vacancies/data/models.dart';
import 'package:dreamjob/vacancies/data/vacancies_repository.dart';

/// Implementación en memoria de [VacanciesRepository] para pruebas unitarias y de widgets.
class FakeVacanciesRepository implements VacanciesRepository {
  FakeVacanciesRepository({
    List<Vacancy>? vacantesIniciales,
    List<Technology>? catalogoInicial,
  })  : _vacantes = List<Vacancy>.from(vacantesIniciales ?? const []),
        _catalogo = List<Technology>.from(
          catalogoInicial ?? _catalogoPorDefecto,
        );

  static const List<Technology> _catalogoPorDefecto = [
    Technology(id: 't-flutter', nombre: 'Flutter', categoria: 'Móvil'),
    Technology(id: 't-dart', nombre: 'Dart', categoria: 'Móvil'),
    Technology(id: 't-kotlin', nombre: 'Kotlin', categoria: 'Móvil'),
    Technology(id: 't-python', nombre: 'Python', categoria: 'Backend / Datos'),
    Technology(id: 't-go', nombre: 'Go', categoria: 'Backend'),
    Technology(id: 't-nodejs', nombre: 'Node.js', categoria: 'Backend'),
    Technology(id: 't-java', nombre: 'Java', categoria: 'Backend'),
    Technology(id: 't-react', nombre: 'React', categoria: 'Frontend'),
    Technology(id: 't-typescript', nombre: 'TypeScript', categoria: 'Frontend'),
    Technology(
      id: 't-postgresql',
      nombre: 'PostgreSQL',
      categoria: 'Bases de datos',
    ),
    Technology(id: 't-sql', nombre: 'SQL', categoria: 'Bases de datos'),
    Technology(id: 't-aws', nombre: 'AWS', categoria: 'Cloud / DevOps'),
    Technology(id: 't-docker', nombre: 'Docker', categoria: 'Cloud / DevOps'),
    Technology(id: 't-git', nombre: 'Git', categoria: 'Herramientas'),
  ];

  final List<Vacancy> _vacantes;
  final List<Technology> _catalogo;
  int _secuenciaId = 1;

  bool shouldThrow = false;
  Object? errorToThrow;

  bool crearVacanteLlamado = false;
  bool actualizarVacanteLlamado = false;
  bool cambiarEstadoLlamado = false;

  Vacancy? ultimaVacanteCreada;
  List<String>? ultimasTecnologiasCreadas;
  Vacancy? ultimaVacanteActualizada;
  List<String>? ultimasTecnologiasActualizadas;
  String? ultimoEstadoCambiado;

  void _checkError() {
    if (shouldThrow) {
      throw errorToThrow ?? Exception('Error simulado en FakeVacanciesRepository');
    }
  }

  List<Technology> _resolverTecnologias(List<String> tecnologiaIds) {
    return tecnologiaIds.map((id) {
      for (final tech in _catalogo) {
        if (tech.id == id) return tech;
      }
      return Technology(id: id, nombre: id);
    }).toList();
  }

  @override
  Future<List<Technology>> obtenerCatalogoTecnologias() async {
    _checkError();
    return List<Technology>.from(_catalogo);
  }

  @override
  Future<Vacancy> crearVacante({
    required Vacancy vacante,
    required List<String> tecnologiaIds,
  }) async {
    _checkError();
    crearVacanteLlamado = true;
    final tecnologias = _resolverTecnologias(tecnologiaIds);
    final nueva = vacante.copyWith(
      id: vacante.id ?? 'fake-vac-${_secuenciaId++}',
      createdAt: vacante.createdAt ?? DateTime.now(),
      tecnologias: tecnologias,
    );
    _vacantes.insert(0, nueva);
    ultimaVacanteCreada = nueva;
    ultimasTecnologiasCreadas = List<String>.from(tecnologiaIds);
    return nueva;
  }

  @override
  Future<Vacancy> actualizarVacante({
    required Vacancy vacante,
    required List<String> tecnologiaIds,
  }) async {
    _checkError();
    actualizarVacanteLlamado = true;
    final tecnologias = _resolverTecnologias(tecnologiaIds);
    final actualizada = vacante.copyWith(tecnologias: tecnologias);
    final idx = _vacantes.indexWhere((v) => v.id == vacante.id);
    if (idx != -1) {
      _vacantes[idx] = actualizada;
    } else {
      _vacantes.insert(0, actualizada);
    }
    ultimaVacanteActualizada = actualizada;
    ultimasTecnologiasActualizadas = List<String>.from(tecnologiaIds);
    return actualizada;
  }

  @override
  Future<List<Vacancy>> obtenerVacantesEmpresa(String empresaId) async {
    _checkError();
    return _vacantes.where((v) => v.empresaId == empresaId).toList();
  }

  @override
  Future<List<Vacancy>> obtenerVacantesActivas() async {
    _checkError();
    return _vacantes
        .where((v) => v.estado == VacancyStatuses.activa)
        .toList();
  }

  @override
  Future<Vacancy?> obtenerVacantePorId(String id) async {
    _checkError();
    for (final v in _vacantes) {
      if (v.id == id) return v;
    }
    return null;
  }

  @override
  Future<Vacancy> cambiarEstadoVacante({
    required String vacanteId,
    required String nuevoEstado,
  }) async {
    _checkError();
    cambiarEstadoLlamado = true;
    ultimoEstadoCambiado = nuevoEstado;
    final idx = _vacantes.indexWhere((v) => v.id == vacanteId);
    if (idx == -1) {
      throw Exception('Vacante no encontrada: $vacanteId');
    }
    final actualizada = _vacantes[idx].copyWith(estado: nuevoEstado);
    _vacantes[idx] = actualizada;
    return actualizada;
  }
}
