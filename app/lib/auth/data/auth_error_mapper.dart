import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorMapper {
  const AuthErrorMapper._();

  static String map(Object error) {
    if (error is AuthException) {
      return _mapCodigoOMensaje(error.code, error.message);
    }
    if (error is PostgrestException) {
      return _mapCodigoOMensaje(error.code, error.message);
    }
    if (_pareceErrorDeRed(error.toString())) {
      return 'No hay conexión a internet. Revisa tu conexión e intenta de nuevo';
    }
    return 'Ocurrió un error inesperado, intenta de nuevo';
  }

  static String _mapCodigoOMensaje(String? codigo, String mensaje) {
    switch (codigo) {
      case 'user_already_exists':
      case 'email_exists':
        return 'Este correo electrónico ya está registrado';
      case 'invalid_credentials':
        return 'Correo electrónico o contraseña incorrectos';
      case 'weak_password':
        return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (_pareceErrorDeRed(mensaje)) {
      return 'No hay conexión a internet. Revisa tu conexión e intenta de nuevo';
    }
    return 'Ocurrió un error inesperado, intenta de nuevo';
  }

  static bool _pareceErrorDeRed(String texto) {
    final textoPlano = texto.toLowerCase();
    return textoPlano.contains('socketexception') ||
        textoPlano.contains('failed host lookup') ||
        textoPlano.contains('network') ||
        textoPlano.contains('timeout') ||
        textoPlano.contains('connection');
  }
}
