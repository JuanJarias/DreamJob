import 'package:dreamjob/auth/data/models.dart';
import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/swipes/data/models.dart';
import 'package:dreamjob/swipes/state/swipes_provider.dart';
import 'package:dreamjob/vacancies/data/models.dart';
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

  const vacante = Vacancy(
    id: 'vac-det-1',
    empresaId: 'emp-1',
    reclutadorId: 'rec-1',
    titulo: 'Arquitecto Flutter',
    descripcion: 'Liderar diseño de módulos móviles escalables.',
    ubicacion: 'Bogotá',
    modalidad: JobModalities.hibrido,
    seniority: JobSeniorities.senior,
    salarioMin: 7000000,
    salarioMax: 9000000,
    tecnologias: [techFlutter],
    empresa: CompanyProfile(
      id: 'emp-1',
      nombre: 'Andes Digital',
      descripcion: 'Consultora de ingeniería móvil en Latinoamérica.',
      monograma: 'AD',
    ),
  );

  group('HU-06: JobDetailScreen Widget Tests', () {
    late FakeAuthProvider fakeAuth;
    late FakeSwipesRepository fakeSwipeRepo;
    late SwipesProvider swipesProvider;

    setUp(() {
      fakeAuth = FakeAuthProvider()
        ..setCandidate(
          nombre: 'Carlos Demo',
          email: 'carlos.demo@dreamjob.co',
          ciudad: 'Cali',
          tecnologias: const [techFlutter],
        );
      fakeSwipeRepo = FakeSwipesRepository();
      swipesProvider = SwipesProvider(
        swipesRepository: fakeSwipeRepo,
        vacanciesRepository: FakeVacanciesRepository(
          vacantesIniciales: [vacante],
        ),
      );
    });

    testWidgets(
      'Muestra información completa y registra Postular regresando a la pantalla anterior',
      (WidgetTester tester) async {
        String? popResult;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: fakeAuth),
              ChangeNotifierProvider<SwipesProvider>.value(
                value: swipesProvider,
              ),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      popResult = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JobDetailScreen(
                            vacancy: vacante,
                          ),
                        ),
                      );
                    },
                    child: const Text('Ver detalle'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Ver detalle'));
        await tester.pumpAndSettle();

        expect(find.text('Andes Digital'), findsOneWidget);
        expect(find.text('AD'), findsOneWidget);
        expect(
          find.text('Consultora de ingeniería móvil en Latinoamérica.'),
          findsOneWidget,
        );
        expect(find.text('Arquitecto Flutter'), findsOneWidget);
        expect(find.text('Híbrido'), findsOneWidget);
        expect(find.text('Bogotá'), findsOneWidget);
        expect(find.text('Senior'), findsOneWidget);
        expect(find.text('\$ 7.000.000 - \$ 9.000.000 COP'), findsOneWidget);
        expect(find.text('Flutter'), findsOneWidget);
        expect(
          find.text('Liderar diseño de módulos móviles escalables.'),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('btn_detail_apply')));
        await tester.pumpAndSettle();

        expect(fakeSwipeRepo.registrarSwipeLlamado, isTrue);
        expect(
          fakeSwipeRepo.ultimoSwipeRegistrado?.direccion,
          SwipeDirections.derecha,
        );
        expect(popResult, SwipeDirections.derecha);
      },
    );
  });
}
