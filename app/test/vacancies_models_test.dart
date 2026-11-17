import 'package:dreamjob/vacancies/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Technology Model Tests', () {
    test('Technology fromMap and toMap serialize correctly', () {
      final map = {
        'id': 'tech-1',
        'nombre': 'Flutter',
        'categoria': 'Móvil',
      };

      final tech = Technology.fromMap(map);
      expect(tech.id, 'tech-1');
      expect(tech.nombre, 'Flutter');
      expect(tech.categoria, 'Móvil');

      final serialized = tech.toMap();
      expect(serialized['id'], 'tech-1');
      expect(serialized['nombre'], 'Flutter');
      expect(serialized['categoria'], 'Móvil');
    });

    test('Technology copyWith updates values or retains original', () {
      const tech = Technology(id: 't1', nombre: 'Dart');
      final updated = tech.copyWith(categoria: 'Lenguaje');

      expect(updated.id, 't1');
      expect(updated.nombre, 'Dart');
      expect(updated.categoria, 'Lenguaje');
    });

    test('Technology equality is based on id', () {
      const techA = Technology(id: 't1', nombre: 'Dart');
      const techB = Technology(id: 't1', nombre: 'Dart SDK');
      const techC = Technology(id: 't2', nombre: 'Dart');

      expect(techA, equals(techB));
      expect(techA, isNot(equals(techC)));
    });
  });

  group('Vacancy Model Tests', () {
    test('Vacancy fromMap parses standard and nested technology structures', () {
      final map = {
        'id': 'vac-1',
        'empresa_id': 'emp-10',
        'reclutador_id': 'rec-20',
        'titulo': 'Desarrollador Flutter Senior',
        'descripcion': 'Liderar el desarrollo de la aplicación móvil.',
        'ubicacion': 'Cali',
        'modalidad': 'Remoto',
        'salario_min': 5000000,
        'salario_max': 7000000,
        'moneda': 'COP',
        'seniority': 'Senior',
        'estado': 'activa',
        'created_at': '2026-11-15T18:00:00.000Z',
        'vacante_tecnologias': [
          {
            'tecnologias': {
              'id': 'tech-1',
              'nombre': 'Flutter',
              'categoria': 'Móvil',
            },
          },
          {
            'tecnologias': {
              'id': 'tech-2',
              'nombre': 'Dart',
              'categoria': 'Móvil',
            },
          },
        ],
      };

      final vacancy = Vacancy.fromMap(map);

      expect(vacancy.id, 'vac-1');
      expect(vacancy.empresaId, 'emp-10');
      expect(vacancy.reclutadorId, 'rec-20');
      expect(vacancy.titulo, 'Desarrollador Flutter Senior');
      expect(vacancy.modalidad, JobModalities.remoto);
      expect(vacancy.seniority, JobSeniorities.senior);
      expect(vacancy.salarioMin, 5000000);
      expect(vacancy.salarioMax, 7000000);
      expect(vacancy.tecnologias.length, 2);
      expect(vacancy.tecnologias.first.nombre, 'Flutter');
      expect(vacancy.tecnologias.last.nombre, 'Dart');
    });

    test('Vacancy fromMap parses string/num salaries and handles nulls', () {
      final map = {
        'empresa_id': 'emp-1',
        'reclutador_id': 'rec-1',
        'titulo': 'Practicante QA',
        'descripcion': 'Pruebas automatizadas',
        'ubicacion': 'Bogotá',
        'salario_min': '1500000',
        'salario_max': 2000000.50,
      };

      final vacancy = Vacancy.fromMap(map);

      expect(vacancy.salarioMin, 1500000);
      expect(vacancy.salarioMax, 2000001);
      expect(vacancy.modalidad, JobModalities.remoto);
      expect(vacancy.seniority, JobSeniorities.junior);
      expect(vacancy.estado, VacancyStatuses.activa);
      expect(vacancy.moneda, 'COP');
      expect(vacancy.tecnologias, isEmpty);
    });

    test('Vacancy toMap serializes correctly with/without id', () {
      final vacancy = Vacancy(
        id: 'vac-99',
        empresaId: 'emp-1',
        reclutadorId: 'rec-1',
        titulo: 'Backend Go',
        descripcion: 'Microservicios en Go',
        ubicacion: 'Medellín',
        modalidad: JobModalities.hibrido,
        seniority: JobSeniorities.semiSenior,
        salarioMin: 4000000,
        salarioMax: 6000000,
      );

      final withId = vacancy.toMap(includeId: true);
      expect(withId['id'], 'vac-99');
      expect(withId['titulo'], 'Backend Go');
      expect(withId['modalidad'], 'Híbrido');
      expect(withId['seniority'], 'Semi-Senior');
      expect(withId['salario_min'], 4000000);
      expect(withId['salario_max'], 6000000);

      final withoutId = vacancy.toMap(includeId: false);
      expect(withoutId.containsKey('id'), isFalse);
    });

    test('Vacancy copyWith allows updating and clearing optional salaries', () {
      final original = Vacancy(
        id: 'v1',
        empresaId: 'e1',
        reclutadorId: 'r1',
        titulo: 'Dev',
        descripcion: 'Desc',
        ubicacion: 'Cali',
        salarioMin: 3000000,
        salarioMax: 4000000,
      );

      final cleared = original.copyWith(
        clearSalarioMin: true,
        clearSalarioMax: true,
        titulo: 'Dev Lead',
      );

      expect(cleared.titulo, 'Dev Lead');
      expect(cleared.salarioMin, isNull);
      expect(cleared.salarioMax, isNull);
      expect(cleared.empresaId, 'e1');
    });

    test('Vacancy fromMap parses candidatosInteresados from swipes or direct field', () {
      final mapWithSwipes = {
        'id': 'v-swipes',
        'empresa_id': 'emp-1',
        'reclutador_id': 'rec-1',
        'titulo': 'Mobile Engineer',
        'descripcion': 'Flutter Apps',
        'ubicacion': 'Remoto',
        'swipes': [
          {'id': 's1', 'direccion': 'derecha'},
          {'id': 's2', 'direccion': 'izquierda'},
          {'id': 's3', 'direccion': 'derecha'},
        ],
      };

      final vacA = Vacancy.fromMap(mapWithSwipes);
      expect(vacA.candidatosInteresados, 2);

      final mapDirect = {
        'id': 'v-direct',
        'empresa_id': 'emp-1',
        'reclutador_id': 'rec-1',
        'titulo': 'Mobile Engineer',
        'descripcion': 'Flutter Apps',
        'ubicacion': 'Remoto',
        'candidatos_interesados': 5,
      };

      final vacB = Vacancy.fromMap(mapDirect);
      expect(vacB.candidatosInteresados, 5);

      final copy = vacB.copyWith(candidatosInteresados: 8);
      expect(copy.candidatosInteresados, 8);
    });
  });
}
