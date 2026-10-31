import 'package:flutter/foundation.dart';
import '../data/models.dart';

class _StubAccount {
  final String password;
  final UserRole role;
  final CandidateProfile? candidate;
  final RecruiterProfile? recruiter;

  const _StubAccount({
    required this.password,
    required this.role,
    this.candidate,
    this.recruiter,
  });
}

class AuthProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  UserRole? _role;
  CandidateProfile? _candidate;
  RecruiterProfile? _recruiter;

  final Map<String, _StubAccount> _accounts = {};

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

    await Future<void>.delayed(const Duration(milliseconds: 250));

    final account = _accounts[normalizedEmail];
    if (account == null || account.password != password) {
      _loading = false;
      _error = 'Correo electrónico o contraseña incorrectos';
      notifyListeners();
      return false;
    }

    _role = account.role;
    _candidate = account.candidate;
    _recruiter = account.recruiter;
    _loading = false;
    _error = null;
    notifyListeners();
    return true;
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

    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (_accounts.containsKey(normalizedEmail)) {
      _loading = false;
      _error = 'Este correo electrónico ya está registrado';
      notifyListeners();
      return false;
    }

    final trimmedResumen = resumenPerfil?.trim();
    final profile = CandidateProfile(
      id: 'cand-${_accounts.length + 1}',
      nombre: nombre.trim(),
      email: normalizedEmail,
      ciudad: ciudad.trim(),
      fechaNacimiento: fechaNacimiento,
      resumenPerfil:
          (trimmedResumen == null || trimmedResumen.isEmpty)
              ? null
              : trimmedResumen,
    );

    _accounts[normalizedEmail] = _StubAccount(
      password: password,
      role: UserRole.candidato,
      candidate: profile,
    );

    _role = UserRole.candidato;
    _candidate = profile;
    _recruiter = null;
    _loading = false;
    _error = null;
    notifyListeners();
    return true;
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

    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (_accounts.containsKey(normalizedEmail)) {
      _loading = false;
      _error = 'Este correo electrónico ya está registrado';
      notifyListeners();
      return false;
    }

    final company = CompanyProfile(
      id: 'emp-${_accounts.length + 1}',
      nombre: empresaNombre.trim(),
      descripcion: empresaDescripcion.trim(),
      monograma: empresaMonograma.trim().toUpperCase(),
    );
    final profile = RecruiterProfile(
      id: 'recl-${_accounts.length + 1}',
      nombre: nombre.trim(),
      email: normalizedEmail,
      empresa: company,
    );

    _accounts[normalizedEmail] = _StubAccount(
      password: password,
      role: UserRole.reclutador,
      recruiter: profile,
    );

    _role = UserRole.reclutador;
    _recruiter = profile;
    _candidate = null;
    _loading = false;
    _error = null;
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _loading = false;
    _error = null;
    _role = null;
    _candidate = null;
    _recruiter = null;
    notifyListeners();
  }
}
