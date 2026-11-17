import 'package:dreamjob/auth/data/models.dart';
import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/swipes/data/models.dart';
import 'package:dreamjob/swipes/state/swipes_provider.dart';
import 'package:dreamjob/vacancies/data/models.dart';
import 'package:dreamjob/vacancies/screens/candidate_liked_jobs_screen.dart';
import 'package:dreamjob/vacancies/screens/job_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'fakes/fake_swipes_repository.dart';
import 'fakes/fake_vacancies_repository.dart';
import 'helpers/fake_auth_provider.dart';

void main() {
  const empresaA = CompanyProfile(
    id: 'emp-1',
    nombre: 'NovaTech Labs',
    descripcion: 'Laboratorio de ingeniería móvil',
    monograma: 'NT',
  );
  const empresaB = CompanyProfile(
    id: 'emp-2',
    nombre: 'Andes Cloud',
    descripcion: 'Infraestructura distribuida',
    monograma: 'AC',
  );

  const vacAntigua = Vacancy(
    id: 'vac-old',
    empresaId: 'emp-1',
    reclutadorId: 'rec-1',
    titulo: 'Desarrollador Flutter Jr',
    descripcion: 'Soporte a módulos móviles',
    ubicacion: 'Cali',
    modalidad: JobModalities.remoto,
    empresa: empresaA,
  );

  const vacReciente = Vacancy(
    id: 'vac-new',
    empresaId: 'emp-2',
    reclutadorId: 'rec-2',
    titulo: 'Arquitecto Mobile Senior',
    descripcion: 'Diseño de arquitectura limpia y pruebas automatizadas.',
    ubicacion: 'Medellín',
    modalidad: JobModalities.hibrido,
    empresa: empresaB,
  );

  const vacOmitida = Vacancy(
    id: 'vac-skip',
    empresaId: 'emp-1',
    reclutadorId: 'rec-1',
    titulo: 'Vacante Omitida',
    descripcion: 'No debe aparecer en postulaciones',
    ubicacion: 'Bogotá',
    empresa: empresaA,
  );

  group('HU-11: CandidateLikedJobsScreen Widget Tests', () {
    late FakeAuthProvider fakeAuth;
    late FakeSwipesRepository fakeSwipeRepo;
    late FakeVacanciesRepository fakeVacRepo;

    setUp(() {
      fakeAuth = FakeAuthProvider()
        ..setCandidate(
          nombre: 'Carlos Demo',
          email: 'carlos.demo@dreamjob.co',
          ciudad: 'Cali',
        );
      fakeVacRepo = FakeVacanciesRepository(
        vacantesIniciales: [vacAntigua, vacReciente, vacOmitida],
      );
      fakeSwipeRepo = FakeSwipesRepository();
    });

    Widget buildTestApp(SwipesProvider swipesProvider) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuth),
          ChangeNotifierProvider<SwipesProvider>.value(value: swipesProvider),
        ],
        child: MaterialApp(
          home: const CandidateLikedJobsScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/vacancies/detail') {
              final args = settings.arguments as JobDetailArguments;
              return MaterialPageRoute(
                builder: (_) => JobDetailScreen(
                  vacancy: args.vacancy,
                  showActions: args.showActions,
                ),
              );
            }
            return null;
          },
        ),
      );
    }

    testWidgets(
      'Muestra vacantes con swipe positivo ordenadas de reciente a antigua con estado En revisión',
      (WidgetTester tester) async {
        // Sembramos primero la antigua y luego la más reciente (y una omitida).
        fakeSwipeRepo.seedSwipe(
          SwipeRecord(
            id: 'sw-1',
            usuarioId: 'fake-cand-1',
            vacanteId: 'vac-old',
            direccion: SwipeDirections.derecha,
            createdAt: DateTime(2026, 11, 10, 9, 0),
          ),
          vacante: vacAntigua,
        );
        fakeSwipeRepo.seedSwipe(
          SwipeRecord(
            id: 'sw-2',
            usuarioId: 'fake-cand-1',
            vacanteId: 'vac-new',
            direccion: SwipeDirections.derecha,
            createdAt: DateTime(2026, 11, 16, 14, 30),
          ),
          vacante: vacReciente,
        );
        fakeSwipeRepo.seedSwipe(
          SwipeRecord(
            id: 'sw-3',
            usuarioId: 'fake-cand-1',
            vacanteId: 'vac-skip',
            direccion: SwipeDirections.izquierda,
            createdAt: DateTime(2026, 11, 16, 15, 0),
          ),
          vacante: vacOmitida,
        );

        final provider = SwipesProvider(
          swipesRepository: fakeSwipeRepo,
          vacanciesRepository: fakeVacRepo,
        );

        await tester.pumpWidget(buildTestApp(provider));
        await tester.pumpAndSettle();

        expect(find.text('Mis postulaciones'), findsOneWidget);
        expect(find.text('Arquitecto Mobile Senior'), findsOneWidget);
        expect(find.text('Desarrollador Flutter Jr'), findsOneWidget);
        expect(find.text('Vacante Omitida'), findsNothing);

        expect(find.text('Andes Cloud'), findsOneWidget);
        expect(find.text('AC'), findsOneWidget);
        expect(find.text('Híbrido'), findsOneWidget);
        expect(find.text('Medellín'), findsOneWidget);
        expect(find.text('Postulado el 16/11/2026'), findsOneWidget);
        expect(find.text('Postulado el 10/11/2026'), findsOneWidget);
        expect(find.text('En revisión'), findsNWidgets(2));

        // Verificar orden: la más reciente aparece arriba de la más antigua
        final posReciente = tester.getTopLeft(
          find.text('Arquitecto Mobile Senior'),
        );
        final posAntigua = tester.getTopLeft(
          find.text('Desarrollador Flutter Jr'),
        );
        expect(posReciente.dy, lessThan(posAntigua.dy));
      },
    );

    testWidgets(
      'Tocar una vacante abre JobDetailScreen en modo solo lectura',
      (WidgetTester tester) async {
        fakeSwipeRepo.seedSwipe(
          SwipeRecord(
            id: 'sw-1',
            usuarioId: 'fake-cand-1',
            vacanteId: 'vac-new',
            direccion: SwipeDirections.derecha,
            createdAt: DateTime(2026, 11, 16),
          ),
          vacante: vacReciente,
        );

        final provider = SwipesProvider(
          swipesRepository: fakeSwipeRepo,
          vacanciesRepository: fakeVacRepo,
        );

        await tester.pumpWidget(buildTestApp(provider));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('liked_job_card_vac-new')));
        await tester.pumpAndSettle();

        expect(find.text('Detalle de la vacante'), findsOneWidget);
        expect(
          find.text('Diseño de arquitectura limpia y pruebas automatizadas.'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('btn_detail_apply')), findsNothing);
        expect(find.byKey(const Key('btn_detail_skip')), findsNothing);
      },
    );

    testWidgets(
      'Muestra estado vacío en español cuando no hay postulaciones',
      (WidgetTester tester) async {
        final provider = SwipesProvider(
          swipesRepository: fakeSwipeRepo,
          vacanciesRepository: fakeVacRepo,
        );

        await tester.pumpWidget(buildTestApp(provider));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('empty_liked_jobs_view')), findsOneWidget);
        expect(find.text('Aún no tienes vacantes de interés'), findsOneWidget);
      },
    );
  });
}
