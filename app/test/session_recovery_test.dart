import 'dart:io';

import 'package:dreamjob/auth/data/models.dart';
import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'fakes/fake_auth_repository.dart';

void main() {
  for (final role in UserRole.values) {
    testWidgets('Restaura la sesión de ${role.name} y permite salir', (
      tester,
    ) async {
      final repository = _SessionRepository(role);
      final auth = AuthProvider(repository: repository);
      addTearDown(auth.dispose);
      await tester.pumpWidget(DreamJobApp(authProvider: auth));
      await tester.pumpAndSettle();

      expect(auth.role, role);
      expect(find.text('Mi perfil'), findsOneWidget);
      expect(find.text('sesion@example.com'), findsOneWidget);
      if (role == UserRole.reclutador) {
        expect(find.text('Empresa de prueba'), findsOneWidget);
      }

      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(auth.isAuthenticated, isFalse);
      expect(repository.currentSession, isNull);
      expect(find.text('Iniciar sesión'), findsOneWidget);
    });
  }

  testWidgets('Fallo de red al restaurar termina Splash y conserva la sesión', (
    tester,
  ) async {
    final repository = _SessionRepository(UserRole.candidato)
      ..failProfile = true
      ..failSignOut = true;
    final auth = AuthProvider(repository: repository);
    addTearDown(auth.dispose);
    await tester.pumpWidget(DreamJobApp(authProvider: auth));
    await tester.pumpAndSettle();

    expect(auth.loading, isFalse);
    expect(auth.isAuthenticated, isFalse);
    expect(repository.signOutCalls, 0);
    expect(repository.currentSession, isNotNull);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.textContaining('No hay conexión'), findsOneWidget);

    repository.failProfile = false;
    await tester.pumpWidget(const SizedBox.shrink());
    final reopened = AuthProvider(repository: repository);
    addTearDown(reopened.dispose);
    await tester.pumpWidget(DreamJobApp(authProvider: reopened));
    await tester.pumpAndSettle();
    expect(reopened.role, UserRole.candidato);
    expect(find.text('Mi perfil'), findsOneWidget);
  });

  testWidgets('Fallo al cerrar sesión muestra error y permite reintentar', (
    tester,
  ) async {
    final repository = _SessionRepository(UserRole.candidato)
      ..failSignOut = true;
    final auth = AuthProvider(repository: repository);
    addTearDown(auth.dispose);
    await tester.pumpWidget(DreamJobApp(authProvider: auth));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(auth.loading, isFalse);
    expect(auth.isAuthenticated, isTrue);
    expect(repository.currentSession, isNotNull);
    expect(find.textContaining('No hay conexión'), findsOneWidget);

    repository.failSignOut = false;
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(auth.isAuthenticated, isFalse);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}

class _SessionRepository extends FakeAuthRepository {
  _SessionRepository(UserRole role) {
    _session = Session(
      accessToken: 'test-token',
      tokenType: 'bearer',
      user: User(
        id: 'session-user',
        appMetadata: const {},
        userMetadata: {'role': role.name},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
      ),
    );
  }

  Session? _session;
  bool failProfile = false;
  bool failSignOut = false;
  int signOutCalls = 0;

  @override
  Session? get currentSession => _session;

  @override
  Future<Map<String, dynamic>> obtenerUsuario(String id) async {
    if (failProfile) throw const SocketException('Network unavailable');
    return {
      'id': id,
      'nombre': 'Usuario de prueba',
      'email': 'sesion@example.com',
      'ciudad': 'Cali',
      'fecha_nacimiento': '2000-01-01',
    };
  }

  @override
  Future<Map<String, dynamic>> obtenerReclutadorConEmpresa(String id) async => {
    'id': id,
    'nombre': 'Usuario de prueba',
    'email': 'sesion@example.com',
    'empresas': {
      'id': 'company',
      'nombre': 'Empresa de prueba',
      'descripcion': 'Descripción',
      'monograma': 'EP',
    },
  };

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (failSignOut) throw const SocketException('Network unavailable');
    _session = null;
  }
}
