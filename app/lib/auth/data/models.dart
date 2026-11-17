import '../../vacancies/data/technology.dart';

enum UserRole { candidato, reclutador }

class CandidateProfile {
  final String id;
  final String nombre;
  final String email;
  final String ciudad;
  final DateTime fechaNacimiento;
  final String? resumenPerfil;
  final String? modalidadPreferida;
  final int? salarioMinimo;
  final String? seniority;
  final List<Technology> tecnologias;

  const CandidateProfile({
    required this.id,
    required this.nombre,
    required this.email,
    required this.ciudad,
    required this.fechaNacimiento,
    this.resumenPerfil,
    this.modalidadPreferida,
    this.salarioMinimo,
    this.seniority,
    this.tecnologias = const [],
  });

  factory CandidateProfile.fromMap(Map<String, dynamic> map) {
    var parsedTecnologias = const <Technology>[];
    if (map['usuario_tecnologias'] is List) {
      parsedTecnologias = (map['usuario_tecnologias'] as List)
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

    return CandidateProfile(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      email: map['email'] as String,
      ciudad: map['ciudad'] as String,
      fechaNacimiento: DateTime.parse(map['fecha_nacimiento'] as String),
      resumenPerfil: map['resumen_perfil'] as String?,
      modalidadPreferida: map['modalidad_preferida'] as String?,
      salarioMinimo: _parseOptionalInt(map['salario_minimo']),
      seniority: map['seniority'] as String?,
      tecnologias: parsedTecnologias,
    );
  }

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.round();
    if (value is String) {
      final sanitized = value.trim();
      return int.tryParse(sanitized) ?? double.tryParse(sanitized)?.round();
    }
    return null;
  }

  CandidateProfile copyWith({
    String? id,
    String? nombre,
    String? email,
    String? ciudad,
    DateTime? fechaNacimiento,
    String? resumenPerfil,
    String? modalidadPreferida,
    int? salarioMinimo,
    bool clearSalarioMinimo = false,
    String? seniority,
    List<Technology>? tecnologias,
  }) {
    return CandidateProfile(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      ciudad: ciudad ?? this.ciudad,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      resumenPerfil: resumenPerfil ?? this.resumenPerfil,
      modalidadPreferida: modalidadPreferida ?? this.modalidadPreferida,
      salarioMinimo:
          clearSalarioMinimo ? null : (salarioMinimo ?? this.salarioMinimo),
      seniority: seniority ?? this.seniority,
      tecnologias: tecnologias ?? this.tecnologias,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'ciudad': ciudad,
      'fecha_nacimiento': _formatFechaPostgres(fechaNacimiento),
      'resumen_perfil': resumenPerfil,
    };
  }
}

String _formatFechaPostgres(DateTime fecha) {
  final anio = fecha.year.toString().padLeft(4, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  final dia = fecha.day.toString().padLeft(2, '0');
  return '$anio-$mes-$dia';
}

class CompanyProfile {
  final String id;
  final String nombre;
  final String descripcion;
  final String monograma;

  const CompanyProfile({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.monograma,
  });

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String? ?? '',
      monograma: map['monograma'] as String,
    );
  }
  CompanyProfile copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? monograma,
  }) {
    return CompanyProfile(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      monograma: monograma ?? this.monograma,
    );
  }
}

class RecruiterProfile {
  final String id;
  final String nombre;
  final String email;
  final CompanyProfile empresa;

  const RecruiterProfile({
    required this.id,
    required this.nombre,
    required this.email,
    required this.empresa,
  });

  RecruiterProfile copyWith({
    String? id,
    String? nombre,
    String? email,
    CompanyProfile? empresa,
  }) {
    return RecruiterProfile(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      empresa: empresa ?? this.empresa,
    );
  }

  factory RecruiterProfile.fromMap(Map<String, dynamic> map) {
    return RecruiterProfile(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      email: map['email'] as String,
      empresa: CompanyProfile.fromMap(map['empresas'] as Map<String, dynamic>),
    );
  }
}
