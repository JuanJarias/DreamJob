import 'package:dreamjob/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthRepository implements AuthRepository {
  final Map<String, _FakeAccount> _accounts = {};
  final Map<String, Map<String, dynamic>> _usuarios = {};
  final Map<String, Map<String, dynamic>> _reclutadores = {};
  final Map<String, Map<String, dynamic>> _empresas = {};
  int _nextId = 1;

  @override
  Session? get currentSession => null;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (_accounts.containsKey(email)) {
      throw Exception('Este correo electrónico ya está registrado');
    }
    final id = 'user-${_nextId++}';
    _accounts[email] = _FakeAccount(
      id: id,
      email: email,
      password: password,
      metadata: data,
    );
    return AuthResponse(user: _buildUser(id, email, data));
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final account = _accounts[email];
    if (account == null || account.password != password) {
      throw Exception('Correo electrónico o contraseña incorrectos');
    }
    return AuthResponse(
      user: _buildUser(account.id, account.email, account.metadata),
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> crearUsuario(Map<String, dynamic> datos) async {
    _usuarios[datos['id'] as String] = datos;
  }

  @override
  Future<Map<String, dynamic>> obtenerUsuario(String id) async {
    return _usuarios[id]!;
  }

  @override
  Future<void> registrarReclutador({
    required String nombre,
    required String email,
    required String empresaNombre,
    required String empresaDescripcion,
    required String empresaMonograma,
  }) async {
    final account = _accounts[email]!;
    final empresaId = 'empresa-${_nextId++}';
    _empresas[empresaId] = {
      'id': empresaId,
      'nombre': empresaNombre,
      'descripcion': empresaDescripcion,
      'monograma': empresaMonograma,
    };
    _reclutadores[account.id] = {
      'id': account.id,
      'nombre': nombre,
      'email': email,
      'empresa_id': empresaId,
    };
  }

  @override
  Future<Map<String, dynamic>> obtenerReclutadorConEmpresa(String id) async {
    final reclutador = _reclutadores[id]!;
    final empresa = _empresas[reclutador['empresa_id']]!;
    return {...reclutador, 'empresas': empresa};
  }

  User _buildUser(String id, String email, Map<String, dynamic> metadata) {
    return User(
      id: id,
      appMetadata: const {},
      userMetadata: metadata,
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
  }
}

class _FakeAccount {
  _FakeAccount({
    required this.id,
    required this.email,
    required this.password,
    required this.metadata,
  });

  final String id;
  final String email;
  final String password;
  final Map<String, dynamic> metadata;
}
