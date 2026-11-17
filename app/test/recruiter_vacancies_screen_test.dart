import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/vacancies/data/models.dart';
import 'package:dreamjob/vacancies/screens/recruiter_vacancies_screen.dart';
import 'package:dreamjob/vacancies/state/vacancies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'fakes/fake_vacancies_repository.dart';
import 'helpers/fake_auth_provider.dart';

void main() {
  group('RecruiterVacanciesScreen Tests', () {
    late FakeAuthProvider fakeAuth;
    late FakeVacanciesRepository fakeRepo;
    late VacanciesProvider vacanciesProvider;

    final vacante1 = Vacancy(
      id: 'vac-1',
      empresaId: 'emp-10',
      reclutadorId: 'rec-1',
      titulo: 'Desarrollador Flutter Senior',
      descripcion: 'Liderar desarrollo móvil',
      ubicacion: 'Cali',
      modalidad: JobModalities.remoto,
      seniority: JobSeniorities.senior,
      salarioMin: 4000000,
      salarioMax: 6000000,
      estado: VacancyStatuses.activa,
      candidatosInteresados: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      tecnologias: const [
        Technology(id: 't-flutter', nombre: 'Flutter'),
        Technology(id: 't-dart', nombre: 'Dart'),
      ],
    );

    final vacante2 = Vacancy(
      id: 'vac-2',
      empresaId: 'emp-10',
      reclutadorId: 'rec-1',
      titulo: 'Backend Developer Go',
      descripcion: 'APIs y microservicios',
      ubicacion: 'Medellín',
      modalidad: JobModalities.hibrido,
      seniority: JobSeniorities.semiSenior,
      salarioMin: 5000000,
      salarioMax: null,
      estado: VacancyStatuses.pausada,
      candidatosInteresados: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      tecnologias: const [
        Technology(id: 't-go', nombre: 'Go'),
      ],
    );

    setUp(() {
      fakeAuth = FakeAuthProvider()
        ..setRecruiter(
          nombre: 'Elena Gómez',
          email: 'elena@empresa.com',
          empresaId: 'emp-10',
          empresaNombre: 'Tech Corp',
          empresaDescripcion: 'Empresa tecnológica',
          empresaMonograma: 'TC',
        );

      fakeRepo = FakeVacanciesRepository(
        vacantesIniciales: [vacante1, vacante2],
      );

      vacanciesProvider = VacanciesProvider(repository: fakeRepo);
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuth),
          ChangeNotifierProvider<VacanciesProvider>.value(
            value: vacanciesProvider,
          ),
        ],
        child: MaterialApp(
          home: const RecruiterVacanciesScreen(),
          routes: {
            '/vacancies/new': (context) => const Scaffold(
                  body: Text('Pantalla Nueva Vacante'),
                ),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/vacancies/edit') {
              final arg = settings.arguments as Vacancy?;
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: Text('Pantalla Editar Vacante: ${arg?.titulo}'),
                ),
              );
            }
            return null;
          },
        ),
      );
    }

    testWidgets('Muestra la lista de vacantes con todos los campos requeridos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Título en AppBar
      expect(find.text('Mis vacantes'), findsOneWidget);

      // Vacante 1: datos principales
      expect(find.text('Desarrollador Flutter Senior'), findsOneWidget);
      expect(find.text('Cali'), findsOneWidget);
      expect(find.text('Remoto'), findsOneWidget);
      expect(find.text('\$ 4.000.000 - \$ 6.000.000 COP'), findsOneWidget);
      expect(find.text('Senior'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Activa'), findsOneWidget);
      expect(find.text('3 candidatos interesados'), findsOneWidget);

      // Vacante 2: datos principales
      expect(find.text('Backend Developer Go'), findsOneWidget);
      expect(find.text('Medellín'), findsOneWidget);
      expect(find.text('Híbrido'), findsOneWidget);
      expect(find.text('Desde \$ 5.000.000 COP'), findsOneWidget);
      expect(find.text('Semi-Senior'), findsOneWidget);
      expect(find.text('Go'), findsOneWidget);
      expect(find.text('Pausada'), findsOneWidget);
      expect(find.text('1 candidato interesado'), findsOneWidget);
    });

    testWidgets('Permite cambiar el estado de una vacante mediante el menú', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Abrir menú de opciones de la primera vacante (id vac-1)
      final menuBtn = find.byKey(const Key('status_menu_vac-1'));
      expect(menuBtn, findsOneWidget);
      await tester.tap(menuBtn);
      await tester.pumpAndSettle();

      // Seleccionar "Pausada"
      final pausadaOption = find.text('Pausada').last;
      await tester.tap(pausadaOption);
      await tester.pumpAndSettle();

      // Verificar que se actualizó en el repositorio
      expect(fakeRepo.cambiarEstadoLlamado, isTrue);
      expect(fakeRepo.ultimoEstadoCambiado, VacancyStatuses.pausada);

      // Verificar feedback visual SnackBar
      expect(
        find.text('Estado de la vacante actualizado a "pausada"'),
        findsOneWidget,
      );
    });

    testWidgets('Al tocar botón Editar navega a /vacancies/edit con la vacante', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final editBtn = find.byKey(const Key('btn_edit_card_vac-1'));
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('Pantalla Editar Vacante: Desarrollador Flutter Senior'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Muestra estado vacío claro y botón para publicar cuando no hay ofertas',
      (WidgetTester tester) async {
        final emptyRepo = FakeVacanciesRepository(vacantesIniciales: []);
        final emptyVacancies = VacanciesProvider(repository: emptyRepo);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: fakeAuth),
              ChangeNotifierProvider<VacanciesProvider>.value(
                value: emptyVacancies,
              ),
            ],
            child: MaterialApp(
              home: const RecruiterVacanciesScreen(),
              routes: {
                '/vacancies/new': (context) => const Scaffold(
                      body: Text('Pantalla Nueva Vacante'),
                    ),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('empty_vacancies_view')), findsOneWidget);
        expect(find.text('No tienes vacantes publicadas'), findsOneWidget);
        expect(
          find.text(
            'Publica tu primera oferta laboral para comenzar a atraer y evaluar candidatos compatibles.',
          ),
          findsOneWidget,
        );

        final emptyPublishBtn = find.byKey(
          const Key('btn_empty_publish_vacancy'),
        );
        expect(emptyPublishBtn, findsOneWidget);

        await tester.tap(emptyPublishBtn);
        await tester.pumpAndSettle();

        expect(find.text('Pantalla Nueva Vacante'), findsOneWidget);
      },
    );

    testWidgets('Botón FAB de publicar vacante navega a /vacancies/new', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final fab = find.byKey(const Key('btn_publish_vacancy'));
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('Pantalla Nueva Vacante'), findsOneWidget);
    });
  });
}
