import 'package:dreamjob/vacancies/data/models.dart';
import 'package:dreamjob/vacancies/state/vacancies_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fakes/fake_vacancies_repository.dart';

void main() {
  group('VacanciesProvider Tests', () {
    late FakeVacanciesRepository repository;
    late VacanciesProvider provider;

    setUp(() {
      repository = FakeVacanciesRepository();
      provider = VacanciesProvider(repository: repository);
    });

    test('cargarCatalogoTecnologias obtiene el listado del repositorio', () async {
      expect(provider.catalogoTecnologias, isEmpty);

      await provider.cargarCatalogoTecnologias();

      expect(provider.catalogoTecnologias.length, 14);
      expect(provider.loading, isFalse);
      expect(provider.error, isNull);
      expect(provider.catalogoTecnologias.any((t) => t.nombre == 'Flutter'), isTrue);
    });

    test('guardarVacante falla si faltan campos obligatorios', () async {
      final vacanteIncompleta = Vacancy(
        empresaId: 'emp-1',
        reclutadorId: 'rec-1',
        titulo: '   ',
        descripcion: 'Descripción',
        ubicacion: 'Cali',
      );

      final result = await provider.guardarVacante(
        vacante: vacanteIncompleta,
        tecnologiaIds: ['t-flutter'],
      );

      expect(result, isNull);
      expect(provider.error, 'Completa todos los campos obligatorios');
      expect(repository.crearVacanteLlamado, isFalse);
    });

    test('guardarVacante falla si no se selecciona ninguna tecnología', () async {
      final vacante = Vacancy(
        empresaId: 'emp-1',
        reclutadorId: 'rec-1',
        titulo: 'Desarrollador Flutter',
        descripcion: 'Descripción completa',
        ubicacion: 'Medellín',
      );

      final result = await provider.guardarVacante(
        vacante: vacante,
        tecnologiaIds: [],
      );

      expect(result, isNull);
      expect(provider.error, 'Debes seleccionar al menos una tecnología');
      expect(repository.crearVacanteLlamado, isFalse);
    });

    test('guardarVacante valida que salario máximo no sea menor al mínimo', () async {
      final vacante = Vacancy(
        empresaId: 'emp-1',
        reclutadorId: 'rec-1',
        titulo: 'Desarrollador Flutter',
        descripcion: 'Descripción completa',
        ubicacion: 'Medellín',
        salarioMin: 5000000,
        salarioMax: 3000000,
      );

      final result = await provider.guardarVacante(
        vacante: vacante,
        tecnologiaIds: ['t-flutter'],
      );

      expect(result, isNull);
      expect(
        provider.error,
        'El salario máximo no puede ser menor al salario mínimo',
      );
      expect(repository.crearVacanteLlamado, isFalse);
    });

    test('guardarVacante nueva crea la vacante y la agrega a vacantesEmpresa', () async {
      final vacante = Vacancy(
        empresaId: 'emp-1',
        reclutadorId: 'rec-1',
        titulo: 'Mobile Lead',
        descripcion: 'Liderar equipo de aplicaciones Flutter',
        ubicacion: 'Cali',
        modalidad: JobModalities.remoto,
        seniority: JobSeniorities.senior,
        salarioMin: 6000000,
        salarioMax: 8000000,
      );

      final creada = await provider.guardarVacante(
        vacante: vacante,
        tecnologiaIds: ['t-flutter', 't-dart'],
      );

      expect(creada, isNotNull);
      expect(creada!.id, isNotNull);
      expect(creada.tecnologias.length, 2);
      expect(provider.error, isNull);
      expect(repository.crearVacanteLlamado, isTrue);
      expect(provider.vacantesEmpresa.contains(creada), isTrue);
    });

    test('guardarVacante existente actualiza los datos y la lista de vacantes', () async {
      // 1. Crear primero una vacante
      final creada = await repository.crearVacante(
        vacante: Vacancy(
          empresaId: 'emp-1',
          reclutadorId: 'rec-1',
          titulo: 'Junior Dart',
          descripcion: 'Desarrollo base',
          ubicacion: 'Bogotá',
        ),
        tecnologiaIds: ['t-dart'],
      );

      await provider.cargarVacantesEmpresa('emp-1');
      expect(provider.vacantesEmpresa.length, 1);

      // 2. Modificarla
      final vacanteEditada = creada.copyWith(
        titulo: 'Semi-Senior Dart & Flutter',
        seniority: JobSeniorities.semiSenior,
      );

      final resultado = await provider.guardarVacante(
        vacante: vacanteEditada,
        tecnologiaIds: ['t-dart', 't-flutter'],
      );

      expect(resultado, isNotNull);
      expect(resultado!.titulo, 'Semi-Senior Dart & Flutter');
      expect(resultado.tecnologias.length, 2);
      expect(repository.actualizarVacanteLlamado, isTrue);

      final enLista = provider.vacantesEmpresa.firstWhere((v) => v.id == creada.id);
      expect(enLista.titulo, 'Semi-Senior Dart & Flutter');
    });

    test('Mapeo de errores de Postgrest con restricción salarial', () async {
      repository.shouldThrow = true;
      repository.errorToThrow = const PostgrestException(
        message: 'new row violates check constraint "vacantes_check_salario_max"',
        code: '23514',
      );

      final vacante = Vacancy(
        empresaId: 'emp-1',
        reclutadorId: 'rec-1',
        titulo: 'QA',
        descripcion: 'Testing',
        ubicacion: 'Cali',
      );

      final result = await provider.guardarVacante(
        vacante: vacante,
        tecnologiaIds: ['t-flutter'],
      );

      expect(result, isNull);
      expect(
        provider.error,
        'El salario máximo no puede ser menor al salario mínimo',
      );
    });
  });
}
