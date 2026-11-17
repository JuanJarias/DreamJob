class Technology {
  final String id;
  final String nombre;
  final String categoria;

  const Technology({
    required this.id,
    required this.nombre,
    this.categoria = 'General',
  });

  factory Technology.fromMap(Map<String, dynamic> map) {
    return Technology(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      categoria: map['categoria'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
    };
  }

  Technology copyWith({
    String? id,
    String? nombre,
    String? categoria,
  }) {
    return Technology(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Technology &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Technology(id: $id, nombre: $nombre, categoria: $categoria)';
}
