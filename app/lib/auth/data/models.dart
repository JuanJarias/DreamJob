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
}
