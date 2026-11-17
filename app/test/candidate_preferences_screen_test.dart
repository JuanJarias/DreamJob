import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/profile/candidate_preferences_screen.dart';
import 'package:dreamjob/profile/profile_summary_screen.dart';
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
  group('HU-07: CandidatePreferencesScreen Widget Tests', () {
    late FakeAuthProvider fakeAuth;
    late VacanciesProvider vacanciesProvider;
    late SwipesProvider swipesProvider;

    setUp(() {
      fakeAuth = FakeAuthProvider()
        ..setCandidate(
          nombre: 'Carlos Demo',
          email: 'carlos.demo@dreamjob.co',
          ciudad: 'Cali',
        );
      final fakeVacRepo = FakeVacanciesRepository();
      vacanciesProvider = VacanciesProvider(repository: fakeVacRepo);
      swipesProvider = SwipesProvider(
        swipesRepository: FakeSwipesRepository(),
        vacanciesRepository: fakeVacRepo,
      );
    });

    Widget buildTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuth),
          ChangeNotifierProvider<VacanciesProvider>.value(
            value: vacanciesProvider,
          ),
          ChangeNotifierProvider<SwipesProvider>.value(value: swipesProvider),
        ],
        child: MaterialApp(
          home: const ProfileSummaryScreen(),
          routes: {
            '/profile/preferences': (_) => const CandidatePreferencesScreen(),
          },
        ),
      );
    }

    testWidgets(
      'Accesible desde Perfil, valida salario numérico y al menos una tecnología, y guarda preferencias',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        final configBtn = find.byKey(const Key('btn_candidate_preferences'));
        await tester.ensureVisible(configBtn);
        await tester.tap(configBtn);
        await tester.pumpAndSettle();

        expect(find.text('Preferencias laborales'), findsOneWidget);

        // Validar salario no numérico y sin tecnologías seleccionadas
        final salaryField = find.byType(TextFormField);
        await tester.enterText(salaryField, 'abc');

        final saveBtn = find.byKey(const Key('btn_save_preferences'));
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        expect(find.text('Ingresa un salario numérico válido'), findsOneWidget);
        expect(
          find.text('Debes seleccionar al menos una tecnología'),
          findsOneWidget,
        );
        expect(fakeAuth.updatePreferencesCalled, isFalse);

        // Llenar preferencias válidas
        await tester.ensureVisible(
          find.byKey(const Key('chip_pref_modalidad_${JobModalities.hibrido}')),
        );
        await tester.tap(
          find.byKey(const Key('chip_pref_modalidad_${JobModalities.hibrido}')),
        );
        await tester.tap(
          find.byKey(
            const Key('chip_pref_seniority_${JobSeniorities.semiSenior}'),
          ),
        );
        await tester.enterText(salaryField, '4500000');

        final flutterChip = find.byKey(const Key('chip_pref_tech_Flutter'));
        await tester.ensureVisible(flutterChip);
        await tester.tap(flutterChip);
        await tester.pumpAndSettle();

        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        expect(fakeAuth.updatePreferencesCalled, isTrue);
        expect(fakeAuth.candidate?.modalidadPreferida, JobModalities.hibrido);
        expect(fakeAuth.candidate?.seniority, JobSeniorities.semiSenior);
        expect(fakeAuth.candidate?.salarioMinimo, 4500000);
        expect(fakeAuth.candidate?.tecnologias.length, 1);
      },
    );
  });
}
