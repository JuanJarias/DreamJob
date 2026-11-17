import '../../auth/data/models.dart';
import 'technology.dart';

export 'technology.dart';

class JobModalities {
  const JobModalities._();
  static const String remoto = 'Remoto';
  static const String hibrido = 'Híbrido';
  static const String presencial = 'Presencial';

  static const List<String> values = [remoto, hibrido, presencial];
}

class JobSeniorities {
  const JobSeniorities._();
  static const String junior = 'Practicante / Junior';
  static const String semiSenior = 'Semi-Senior';
  static const String senior = 'Senior';

  static const List<String> values = [junior, semiSenior, senior];
}

class VacancyStatuses {
  const VacancyStatuses._();
  static const String activa = 'activa';
  static const String pausada = 'pausada';
  static const String cerrada = 'cerrada';

  static const List<String> values = [activa, pausada, cerrada];
}

class Vacancy {
  final String? id;
  final String empresaId;
  final String reclutadorId;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final String modalidad;
  final int? salarioMin;
  final int? salarioMax;
  final String moneda;
  final String seniority;
  final String estado;
  final DateTime? createdAt;
  final List<Technology> tecnologias;
  final int candidatosInteresados;
  final CompanyProfile? empresa;

  const Vacancy({
    this.id,
    required this.empresaId,
    required this.reclutadorId,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    this.modalidad = JobModalities.remoto,
    this.salarioMin,
    this.salarioMax,
    this.moneda = 'COP',
    this.seniority = JobSeniorities.junior,
    this.estado = VacancyStatuses.activa,
    this.createdAt,
    this.tecnologias = const [],
    this.candidatosInteresados = 0,
    this.empresa,
  });

  factory Vacancy.fromMap(
    Map<String, dynamic> map, {
    List<Technology>? tecnologias,
  }) {
    List<Technology> parsedTecnologias = tecnologias ?? const [];
    if (tecnologias == null) {
      if (map['tecnologias'] is List) {
        parsedTecnologias = (map['tecnologias'] as List)
            .map((item) {
              if (item is Map<String, dynamic>) {
                if (item.containsKey('tecnologias') &&
                    item['tecnologias'] is Map<String, dynamic>) {
                  return Technology.fromMap(
                    item['tecnologias'] as Map<String, dynamic>,
                  );
                }
                return Technology.fromMap(item);
              }
              return null;
            })
            .whereType<Technology>()
            .toList();
      } else if (map['vacante_tecnologias'] is List) {
        parsedTecnologias = (map['vacante_tecnologias'] as List)
            .map((item) {
              if (item is Map<String, dynamic> &&
                  item['tecnologias'] is Map<String, dynamic>) {
                return Technology.fromMap(
                  item['tecnologias'] as Map<String, dynamic>,
                );
              }
              return null;
            })
            .whereType<Technology>()
            .toList();
      }
    }

    int parsedInteresados = 0;
    if (map['candidatos_interesados'] is num) {
      parsedInteresados = (map['candidatos_interesados'] as num).round();
    } else if (map['swipes'] is List) {
      parsedInteresados = (map['swipes'] as List)
          .where((s) => s is Map && s['direccion'] == 'derecha')
          .length;
    }

    CompanyProfile? parsedEmpresa;
    if (map['empresas'] is Map<String, dynamic>) {
      parsedEmpresa = CompanyProfile.fromMap(
        map['empresas'] as Map<String, dynamic>,
      );
    }

    return Vacancy(
      id: map['id'] as String?,
      empresaId: map['empresa_id'] as String,
      reclutadorId: map['reclutador_id'] as String,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String,
      ubicacion: map['ubicacion'] as String,
      modalidad: map['modalidad'] as String? ?? JobModalities.remoto,
      salarioMin: _parseNumber(map['salario_min']),
      salarioMax: _parseNumber(map['salario_max']),
      moneda: map['moneda'] as String? ?? 'COP',
      seniority: map['seniority'] as String? ?? JobSeniorities.junior,
      estado: map['estado'] as String? ?? VacancyStatuses.activa,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
      tecnologias: parsedTecnologias,
      candidatosInteresados: parsedInteresados,
      empresa: parsedEmpresa,
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    final data = <String, dynamic>{
      'empresa_id': empresaId,
      'reclutador_id': reclutadorId,
      'titulo': titulo,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'modalidad': modalidad,
      'salario_min': salarioMin,
      'salario_max': salarioMax,
      'moneda': moneda,
      'seniority': seniority,
      'estado': estado,
    };
    if (candidatosInteresados > 0) {
      data['candidatos_interesados'] = candidatosInteresados;
    }
    if (includeId && id != null) {
      data['id'] = id;
    }
    if (createdAt != null) {
      data['created_at'] = createdAt!.toIso8601String();
    }
    return data;
  }

  Vacancy copyWith({
    String? id,
    String? empresaId,
    String? reclutadorId,
    String? titulo,
    String? descripcion,
    String? ubicacion,
    String? modalidad,
    int? salarioMin,
    int? salarioMax,
    bool clearSalarioMin = false,
    bool clearSalarioMax = false,
    String? moneda,
    String? seniority,
    String? estado,
    DateTime? createdAt,
    List<Technology>? tecnologias,
    int? candidatosInteresados,
    CompanyProfile? empresa,
  }) {
    return Vacancy(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      reclutadorId: reclutadorId ?? this.reclutadorId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      ubicacion: ubicacion ?? this.ubicacion,
      modalidad: modalidad ?? this.modalidad,
      salarioMin: clearSalarioMin ? null : (salarioMin ?? this.salarioMin),
      salarioMax: clearSalarioMax ? null : (salarioMax ?? this.salarioMax),
      moneda: moneda ?? this.moneda,
      seniority: seniority ?? this.seniority,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      tecnologias: tecnologias ?? this.tecnologias,
      candidatosInteresados:
          candidatosInteresados ?? this.candidatosInteresados,
      empresa: empresa ?? this.empresa,
    );
  }

  static int? _parseNumber(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.round();
    if (value is String) {
      final sanitized = value.trim();
      return int.tryParse(sanitized) ?? double.tryParse(sanitized)?.round();
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vacancy &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          titulo == other.titulo &&
          empresaId == other.empresaId;

  @override
  int get hashCode => id.hashCode ^ titulo.hashCode ^ empresaId.hashCode;

  @override
  String toString() =>
      'Vacancy(id: $id, titulo: $titulo, modalidad: $modalidad, seniority: $seniority, estado: $estado)';
}
