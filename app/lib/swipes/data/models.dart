import '../../vacancies/data/models.dart';

class SwipeDirections {
  const SwipeDirections._();

  static const String derecha = 'derecha';
  static const String izquierda = 'izquierda';
}

class SwipeRecord {
  final String id;
  final String usuarioId;
  final String vacanteId;
  final String direccion;
  final DateTime? createdAt;
  final Vacancy? vacante;

  const SwipeRecord({
    required this.id,
    required this.usuarioId,
    required this.vacanteId,
    required this.direccion,
    this.createdAt,
    this.vacante,
  });

  factory SwipeRecord.fromMap(Map<String, dynamic> map) {
    Vacancy? parsedVacante;
    if (map['vacantes'] is Map<String, dynamic>) {
      parsedVacante = Vacancy.fromMap(map['vacantes'] as Map<String, dynamic>);
    }

    return SwipeRecord(
      id: map['id'] as String,
      usuarioId: map['usuario_id'] as String,
      vacanteId: map['vacante_id'] as String,
      direccion: map['direccion'] as String,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
      vacante: parsedVacante,
    );
  }

  SwipeRecord copyWith({
    String? id,
    String? usuarioId,
    String? vacanteId,
    String? direccion,
    DateTime? createdAt,
    Vacancy? vacante,
  }) {
    return SwipeRecord(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      vacanteId: vacanteId ?? this.vacanteId,
      direccion: direccion ?? this.direccion,
      createdAt: createdAt ?? this.createdAt,
      vacante: vacante ?? this.vacante,
    );
  }
}
