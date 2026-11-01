import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Session? get currentSession;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> crearUsuario(Map<String, dynamic> datos);

  Future<Map<String, dynamic>> obtenerUsuario(String id);

  Future<void> registrarReclutador({
    required String nombre,
    required String email,
    required String empresaNombre,
    required String empresaDescripcion,
    required String empresaMonograma,
  });

  Future<Map<String, dynamic>> obtenerReclutadorConEmpresa(String id);
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) {
    return _client.auth.signUp(email: email, password: password, data: data);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> crearUsuario(Map<String, dynamic> datos) async {
    await _client.from('usuarios').insert(datos);
  }

  @override
  Future<Map<String, dynamic>> obtenerUsuario(String id) {
    return _client.from('usuarios').select().eq('id', id).single();
  }

  @override
  Future<void> registrarReclutador({
    required String nombre,
    required String email,
    required String empresaNombre,
    required String empresaDescripcion,
    required String empresaMonograma,
  }) async {
    await _client.rpc('registrar_reclutador', params: {
      'p_nombre': nombre,
      'p_email': email,
      'p_empresa_nombre': empresaNombre,
      'p_empresa_descripcion': empresaDescripcion,
      'p_empresa_monograma': empresaMonograma,
    });
  }

  @override
  Future<Map<String, dynamic>> obtenerReclutadorConEmpresa(String id) {
    return _client
        .from('reclutadores')
        .select(
          'id, nombre, email, empresa_id, empresas(id, nombre, descripcion, monograma)',
        )
        .eq('id', id)
        .single();
  }
}
