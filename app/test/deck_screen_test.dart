import 'package:dreamjob/auth/data/models.dart';
import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/swipes/data/models.dart';
import 'package:dreamjob/swipes/state/swipes_provider.dart';
import 'package:dreamjob/vacancies/data/models.dart';
import 'package:dreamjob/vacancies/screens/deck_screen.dart';
import 'package:dreamjob/vacancies/screens/job_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'fakes/fake_swipes_repository.dart';
import 'fakes/fake_vacancies_repository.dart';
import 'helpers/fake_auth_provider.dart';

void main() {
  const techFlutter =
      Technology(id: 't-flutter', nombre: 'Flutter', categoria: 'Móvil');
  const techDart =
      Technology(id: 't-dart', nombre: 'Dart', categoria: 'Móvil');

  const empresaDemo = CompanyProfile(
    id: 'emp-1',
    nombre: 'NovaTech Labs',
    descripcion: 'Desarrollo de software móvil',
    monograma: 'NT',
  );

  final vac1 = Vacancy(
    id: 'vac-1',
    empresaId: 'emp-1',
    reclutadorId: 'rec-1',
    titulo: 'Desarrollador Flutter Semi-Senior',
    descripcion: 'Apps multiplataforma en producción',
    ubicacion: 'Cali',
    modalidad: JobModalities.remoto,
    seniority: JobSeniorities.semiSenior,
    salarioMin: 4500000,
    salarioMax: 6500000,
    tecnologias: const [techFlutter, techDart],
    empresa: empresaDemo,
  );

  final vac2 = Vacancy(
    id: 'vac-2',
    empresaId: 'emp-1',
    reclutadorId: 'rec-1',
    titulo: 'Ingeniero QA Mobile',
    descripcion: 'Pruebas automatizadas',
    ubicacion: 'Medellín',
    modalidad: JobModalities.hibrido,
    seniority: JobSeniorities.junior,
    empresa: empresaDemo,
  );

  group('HU-05: DeckScreen Widget Tests', () {
    late FakeAuthProvider fakeAuth;
    late FakeVacanciesRepository fakeVacRepo;
    late FakeSwipesRepository fakeSwipeRepo;
    late SwipesProvider swipesProvider;

    setUp(() {
      fakeAuth = FakeAuthProvider()
        ..setCandidate(
          nombre: 'Carlos Demo',
          email: 'carlos.demo@dreamjob.co',
          ciudad: 'Cali',
          modalidadPreferida: JobModalities.remoto,
          seniority: JobSeniorities.semiSenior,
          salarioMinimo: 4000000,
          tecnologias: const [techFlutter],
        );
      fakeVacRepo = FakeVacanciesRepository(vacantesIniciales: [vac1, vac2]);
      fakeSwipeRepo = FakeSwipesRepository();
      swipesProvider = SwipesProvider(
        swipesRepository: fakeSwipeRepo,
        vacanciesRepository: fakeVacRepo,
      );
    });

    Widget buildTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuth),
          ChangeNotifierProvider<SwipesProvider>.value(value: swipesProvider),
        ],
        child: MaterialApp(
          home: const DeckScreen(),
          routes: {
            '/profile/preferences': (_) => const Scaffold(
                  body: Text('Pantalla Preferencias'),
                ),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/vacancies/detail') {
              final vac = settings.arguments as Vacancy;
              return MaterialPageRoute(
                builder: (_) => JobDetailScreen(vacancy: vac),
              );
            }
            return null;
          },
        ),
      );
    }

    testWidgets(
      'Muestra datos de tarjeta, afinidad y permite omitir + deshacer',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Explorar vacantes'), findsOneWidget);
        expect(find.text('NovaTech Labs'), findsOneWidget);
        expect(find.text('NT'), findsOneWidget);
        expect(find.text('Desarrollador Flutter Semi-Senior'), findsOneWidget);
        expect(find.text('Cali'), findsOneWidget);
        expect(find.text('\$ 4.500.000 - \$ 6.500.000 COP'), findsOneWidget);
        expect(find.text('Flutter'), findsOneWidget);
        expect(find.textContaining('Coincide 1 tecnología'), findsOneWidget);

        // Omitir tarjeta
        await tester.tap(find.byKey(const Key('btn_deck_skip')));
        await tester.pumpAndSettle();

        expect(
          fakeSwipeRepo.ultimoSwipeRegistrado?.direccion,
          SwipeDirections.izquierda,
        );
        expect(find.text('Ingeniero QA Mobile'), findsOneWidget);
        expect(find.text('Deshacer'), findsWidgets);

        // Tocar Deshacer desde el botón inferior
        await tester.tap(find.byKey(const Key('btn_deck_undo')));
        await tester.pumpAndSettle();

        expect(fakeSwipeRepo.eliminarSwipeLlamado, isTrue);
        expect(find.text('Desarrollador Flutter Semi-Senior'), findsOneWidget);
      },
    );

    testWidgets(
      'Postular hasta vaciar el deck muestra estado vacío con opciones en español',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('btn_deck_apply')));
        await tester.pumpAndSettle();
        expect(find.text('Ingeniero QA Mobile'), findsOneWidget);

        await tester.tap(find.byKey(const Key('btn_deck_apply')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('empty_deck_view')), findsOneWidget);
        expect(find.text('No quedan vacantes por explorar'), findsOneWidget);
        expect(find.text('Recargar vacantes'), findsOneWidget);
        expect(find.text('Ajustar preferencias'), findsOneWidget);

        await tester.tap(find.byKey(const Key('btn_deck_preferences')));
        await tester.pumpAndSettle();
        expect(find.text('Pantalla Preferencias'), findsOneWidget);
      },
    );

    testWidgets(
      'Tocar tarjeta abre JobDetailScreen con detalle completo',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('deck_card_vac-1')));
        await tester.pumpAndSettle();

        expect(find.text('Detalle de la vacante'), findsOneWidget);
        expect(
          find.text('Apps multiplataforma en producción'),
          findsOneWidget,
        );
      },
    );
  });
}
