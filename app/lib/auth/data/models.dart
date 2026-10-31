enum UserRole { candidato, reclutador }

class CandidateProfile {
  final String id;
  final String nombre;
  final String email;
  final String ciudad;
  final DateTime fechaNacimiento;
  final String? resumenPerfil;

  const CandidateProfile({
    required this.id,
    required this.nombre,
    required this.email,
    required this.ciudad,
    required this.fechaNacimiento,
    this.resumenPerfil,
  });

  factory CandidateProfile.fromMap(Map<String, dynamic> map) {
    return CandidateProfile(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      email: map['email'] as String,
      ciudad: map['ciudad'] as String,
      fechaNacimiento: DateTime.parse(map['fecha_nacimiento'] as String),
      resumenPerfil: map['resumen_perfil'] as String?,
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

  factory RecruiterProfile.fromMap(Map<String, dynamic> map) {
    return RecruiterProfile(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      email: map['email'] as String,
      empresa: CompanyProfile.fromMap(map['empresas'] as Map<String, dynamic>),
    );
  }
}
