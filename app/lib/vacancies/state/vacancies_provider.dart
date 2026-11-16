import 'package:flutter/foundation.dart';
import '../data/models.dart';
import '../data/vacancies_error_mapper.dart';
import '../data/vacancies_repository.dart';

class VacanciesProvider extends ChangeNotifier {
  VacanciesProvider({VacanciesRepository? repository})
      : _repository = repository ?? SupabaseVacanciesRepository();

  final VacanciesRepository _repository;

  bool _loading = false;
  String? _error;
  List<Technology> _catalogoTecnologias = [];
  List<Vacancy> _vacantesEmpresa = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Technology> get catalogoTecnologias => _catalogoTecnologias;
  List<Vacancy> get vacantesEmpresa => _vacantesEmpresa;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> cargarCatalogoTecnologias({bool forceRefresh = false}) async {
    if (_catalogoTecnologias.isNotEmpty && !forceRefresh) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _catalogoTecnologias = await _repository.obtenerCatalogoTecnologias();
      _loading = false;
      _error = null;
    } catch (e) {
      _loading = false;
      _error = VacanciesErrorMapper.map(e);
    }
    notifyListeners();
  }

  Future<void> cargarVacantesEmpresa(String empresaId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _vacantesEmpresa = await _repository.obtenerVacantesEmpresa(empresaId);
      _loading = false;
      _error = null;
    } catch (e) {
      _loading = false;
      _error = VacanciesErrorMapper.map(e);
    }
    notifyListeners();
  }

  Future<Vacancy?> guardarVacante({
    required Vacancy vacante,
    required List<String> tecnologiaIds,
  }) async {
    final trimmedTitulo = vacante.titulo.trim();
    final trimmedUbicacion = vacante.ubicacion.trim();
    final trimmedDescripcion = vacante.descripcion.trim();

    if (trimmedTitulo.isEmpty ||
        trimmedUbicacion.isEmpty ||
        trimmedDescripcion.isEmpty) {
      _error = 'Completa todos los campos obligatorios';
      notifyListeners();
      return null;
    }

    if (tecnologiaIds.isEmpty) {
      _error = 'Debes seleccionar al menos una tecnología';
      notifyListeners();
      return null;
    }

    if (vacante.salarioMin != null &&
        vacante.salarioMax != null &&
        vacante.salarioMax! < vacante.salarioMin!) {
      _error = 'El salario máximo no puede ser menor al salario mínimo';
      notifyListeners();
      return null;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    final vacanteSanitizada = vacante.copyWith(
      titulo: trimmedTitulo,
      ubicacion: trimmedUbicacion,
      descripcion: trimmedDescripcion,
    );

    try {
      final Vacancy resultado;
      if (vacante.id == null || vacante.id!.isEmpty) {
        resultado = await _repository.crearVacante(
          vacante: vacanteSanitizada,
          tecnologiaIds: tecnologiaIds,
        );
        _vacantesEmpresa = [resultado, ..._vacantesEmpresa];
      } else {
        resultado = await _repository.actualizarVacante(
          vacante: vacanteSanitizada,
          tecnologiaIds: tecnologiaIds,
        );
        _vacantesEmpresa = _vacantesEmpresa
            .map((v) => v.id == resultado.id ? resultado : v)
            .toList();
      }

      _loading = false;
      _error = null;
      notifyListeners();
      return resultado;
    } catch (e) {
      _loading = false;
      _error = VacanciesErrorMapper.map(e);
      notifyListeners();
      return null;
    }
  }
}
