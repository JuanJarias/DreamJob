import '../../auth/data/models.dart';
import 'models.dart';

class VacancyAffinity {
  final int score;
  final Set<String> matchingTechIds;
  final List<String> razones;

  const VacancyAffinity({
    required this.score,
    required this.matchingTechIds,
    required this.razones,
  });
}

/// Calcula los criterios de afinidad entre un candidato y una vacante.
VacancyAffinity calculateVacancyAffinity({
  required Vacancy vacante,
  CandidateProfile? candidate,
}) {
  if (candidate == null) {
    return const VacancyAffinity(
      score: 0,
      matchingTechIds: {},
      razones: [],
    );
  }

  final candidateTechIds = candidate.tecnologias.map((t) => t.id).toSet();
  final candidateTechNames =
      candidate.tecnologias.map((t) => t.nombre.toLowerCase()).toSet();

  final matchingIds = <String>{};
  final matchingNames = <String>[];

  for (final tech in vacante.tecnologias) {
    final matchesById = candidateTechIds.contains(tech.id);
    final matchesByName = candidateTechNames.contains(tech.nombre.toLowerCase());
    if (matchesById || matchesByName) {
      matchingIds.add(tech.id);
      matchingNames.add(tech.nombre);
    }
  }

  var score = 0;
  final razones = <String>[];

  if (matchingNames.isNotEmpty) {
    score += matchingNames.length * 20;
    final preview = matchingNames.take(3).join(', ');
    final label = matchingNames.length == 1
        ? 'Coincide 1 tecnología ($preview)'
        : 'Coinciden ${matchingNames.length} tecnologías ($preview)';
    razones.add(label);
  }

  if (candidate.modalidadPreferida != null &&
      candidate.modalidadPreferida == vacante.modalidad) {
    score += 25;
    razones.add('Modalidad ${vacante.modalidad} coincide');
  }

  if (candidate.seniority != null && candidate.seniority == vacante.seniority) {
    score += 20;
    razones.add('Nivel ${vacante.seniority} coincide');
  }

  if (candidate.salarioMinimo != null) {
    final techoSalario = vacante.salarioMax ?? vacante.salarioMin;
    if (techoSalario != null && techoSalario >= candidate.salarioMinimo!) {
      score += 15;
      razones.add('Salario acorde a tu expectativa');
    }
  }

  return VacancyAffinity(
    score: score,
    matchingTechIds: matchingIds,
    razones: razones,
  );
}
