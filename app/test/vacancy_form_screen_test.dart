import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/auth/widgets/auth_primary_button.dart';
import 'package:dreamjob/auth/widgets/auth_text_field.dart';
import 'package:dreamjob/vacancies/data/models.dart';
import 'package:dreamjob/vacancies/screens/vacancy_form_screen.dart';
import 'package:dreamjob/vacancies/state/vacancies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'fakes/fake_vacancies_repository.dart';
import 'helpers/fake_auth_provider.dart';

void main() {
  group('HU-09: VacancyFormScreen Widget Tests', () {
    late FakeAuthProvider fakeAuth;
    late FakeVacanciesRepository fakeRepo;
    late VacanciesProvider vacanciesProvider;

    setUp(() {
      fakeAuth = FakeAuthProvider()
        ..setRecruiter(
          nombre: 'Santiago Gómez',
          email: 'santiago@tech.co',
          empresaNombre: 'Tech Corp',
          empresaDescripcion: 'Empresa de desarrollo',
          empresaMonograma: 'TC',
        );
      fakeRepo = FakeVacanciesRepository();
      vacanciesProvider = VacanciesProvider(repository: fakeRepo);
    });

    Widget createScreen({Vacancy? vacancy}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuth),
          ChangeNotifierProvider<VacanciesProvider>.value(
            value: vacanciesProvider,
          ),
        ],
        child: MaterialApp(
          home: VacancyFormScreen(vacancy: vacancy),
        ),
      );
    }

    testWidgets(
      'Valida campos obligatorios vacíos y selección obligatoria de tecnologías',
      (WidgetTester tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // Título del appbar
        expect(find.text('Publicar vacante'), findsWidgets);

        // Tocar botón Publicar vacante sin llenar nada
        final submitBtn = find.byType(AuthPrimaryButton);
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        // Criterio: validaciones en español
        expect(find.text('El título del cargo es obligatorio'), findsOneWidget);
        expect(find.text('La ubicación es obligatorio'), findsOneWidget);
        expect(find.text('La descripción es obligatorio'), findsOneWidget);
        expect(
          find.text('Debes seleccionar al menos una tecnología'),
          findsOneWidget,
        );
        expect(fakeRepo.crearVacanteLlamado, isFalse);
      },
    );

    testWidgets(
      'Valida que el salario máximo no sea menor al salario mínimo',
      (WidgetTester tester) async {
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        final minField = find.descendant(
          of: find.widgetWithText(AuthTextField, 'Salario mínimo'),
          matching: find.byType(TextFormField),
        );
        final maxField = find.descendant(
          of: find.widgetWithText(AuthTextField, 'Salario máximo'),
          matching: find.byType(TextFormField),
        );

        await tester.ensureVisible(minField);
        await tester.enterText(minField, '5000000');
        await tester.ensureVisible(maxField);
        await tester.enterText(maxField, '3000000');

        final submitBtn = find.byType(AuthPrimaryButton);
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(
          find.text('El salario máximo no puede ser menor al salario mínimo'),
          findsOneWidget,
        );
        expect(fakeRepo.crearVacanteLlamado, isFalse);
      },
    );

    testWidgets(
      'Crear vacante exitosamente registra en repositorio y hace pop',
      (WidgetTester tester) async {
        bool didPop = false;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: fakeAuth),
              ChangeNotifierProvider<VacanciesProvider>.value(
                value: vacanciesProvider,
              ),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VacancyFormScreen(),
                          ),
                        );
                        if (result == true) {
                          didPop = true;
                        }
                      },
                      child: const Text('Abrir Formulario'),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Abrir formulario
        await tester.tap(find.text('Abrir Formulario'));
        await tester.pumpAndSettle();

        // Llenar campos
        final tituloField = find.descendant(
          of: find.widgetWithText(AuthTextField, 'Título del cargo'),
          matching: find.byType(TextFormField),
        );
        final ubicacionField = find.descendant(
          of: find.widgetWithText(AuthTextField, 'Ubicación / Ciudad'),
          matching: find.byType(TextFormField),
        );
        final descripcionField = find.descendant(
          of: find.widgetWithText(AuthTextField, 'Descripción del puesto'),
          matching: find.byType(TextFormField),
        );
        final minField = find.descendant(
          of: find.widgetWithText(AuthTextField, 'Salario mínimo'),
          matching: find.byType(TextFormField),
        );
        final maxField = find.descendant(
          of: find.widgetWithText(AuthTextField, 'Salario máximo'),
          matching: find.byType(TextFormField),
        );

        await tester.ensureVisible(tituloField);
        await tester.enterText(tituloField, 'Ingeniero Flutter Semi-Senior');
        await tester.ensureVisible(ubicacionField);
        await tester.enterText(ubicacionField, 'Cali, Colombia');
        await tester.ensureVisible(descripcionField);
        await tester.enterText(
          descripcionField,
          'Responsable del diseño de arquitectura y desarrollo de features móviles.',
        );
        await tester.ensureVisible(minField);
        await tester.enterText(minField, '4000000');
        await tester.ensureVisible(maxField);
        await tester.enterText(maxField, '6000000');

        // Seleccionar chips de tecnologías
        final flutterChip = find.widgetWithText(FilterChip, 'Flutter');
        await tester.ensureVisible(flutterChip);
        await tester.tap(flutterChip);
        await tester.pumpAndSettle();

        final dartChip = find.widgetWithText(FilterChip, 'Dart');
        await tester.ensureVisible(dartChip);
        await tester.tap(dartChip);
        await tester.pumpAndSettle();

        // Guardar
        final submitBtn = find.byType(AuthPrimaryButton);
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        // Verificaciones
        expect(fakeRepo.crearVacanteLlamado, isTrue);
        expect(
          fakeRepo.ultimaVacanteCreada?.titulo,
          'Ingeniero Flutter Semi-Senior',
        );
        expect(fakeRepo.ultimaVacanteCreada?.ubicacion, 'Cali, Colombia');
        expect(fakeRepo.ultimaVacanteCreada?.salarioMin, 4000000);
        expect(fakeRepo.ultimaVacanteCreada?.salarioMax, 6000000);
        expect(fakeRepo.ultimasTecnologiasCreadas?.length, 2);
        expect(didPop, isTrue);
      },
    );

    testWidgets(
      'Modo edición precarga los datos de la vacante y permite actualizar',
      (WidgetTester tester) async {
        const techFlutter = Technology(id: 't-flutter', nombre: 'Flutter', categoria: 'Móvil');
        const techDart = Technology(id: 't-dart', nombre: 'Dart', categoria: 'Móvil');

        final vacanteExistente = Vacancy(
          id: 'vac-100',
          empresaId: 'fake-emp-1',
          reclutadorId: 'fake-rec-1',
          titulo: 'Desarrollador Flutter Jr',
          descripcion: 'Mantenimiento de componentes visuales',
          ubicacion: 'Medellín',
          modalidad: JobModalities.hibrido,
          seniority: JobSeniorities.junior,
          salarioMin: 2500000,
          salarioMax: 3500000,
          tecnologias: const [techFlutter, techDart],
        );

        bool didPop = false;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: fakeAuth),
              ChangeNotifierProvider<VacanciesProvider>.value(
                value: vacanciesProvider,
              ),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VacancyFormScreen(
                              vacancy: vacanteExistente,
                            ),
                          ),
                        );
                        if (result == true) {
                          didPop = true;
                        }
                      },
                      child: const Text('Abrir Edición'),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Abrir Edición'));
        await tester.pumpAndSettle();

        // Título de la vista en modo edición
        expect(find.text('Editar vacante'), findsOneWidget);

        // Precarga de campos
        expect(find.text('Desarrollador Flutter Jr'), findsOneWidget);
        expect(find.text('Medellín'), findsOneWidget);
        expect(find.text('Mantenimiento de componentes visuales'), findsOneWidget);
        expect(find.text('2500000'), findsOneWidget);
        expect(find.text('3500000'), findsOneWidget);

        // Modificar título
        final tituloField = find.descendant(
          of: find.widgetWithText(AuthTextField, 'Título del cargo'),
          matching: find.byType(TextFormField),
        );
        await tester.ensureVisible(tituloField);
        await tester.enterText(
          tituloField,
          'Desarrollador Flutter Semi-Senior Promovido',
        );

        // Guardar cambios
        final saveBtn = find.byType(AuthPrimaryButton);
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        expect(fakeRepo.actualizarVacanteLlamado, isTrue);
        expect(
          fakeRepo.ultimaVacanteActualizada?.titulo,
          'Desarrollador Flutter Semi-Senior Promovido',
        );
        expect(didPop, isTrue);
      },
    );
  });
}
