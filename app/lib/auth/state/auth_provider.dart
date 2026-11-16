import 'dart:async';

import 'package:flutter/foundation.dart';
import '../data/auth_error_mapper.dart';
import '../data/auth_repository.dart';
import '../data/models.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? SupabaseAuthRepository() {
    unawaited(_restoreSession());
  }

  final AuthRepository _repository;

  bool _loading = true;
  String? _error;
  UserRole? _role;
  CandidateProfile? _candidate;
  RecruiterProfile? _recruiter;

  bool get loading => _loading;
  String? get error => _error;
  UserRole? get role => _role;
  CandidateProfile? get candidate => _candidate;
  RecruiterProfile? get recruiter => _recruiter;
  bool get isAuthenticated => _role != null;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> _restoreSession() async {
    final session = _repository.currentSession;
    if (session == null) {
      _loading = false;
      notifyListeners();
      return;
    }

    try {
      final role = _rolDesdeMetadata(session.user.userMetadata);
      await _cargarPerfil(role, session.user.id);
    } catch (error) {
      // Un fallo de red al cargar el perfil no debe borrar la sesión persistida.
      _error = AuthErrorMapper.map(error);
      _role = null;
      _candidate = null;
      _recruiter = null;
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      _error = 'Completa todos los campos obligatorios';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.signIn(
        email: normalizedEmail,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw Exception('No se pudo iniciar sesión');
      }
      final role = _rolDesdeMetadata(user.userMetadata);
      await _cargarPerfil(role, user.id);
      _loading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (error) {
      _loading = false;
      _error = AuthErrorMapper.map(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpCandidate({
    required String nombre,
    required String email,
    required String password,
    required String ciudad,
    required DateTime fechaNacimiento,
    String? resumenPerfil,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (nombre.trim().isEmpty ||
        normalizedEmail.isEmpty ||
        password.isEmpty ||
        ciudad.trim().isEmpty) {
      _error = 'Completa todos los campos obligatorios';
      notifyListeners();
      return false;
    }
    if (password.length < 8) {
      _error = 'La contraseña debe tener al menos 8 caracteres';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.signUp(
        email: normalizedEmail,
        password: password,
        data: {'role': UserRole.candidato.name},
      );
      final user = response.user;
      if (user == null) {
        throw Exception('No se pudo crear la cuenta');
      }

      final trimmedResumen = resumenPerfil?.trim();
      final profile = CandidateProfile(
        id: user.id,
        nombre: nombre.trim(),
        email: normalizedEmail,
        ciudad: ciudad.trim(),
        fechaNacimiento: fechaNacimiento,
        resumenPerfil: (trimmedResumen == null || trimmedResumen.isEmpty)
            ? null
            : trimmedResumen,
      );
      await _repository.crearUsuario(profile.toMap());

      _role = UserRole.candidato;
      _candidate = profile;
      _recruiter = null;
      _loading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (error) {
      _loading = false;
      _error = AuthErrorMapper.map(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpRecruiter({
    required String nombre,
    required String email,
    required String password,
    required String empresaNombre,
    required String empresaDescripcion,
    required String empresaMonograma,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (nombre.trim().isEmpty ||
        normalizedEmail.isEmpty ||
        password.isEmpty ||
        empresaNombre.trim().isEmpty ||
        empresaDescripcion.trim().isEmpty ||
        empresaMonograma.trim().isEmpty) {
      _error = 'Completa todos los campos obligatorios';
      notifyListeners();
      return false;
    }
    if (password.length < 8) {
      _error = 'La contraseña debe tener al menos 8 caracteres';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.signUp(
        email: normalizedEmail,
        password: password,
        data: {'role': UserRole.reclutador.name},
      );
      final user = response.user;
      if (user == null) {
        throw Exception('No se pudo crear la cuenta');
      }

      await _repository.registrarReclutador(
        nombre: nombre.trim(),
        email: normalizedEmail,
        empresaNombre: empresaNombre.trim(),
        empresaDescripcion: empresaDescripcion.trim(),
        empresaMonograma: empresaMonograma.trim().toUpperCase(),
      );

      await _cargarPerfil(UserRole.reclutador, user.id);
      _loading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (error) {
      _loading = false;
      _error = AuthErrorMapper.map(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCandidateProfile({
    required String nombre,
    required String ciudad,
    String? resumenPerfil,
  }) async {
    final current = _candidate;
    if (current == null) {
      _error = 'No se encontró el perfil de candidato';
      notifyListeners();
      return false;
    }

    final trimmedNombre = nombre.trim();
    final trimmedCiudad = ciudad.trim();
    final trimmedResumen = resumenPerfil?.trim();

    if (trimmedNombre.isEmpty || trimmedCiudad.isEmpty) {
      _error = 'Completa todos los campos obligatorios';
      notifyListeners();
      return false;
    }

    if (trimmedResumen != null && trimmedResumen.length > 280) {
      _error = 'El resumen profesional no puede superar los 280 caracteres';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final sanitizedResumen =
          (trimmedResumen == null || trimmedResumen.isEmpty)
              ? null
              : trimmedResumen;

      await _repository.actualizarUsuario(
        id: current.id,
        datos: {
          'nombre': trimmedNombre,
          'ciudad': trimmedCiudad,
          'resumen_perfil': sanitizedResumen,
        },
      );

      _candidate = CandidateProfile(
        id: current.id,
        nombre: trimmedNombre,
        email: current.email,
        ciudad: trimmedCiudad,
        fechaNacimiento: current.fechaNacimiento,
        resumenPerfil: sanitizedResumen,
      );
      _loading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (error) {
      _loading = false;
      _error = AuthErrorMapper.map(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRecruiterProfile({
    required String nombre,
    required String empresaNombre,
    required String empresaDescripcion,
    required String empresaMonograma,
  }) async {
    final current = _recruiter;
    if (current == null) {
      _error = 'No se encontró el perfil de reclutador';
      notifyListeners();
      return false;
    }

    final trimmedNombre = nombre.trim();
    final trimmedEmpresaNombre = empresaNombre.trim();
    final trimmedEmpresaDesc = empresaDescripcion.trim();
    final trimmedMonograma = empresaMonograma.trim().toUpperCase();

    if (trimmedNombre.isEmpty ||
        trimmedEmpresaNombre.isEmpty ||
        trimmedEmpresaDesc.isEmpty ||
        trimmedMonograma.isEmpty) {
      _error = 'Completa todos los campos obligatorios';
      notifyListeners();
      return false;
    }

    if (trimmedEmpresaDesc.length > 280) {
      _error =
          'La descripción de la empresa no puede superar los 280 caracteres';
      notifyListeners();
      return false;
    }

    if (trimmedMonograma.isEmpty ||
        trimmedMonograma.length > 3 ||
        !RegExp(r'^[A-ZÁÉÍÓÚÑ]+$').hasMatch(trimmedMonograma)) {
      _error = 'El monograma debe tener entre 1 y 3 letras';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.actualizarReclutadorYEmpresa(
        reclutadorId: current.id,
        nombre: trimmedNombre,
        empresaId: current.empresa.id,
        empresaNombre: trimmedEmpresaNombre,
        empresaDescripcion: trimmedEmpresaDesc,
        empresaMonograma: trimmedMonograma,
      );

      _recruiter = RecruiterProfile(
        id: current.id,
        nombre: trimmedNombre,
        email: current.email,
        empresa: CompanyProfile(
          id: current.empresa.id,
          nombre: trimmedEmpresaNombre,
          descripcion: trimmedEmpresaDesc,
          monograma: trimmedMonograma,
        ),
      );
      _loading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (error) {
      _loading = false;
      _error = AuthErrorMapper.map(error);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.signOut();
      _role = null;
      _candidate = null;
      _recruiter = null;
    } catch (error) {
      _error = AuthErrorMapper.map(error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _cargarPerfil(UserRole role, String userId) async {
    if (role == UserRole.candidato) {
      final datos = await _repository.obtenerUsuario(userId);
      _candidate = CandidateProfile.fromMap(datos);
      _recruiter = null;
    } else {
      final datos = await _repository.obtenerReclutadorConEmpresa(userId);
      _recruiter = RecruiterProfile.fromMap(datos);
      _candidate = null;
    }
    _role = role;
  }

  UserRole _rolDesdeMetadata(Map<String, dynamic>? metadata) {
    final valor = metadata?['role'] as String?;
    if (valor == null) {
      throw Exception('El usuario no tiene un rol asignado');
    }
    return UserRole.values.byName(valor);
  }
}
