import 'package:dreamjob/auth/data/auth_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('mapea email ya registrado', () {
    final error = AuthException('User already registered', code: 'user_already_exists');
    expect(AuthErrorMapper.map(error), 'Este correo electrónico ya está registrado');
  });

  test('mapea credenciales incorrectas', () {
    final error = AuthException('Invalid login credentials', code: 'invalid_credentials');
    expect(AuthErrorMapper.map(error), 'Correo electrónico o contraseña incorrectos');
  });

  test('mapea contraseña corta', () {
    final error = AuthException('Password should be at least 8 characters', code: 'weak_password');
    expect(AuthErrorMapper.map(error), 'La contraseña debe tener al menos 8 caracteres');
  });

  test('mapea falta de conexión', () {
    final error = AuthRetryableFetchException(message: 'Failed host lookup');
    expect(
      AuthErrorMapper.map(error),
      'No hay conexión a internet. Revisa tu conexión e intenta de nuevo',
    );
  });

  test('mapea error de postgrest sin codigo conocido a mensaje generico', () {
    final error = PostgrestException(message: 'No autenticado', code: 'P0001');
    expect(AuthErrorMapper.map(error), 'Ocurrió un error inesperado, intenta de nuevo');
  });

  test('mapea cualquier otro error a mensaje generico', () {
    expect(
      AuthErrorMapper.map(Exception('algo que no controlamos')),
      'Ocurrió un error inesperado, intenta de nuevo',
    );
  });
}
