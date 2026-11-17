import 'package:dreamjob/auth/data/models.dart';
import 'package:dreamjob/swipes/data/models.dart';
import 'package:dreamjob/swipes/state/swipes_provider.dart';
import 'package:dreamjob/vacancies/data/affinity.dart';
import 'package:dreamjob/vacancies/data/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fakes/fake_swipes_repository.dart';
import 'fakes/fake_vacancies_repository.dart';

void main() {
  const techFlutter =
      Technology(id: 't-flutter', nombre: 'Flutter', categoria: 'Móvil');
  const techDart =
      Technology(id: 't-dart', nombre: 'Dart', categoria: 'Móvil');
  const techGo = Technology(id: 't-go', nombre: 'Go', categoria: 'Backend');

  final candidate = CandidateProfile(
    id: 'cand-1',
    nombre: 'Carlos Demo',
    email: 'carlos.demo@dreamjob.co',
    ciudad: 'Cali',
    fechaNacimiento: DateTime(2000, 1, 1),
    modalidadPreferida: JobModalities.remoto,
    seniority: JobSeniorities.semiSenior,
    salarioMinimo: 4000000,
    tecnologias: const [techFlutter, techDart],
  );

  const vacAltaAfinidad = Vacancy(
    id: 'vac-alta',
    empresaId: 'emp-1',
    reclutadorId: 'rec-1',
    titulo: 'Flutter Senior Engineer',
    descripcion: 'Construir app móvil',
    ubicacion: 'Cali',
    modalidad: JobModalities.remoto,
    seniority: JobSeniorities.semiSenior,
    salarioMin: 4500000,
    salarioMax: 6500000,
    estado: VacancyStatuses.activa,
    tecnologias: [techFlutter, techDart],
  );

  const vacBajaAfinidad = Vacancy(
    id: 'vac-baja',
    empresaId: 'emp-1',
    reclutadorId: 'rec-1',
    titulo: 'Backend Go',
    descripcion: 'Servicios Go',
    ubicacion: 'Bogotá',
    modalidad: JobModalities.presencial,
    seniority: JobSeniorities.senior,
    salarioMin: 2500000,
    salarioMax: 3500000,
    estado: VacancyStatuses.activa,
    tecnologias: [techGo],
  );

  const vacPausada = Vacancy(
    id: 'vac-pausada',
    empresaId: 'emp-1',
    reclutadorId: 'rec-1',
    titulo: 'Vacante Pausada',
    descripcion: 'No visible en deck',
    ubicacion: 'Medellín',
    estado: VacancyStatuses.pausada,
  );

  group('Affinity & SwipesProvider Tests', () {
    test('calculateVacancyAffinity calcula coincidencias y razones en español',
        () {
      final res = calculateVacancyAffinity(
        vacante: vacAltaAfinidad,
        candidate: candidate,
      );

      expect(res.matchingTechIds, containsAll(['t-flutter', 't-dart']));
      expect(res.score, greaterThan(50));
      expect(
        res.razones.any((r) => r.contains('Coinciden 2 tecnologías')),
        isTrue,
      );
      expect(
        res.razones.any((r) => r.contains('Modalidad Remoto coincide')),
        isTrue,
      );
      expect(
        res.razones.any((r) => r.contains('Nivel Semi-Senior coincide')),
        isTrue,
      );
      expect(
        res.razones.any((r) => r.contains('Salario acorde a tu expectativa')),
        isTrue,
      );
    });

    test('cargarDeckYSwipes excluye pausadas/evaluadas y ordena por afinidad',
        () async {
      final vacRepo = FakeVacanciesRepository(
        vacantesIniciales: [vacBajaAfinidad, vacPausada, vacAltaAfinidad],
      );
      final swipeRepo = FakeSwipesRepository();
      final provider = SwipesProvider(
        swipesRepository: swipeRepo,
        vacanciesRepository: vacRepo,
      );

      await provider.cargarDeckYSwipes(
        usuarioId: candidate.id,
        candidate: candidate,
      );

      expect(provider.loading, isFalse);
      expect(provider.error, isNull);
      expect(provider.deck.length, 2);
      expect(provider.deck.first.id, 'vac-alta');
      expect(provider.deck.last.id, 'vac-baja');
    });

    test('registrarSwipe guarda swipe y deshacerUltimoDescarte restaura tope',
        () async {
      final vacRepo = FakeVacanciesRepository(
        vacantesIniciales: [vacAltaAfinidad, vacBajaAfinidad],
      );
      final swipeRepo = FakeSwipesRepository();
      final provider = SwipesProvider(
        swipesRepository: swipeRepo,
        vacanciesRepository: vacRepo,
      );

      await provider.cargarDeckYSwipes(
        usuarioId: candidate.id,
        candidate: candidate,
      );

      final skippedOk = await provider.registrarSwipe(
        usuarioId: candidate.id,
        vacante: vacAltaAfinidad,
        direccion: SwipeDirections.izquierda,
      );

      expect(skippedOk, isTrue);
      expect(swipeRepo.registrarSwipeLlamado, isTrue);
      expect(provider.canUndo, isTrue);
      expect(provider.deck.length, 1);
      expect(provider.deck.first.id, 'vac-baja');

      final undoOk = await provider.deshacerUltimoDescarte();

      expect(undoOk, isTrue);
      expect(swipeRepo.eliminarSwipeLlamado, isTrue);
      expect(provider.canUndo, isFalse);
      expect(provider.deck.length, 2);
      expect(provider.deck.first.id, 'vac-alta');

      final appliedOk = await provider.registrarSwipe(
        usuarioId: candidate.id,
        vacante: vacAltaAfinidad,
        direccion: SwipeDirections.derecha,
      );

      expect(appliedOk, isTrue);
      expect(provider.canUndo, isFalse);
      expect(provider.likedSwipes.length, 1);
      expect(provider.likedSwipes.first.vacanteId, 'vac-alta');
    });
  });
}
