import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';

abstract class VacanciesRepository {
  Future<List<Technology>> obtenerCatalogoTecnologias();

  Future<Vacancy> crearVacante({
    required Vacancy vacante,
    required List<String> tecnologiaIds,
  });

  Future<Vacancy> actualizarVacante({
    required Vacancy vacante,
    required List<String> tecnologiaIds,
  });

  Future<List<Vacancy>> obtenerVacantesEmpresa(String empresaId);

  Future<Vacancy?> obtenerVacantePorId(String id);
}

class SupabaseVacanciesRepository implements VacanciesRepository {
  SupabaseVacanciesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<Technology>> obtenerCatalogoTecnologias() async {
    final response = await _client
        .from('tecnologias')
        .select()
        .order('nombre', ascending: true);

    final list = response as List<dynamic>;
    return list
        .map((item) => Technology.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Vacancy> crearVacante({
    required Vacancy vacante,
    required List<String> tecnologiaIds,
  }) async {
    final insertData = vacante.toMap(includeId: false);
    final response = await _client
        .from('vacantes')
        .insert(insertData)
        .select()
        .single();

    final createdId = response['id'] as String;

    if (tecnologiaIds.isNotEmpty) {
      final relaciones = tecnologiaIds
          .map((tid) => {'vacante_id': createdId, 'tecnologia_id': tid})
          .toList();
      await _client.from('vacante_tecnologias').insert(relaciones);
    }

    final full = await obtenerVacantePorId(createdId);
    return full ?? Vacancy.fromMap(response);
  }

  @override
  Future<Vacancy> actualizarVacante({
    required Vacancy vacante,
    required List<String> tecnologiaIds,
  }) async {
    final id = vacante.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('La vacante debe tener un ID para actualizarse');
    }

    await _client.from('vacantes').update({
      'titulo': vacante.titulo,
      'descripcion': vacante.descripcion,
      'ubicacion': vacante.ubicacion,
      'modalidad': vacante.modalidad,
      'salario_min': vacante.salarioMin,
      'salario_max': vacante.salarioMax,
      'moneda': vacante.moneda,
      'seniority': vacante.seniority,
      'estado': vacante.estado,
    }).eq('id', id);

    // Sincronizar tecnologías
    await _client.from('vacante_tecnologias').delete().eq('vacante_id', id);
    if (tecnologiaIds.isNotEmpty) {
      final relaciones = tecnologiaIds
          .map((tid) => {'vacante_id': id, 'tecnologia_id': tid})
          .toList();
      await _client.from('vacante_tecnologias').insert(relaciones);
    }

    final full = await obtenerVacantePorId(id);
    return full ?? vacante;
  }

  @override
  Future<List<Vacancy>> obtenerVacantesEmpresa(String empresaId) async {
    final response = await _client
        .from('vacantes')
        .select('*, vacante_tecnologias(tecnologias(*))')
        .eq('empresa_id', empresaId)
        .order('created_at', ascending: false);

    final list = response as List<dynamic>;
    return list
        .map((item) => Vacancy.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Vacancy?> obtenerVacantePorId(String id) async {
    final response = await _client
        .from('vacantes')
        .select('*, vacante_tecnologias(tecnologias(*))')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Vacancy.fromMap(response);
  }
}
