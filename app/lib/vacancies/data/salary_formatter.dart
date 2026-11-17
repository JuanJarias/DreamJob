/// Formatea un entero con separador de miles usando puntos (`4.000.000`).
String formatThousands(int number) {
  final str = number.toString();
  final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
  return str.replaceAll(reg, '.');
}

/// Formatea el rango salarial de una vacante en español.
String formatVacancySalary(int? min, int? max, String moneda) {
  if (min != null && max != null) {
    return '\$ ${formatThousands(min)} - \$ ${formatThousands(max)} $moneda';
  }
  if (min != null) {
    return 'Desde \$ ${formatThousands(min)} $moneda';
  }
  if (max != null) {
    return 'Hasta \$ ${formatThousands(max)} $moneda';
  }
  return 'Salario no especificado';
}
