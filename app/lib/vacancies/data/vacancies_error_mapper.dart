import 'package:supabase_flutter/supabase_flutter.dart';

class VacanciesErrorMapper {
  const VacanciesErrorMapper._();

  static String map(Object error) {
    if (error is PostgrestException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('salario_max') || msg.contains('salario')) {
        return 'El salario máximo no puede ser menor al salario mínimo';
      }
      if (msg.contains('modalidad')) {
        return 'Selecciona una modalidad válida';
      }
      if (msg.contains('seniority')) {
        return 'Selecciona un nivel de experiencia válido';
      }
      if (msg.contains('not authenticated') || msg.contains('no autenticado')) {
        return 'Debes iniciar sesión para realizar esta acción';
      }
    }
    final str = error.toString().toLowerCase();
    if (str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('network') ||
        str.contains('timeout') ||
        str.contains('connection')) {
      return 'No hay conexión a internet. Revisa tu conexión e intenta de nuevo';
    }
    return 'Ocurrió un error al procesar la vacante, intenta de nuevo';
  }
}
