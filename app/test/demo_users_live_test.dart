import 'dart:io';
import 'package:dreamjob/auth/data/auth_repository.dart';
import 'package:dreamjob/auth/data/models.dart';
import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  const candidateEmail = String.fromEnvironment(
    'DEMO_CANDIDATO_EMAIL',
    defaultValue: 'candidato.demo@dreamjob.app',
  );
  const recruiterEmail = String.fromEnvironment(
    'DEMO_RECLUTADOR_EMAIL',
    defaultValue: 'reclutador.demo@dreamjob.app',
  );
  const password = String.fromEnvironment(
    'DEMO_PASSWORD',
    defaultValue: 'DreamJob2026!',
  );

  final hasLiveBackend = supabaseUrl.isNotEmpty && anonKey.isNotEmpty;

  group('Usuarios de demostración en Supabase real', () {
    setUpAll(() async {
      if (hasLiveBackend) {
        TestWidgetsFlutterBinding.ensureInitialized();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/shared_preferences'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getAll') {
              return <String, Object>{};
            }
            return true;
          },
        );
        HttpOverrides.global = null;
        await Supabase.initialize(
          url: supabaseUrl,
          publishableKey: anonKey,
        );
      }
    });

    testWidgets(
      'Candidato demo inicia sesión y ve su perfil respectivo en Supabase',
      (WidgetTester tester) async {
        if (!hasLiveBackend) return;

        final repository = SupabaseAuthRepository();
        final auth = AuthProvider(repository: repository);

        // Esperar restauración inicial de sesión
        await tester.runAsync(() async {
          while (auth.loading) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
        });

        await tester.pumpWidget(
          DreamJobApp(authProvider: auth, initialLocation: '/login'),
        );
        await tester.pumpAndSettle();

        // Iniciar sesión con candidato demo
        await tester.runAsync(() async {
          final ok = await auth.signIn(candidateEmail, password);
          expect(ok, isTrue);
        });
        await tester.pumpAndSettle();

        // Confirmar redirección automática a /profile
        expect(auth.isAuthenticated, isTrue);
        expect(auth.role, UserRole.candidato);
        expect(find.text('Mi perfil'), findsOneWidget);
        expect(find.text(candidateEmail), findsOneWidget);
        expect(find.text('Candidato'), findsOneWidget);
        expect(find.text('Cali'), findsOneWidget);

        // Cerrar sesión
        await tester.runAsync(() async {
          await auth.signOut();
        });
        await tester.pumpAndSettle();

        expect(auth.isAuthenticated, isFalse);
        expect(find.text('Iniciar sesión'), findsOneWidget);
      },
    );

    testWidgets(
      'Reclutador demo inicia sesión y ve su perfil con empresa en Supabase',
      (WidgetTester tester) async {
        if (!hasLiveBackend) return;

        final repository = SupabaseAuthRepository();
        final auth = AuthProvider(repository: repository);

        // Esperar restauración inicial de sesión
        await tester.runAsync(() async {
          while (auth.loading) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
        });

        await tester.pumpWidget(
          DreamJobApp(authProvider: auth, initialLocation: '/login'),
        );
        await tester.pumpAndSettle();

        // Iniciar sesión con reclutador demo
        await tester.runAsync(() async {
          final ok = await auth.signIn(recruiterEmail, password);
          expect(ok, isTrue);
        });
        await tester.pumpAndSettle();

        // Confirmar redirección automática a /profile con su empresa
        expect(auth.isAuthenticated, isTrue);
        expect(auth.role, UserRole.reclutador);
        expect(find.text('Mi perfil'), findsOneWidget);
        expect(find.text(recruiterEmail), findsOneWidget);
        expect(find.text('Reclutador'), findsOneWidget);
        expect(find.text('Tech Solutions S.A.S.'), findsWidgets);
        expect(find.text('TS'), findsWidgets);
        expect(find.text('Monograma: TS'), findsOneWidget);

        // Cerrar sesión
        await tester.runAsync(() async {
          await auth.signOut();
        });
        await tester.pumpAndSettle();

        expect(auth.isAuthenticated, isFalse);
        expect(find.text('Iniciar sesión'), findsOneWidget);
      },
    );
  });
}
