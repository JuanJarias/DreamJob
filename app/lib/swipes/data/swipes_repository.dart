import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';

abstract class SwipesRepository {
  Future<List<SwipeRecord>> obtenerSwipesCandidato(String usuarioId);

  Future<SwipeRecord> registrarSwipe({
    required String usuarioId,
    required String vacanteId,
    required String direccion,
  });

  Future<void> eliminarSwipe(String swipeId);
}

class SupabaseSwipesRepository implements SwipesRepository {
  SupabaseSwipesRepository({SupabaseClient? client}) : _providedClient = client;

  final SupabaseClient? _providedClient;

  SupabaseClient get _client => _providedClient ?? Supabase.instance.client;

  @override
  Future<List<SwipeRecord>> obtenerSwipesCandidato(String usuarioId) async {
    final response = await _client
        .from('swipes')
        .select(
          '*, vacantes(*, empresas(id, nombre, descripcion, monograma), vacante_tecnologias(tecnologias(*)))',
        )
        .eq('usuario_id', usuarioId)
        .order('created_at', ascending: false);

    final list = response as List<dynamic>;
    return list
        .map((item) => SwipeRecord.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SwipeRecord> registrarSwipe({
    required String usuarioId,
    required String vacanteId,
    required String direccion,
  }) async {
    final response = await _client
        .from('swipes')
        .insert({
          'usuario_id': usuarioId,
          'vacante_id': vacanteId,
          'direccion': direccion,
        })
        .select()
        .single();

    return SwipeRecord.fromMap(response);
  }

  @override
  Future<void> eliminarSwipe(String swipeId) async {
    await _client.from('swipes').delete().eq('id', swipeId);
  }
}
