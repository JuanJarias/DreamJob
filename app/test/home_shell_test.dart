import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/home/home_shell.dart';
import 'package:dreamjob/main.dart';
import 'package:dreamjob/swipes/state/swipes_provider.dart';
import 'package:dreamjob/vacancies/data/models.dart';
import 'package:dreamjob/vacancies/state/vacancies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'fakes/fake_swipes_repository.dart';
import 'fakes/fake_vacancies_repository.dart';
import 'helpers/fake_auth_provider.dart';

void main() {
  group('HomeShell & Rutas Nombradas', () {
    testWidgets(
      'Rol candidato muestra 3 pestañas (Deck, Postulaciones, Perfil) y conserva navegación',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setCandidate(
            nombre: 'Valentina Rodríguez',
            email: 'valentina@icesi.edu.co',
            ciudad: 'Cali',
          );

        final fakeSwipes = SwipesProvider(
          swipesRepository: FakeSwipesRepository(),
          vacanciesRepository: FakeVacanciesRepository(),
        );

        await tester.pumpWidget(
          DreamJobApp(
            authProvider: fakeAuth,
            swipesProvider: fakeSwipes,
            initialRoute: '/home',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Deck'), findsOneWidget);
        expect(find.text('Postulaciones'), findsOneWidget);
        expect(find.text('Perfil'), findsOneWidget);
        expect(find.text('Explorar vacantes'), findsOneWidget);

        await tester.tap(find.text('Postulaciones'));
        await tester.pumpAndSettle();
        expect(find.text('Vacantes de interés'), findsOneWidget);

        await tester.tap(find.text('Perfil'));
        await tester.pumpAndSettle();
        expect(find.text('Valentina Rodríguez'), findsOneWidget);
      },
    );

    testWidgets(
      'Rol reclutador muestra 2 pestañas (Vacantes y Perfil)',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setRecruiter(
            nombre: 'Laura Gómez',
            email: 'laura@empresa.co',
            empresaNombre: 'Tech Solutions',
            empresaDescripcion: 'Desarrollo móvil',
            empresaMonograma: 'TS',
          );

        final fakeVacancies = VacanciesProvider(
          repository: FakeVacanciesRepository(),
        );

        await tester.pumpWidget(
          DreamJobApp(
            authProvider: fakeAuth,
            vacanciesProvider: fakeVacancies,
            initialRoute: '/home',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Vacantes'), findsOneWidget);
        expect(find.text('Perfil'), findsOneWidget);
        expect(find.text('Deck'), findsNothing);
        expect(find.text('Mis vacantes'), findsOneWidget);

        await tester.tap(find.text('Perfil'));
        await tester.pumpAndSettle();
        expect(find.text('Tech Solutions'), findsOneWidget);
      },
    );

    testWidgets(
      'Navegación por rutas nombradas entre Login, Registro y Perfil funciona sin go_router',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider();

        await tester.pumpWidget(
          DreamJobApp(authProvider: fakeAuth, initialRoute: '/login'),
        );
        await tester.pumpAndSettle();

        final createBtn = find.text('¿No tienes cuenta? Crear cuenta');
        await tester.ensureVisible(createBtn);
        await tester.tap(createBtn);
        await tester.pumpAndSettle();
        expect(find.text('¿Cómo quieres usar DreamJob?'), findsOneWidget);

        await tester.tap(find.text('Soy candidato'));
        await tester.pumpAndSettle();
        expect(find.text('Registro de candidato'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.text('¿Cómo quieres usar DreamJob?'), findsOneWidget);

        await tester.tap(find.text('Soy reclutador'));
        await tester.pumpAndSettle();
        expect(find.text('Registro de reclutador'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.text('¿Cómo quieres usar DreamJob?'), findsOneWidget);

        await tester.tap(find.text('Volver a iniciar sesión'));
        await tester.pumpAndSettle();
        expect(find.text('Te damos la bienvenida a DreamJob'), findsOneWidget);
      },
    );

    testWidgets(
      'HomeShell sin sesión activa redirige a /login',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider();

        await tester.pumpWidget(
          MaterialApp(
            initialRoute: '/home',
            routes: {
              '/home': (_) => ChangeNotifierProvider<AuthProvider>.value(
                    value: fakeAuth,
                    child: const HomeShell(),
                  ),
              '/login': (_) => const Scaffold(
                    body: Text('Pantalla Login'),
                  ),
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pantalla Login'), findsOneWidget);
      },
    );

    testWidgets(
      'Rol reclutador: muestra RecruiterVacanciesScreen en la pestaña Mis vacantes y navega a crear',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setRecruiter(
            nombre: 'Carlos Restrepo',
            email: 'carlos@empresa.com',
            empresaNombre: 'Innovatech',
            empresaDescripcion: 'Tech',
            empresaMonograma: 'INN',
          );
        final fakeVacancies = VacanciesProvider(
          repository: FakeVacanciesRepository(),
        );

        await tester.pumpWidget(
          DreamJobApp(
            authProvider: fakeAuth,
            vacanciesProvider: fakeVacancies,
            initialRoute: '/home',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Mis vacantes'), findsOneWidget);
        expect(find.text('No tienes vacantes publicadas'), findsOneWidget);
        final publishBtn = find.text('Publicar primera vacante');
        expect(publishBtn, findsOneWidget);

        await tester.tap(publishBtn);
        await tester.pumpAndSettle();

        expect(find.text('Título del cargo'), findsOneWidget);
        expect(find.text('Tecnologías requeridas'), findsOneWidget);
      },
    );

    testWidgets(
      'Rol reclutador: muestra vacantes publicadas existentes en HomeShell',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setRecruiter(
            nombre: 'Carlos Restrepo',
            email: 'carlos@empresa.com',
            empresaId: 'emp-innova',
            empresaNombre: 'Innovatech',
            empresaDescripcion: 'Tech',
            empresaMonograma: 'INN',
          );

        final repo = FakeVacanciesRepository(
          vacantesIniciales: [
            const Vacancy(
              id: 'vac-100',
              empresaId: 'emp-innova',
              reclutadorId: 'rec-1',
              titulo: 'Arquitecto Mobile Flutter',
              descripcion: 'Liderar proyectos',
              ubicacion: 'Bogotá',
              candidatosInteresados: 5,
            ),
          ],
        );

        await tester.pumpWidget(
          DreamJobApp(
            authProvider: fakeAuth,
            vacanciesProvider: VacanciesProvider(repository: repo),
            initialRoute: '/home',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Arquitecto Mobile Flutter'), findsOneWidget);
        expect(find.text('5 candidatos interesados'), findsOneWidget);
      },
    );
  });
}
