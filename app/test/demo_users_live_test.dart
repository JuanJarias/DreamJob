import 'dart:io';
import 'package:dreamjob/auth/data/auth_repository.dart';
import 'package:dreamjob/auth/data/models.dart';
import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/main.dart';
import 'package:dreamjob/swipes/state/swipes_provider.dart';
import 'package:dreamjob/vacancies/state/vacancies_provider.dart';
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
  const password = String.fromEnvironment('DEMO_PASSWORD');

  final hasLiveBackend =
      supabaseUrl.isNotEmpty && anonKey.isNotEmpty && password.isNotEmpty;

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

    tearDown(() async {
      if (hasLiveBackend) {
        await Supabase.instance.client.auth.signOut();
      }
    });

    testWidgets(
      'Candidato demo inicia sesión y ve su perfil y deck en Supabase',
      (WidgetTester tester) async {
        final auth = AuthProvider(repository: SupabaseAuthRepository());
        final vacancies = VacanciesProvider();
        final swipes = SwipesProvider();
        addTearDown(auth.dispose);
        addTearDown(vacancies.dispose);
        addTearDown(swipes.dispose);

        await tester.runAsync(() async {
          while (auth.loading) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          final ok = await auth.signIn(candidateEmail, password);
          expect(ok, isTrue);
          await swipes.cargarDeckYSwipes(
            usuarioId: auth.candidate!.id,
            candidate: auth.candidate,
          );
        });

        await tester.pumpWidget(
          DreamJobApp(
            authProvider: auth,
            vacanciesProvider: vacancies,
            swipesProvider: swipes,
          ),
        );
        await tester.pumpAndSettle();

        expect(auth.isAuthenticated, isTrue);
        expect(auth.role, UserRole.candidato);
        expect(swipes.error, isNull);
        expect(swipes.deck.length, greaterThanOrEqualTo(4));

        await tester.tap(find.text('Perfil'));
        await tester.pumpAndSettle();

        expect(find.text('Mi perfil'), findsOneWidget);
        expect(find.text(candidateEmail), findsOneWidget);
        expect(find.text('Candidato'), findsOneWidget);
        expect(find.text('Cali'), findsOneWidget);

        await tester.runAsync(() async {
          await auth.signOut();
        });
        await tester.pumpWidget(
          DreamJobApp(
            authProvider: auth,
            vacanciesProvider: vacancies,
            swipesProvider: swipes,
          ),
        );
        await tester.pumpAndSettle();

        expect(auth.isAuthenticated, isFalse);
        expect(find.text('Iniciar sesión'), findsOneWidget);
      },
      skip: !hasLiveBackend,
    );

    testWidgets(
      'Reclutador demo inicia sesión y ve su perfil, empresa y vacantes en Supabase',
      (WidgetTester tester) async {
        final auth = AuthProvider(repository: SupabaseAuthRepository());
        final vacancies = VacanciesProvider();
        final swipes = SwipesProvider();
        addTearDown(auth.dispose);
        addTearDown(vacancies.dispose);
        addTearDown(swipes.dispose);

        await tester.runAsync(() async {
          while (auth.loading) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          final ok = await auth.signIn(recruiterEmail, password);
          expect(ok, isTrue);
          await vacancies.cargarVacantesEmpresa(auth.recruiter!.empresa.id);
        });

        await tester.pumpWidget(
          DreamJobApp(
            authProvider: auth,
            vacanciesProvider: vacancies,
            swipesProvider: swipes,
          ),
        );
        // Splash -> /home
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.runAsync(() async {
          final deadline = DateTime.now().add(const Duration(seconds: 15));
          while (vacancies.loading && DateTime.now().isBefore(deadline)) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
        });
        await tester.pumpAndSettle();

        expect(auth.isAuthenticated, isTrue);
        expect(auth.role, UserRole.reclutador);
        expect(vacancies.error, isNull);
        expect(vacancies.vacantesEmpresa.length, greaterThanOrEqualTo(4));

        await tester.tap(find.text('Perfil'));
        await tester.pumpAndSettle();

        final empresa = auth.recruiter!.empresa;
        expect(find.text('Mi perfil'), findsOneWidget);
        expect(find.text(recruiterEmail), findsOneWidget);
        expect(find.text('Reclutador'), findsOneWidget);
        expect(find.text(empresa.nombre), findsWidgets);
        expect(find.text(empresa.monograma), findsWidgets);
        expect(find.text('Monograma: ${empresa.monograma}'), findsOneWidget);

        await tester.runAsync(() async {
          await auth.signOut();
        });
        await tester.pumpWidget(
          DreamJobApp(
            authProvider: auth,
            vacanciesProvider: vacancies,
            swipesProvider: swipes,
          ),
        );
        await tester.pumpAndSettle();

        expect(auth.isAuthenticated, isFalse);
        expect(find.text('Iniciar sesión'), findsOneWidget);
      },
      skip: !hasLiveBackend,
    );
  });
}
