import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fakes/fake_auth_repository.dart';

void main() {
  group('AuthProvider Profile Editing Unit Tests', () {
    late FakeAuthRepository repository;
    late AuthProvider provider;

    setUp(() async {
      repository = FakeAuthRepository();
      provider = AuthProvider(repository: repository);
    });

    test(
      'updateCandidateProfile: actualiza datos en el repositorio y en memoria',
      () async {
        // Registrar candidato inicial
        final okSignUp = await provider.signUpCandidate(
          nombre: 'Elena Ruiz',
          email: 'elena@ejemplo.com',
          password: 'password123',
          ciudad: 'Cali',
          fechaNacimiento: DateTime(1995, 3, 10),
          resumenPerfil: 'Resumen inicial',
        );
        expect(okSignUp, isTrue);
        expect(provider.candidate?.nombre, 'Elena Ruiz');

        // Actualizar datos
        final okUpdate = await provider.updateCandidateProfile(
          nombre: 'Elena Ruiz Gómez',
          ciudad: 'Palmira',
          resumenPerfil: 'Especialista en interfaces accesibles y pruebas E2E.',
        );

        expect(okUpdate, isTrue);
        expect(provider.error, isNull);
        expect(provider.candidate?.nombre, 'Elena Ruiz Gómez');
        expect(provider.candidate?.ciudad, 'Palmira');
        expect(
          provider.candidate?.resumenPerfil,
          'Especialista en interfaces accesibles y pruebas E2E.',
        );

        // Verificar que en el repositorio persistió
        final enRepo = await repository.obtenerUsuario(provider.candidate!.id);
        expect(enRepo['nombre'], 'Elena Ruiz Gómez');
        expect(enRepo['ciudad'], 'Palmira');
        expect(
          enRepo['resumen_perfil'],
          'Especialista en interfaces accesibles y pruebas E2E.',
        );
      },
    );

    test(
      'updateCandidateProfile: falla si el resumen supera los 280 caracteres',
      () async {
        await provider.signUpCandidate(
          nombre: 'Elena Ruiz',
          email: 'elena@ejemplo.com',
          password: 'password123',
          ciudad: 'Cali',
          fechaNacimiento: DateTime(1995, 3, 10),
        );

        final longText = 'A' * 281;
        final okUpdate = await provider.updateCandidateProfile(
          nombre: 'Elena Ruiz',
          ciudad: 'Cali',
          resumenPerfil: longText,
        );

        expect(okUpdate, isFalse);
        expect(
          provider.error,
          'El resumen profesional no puede superar los 280 caracteres',
        );
      },
    );

    test(
      'updateRecruiterProfile: actualiza reclutador y empresa en repositorio y memoria',
      () async {
        final okSignUp = await provider.signUpRecruiter(
          nombre: 'Mateo Ortiz',
          email: 'mateo@startup.com',
          password: 'password123',
          empresaNombre: 'Startup XYZ',
          empresaDescripcion: 'Empresa inicial de desarrollo',
          empresaMonograma: 'SXYZ',
        );
        expect(okSignUp, isTrue);
        expect(provider.recruiter?.nombre, 'Mateo Ortiz');
        expect(provider.recruiter?.empresa.nombre, 'Startup XYZ');

        final okUpdate = await provider.updateRecruiterProfile(
          nombre: 'Mateo Ortiz Peña',
          empresaNombre: 'Startup XYZ Global',
          empresaDescripcion:
              'Plataforma global de logística impulsada por IA.',
          empresaMonograma: 'XYZ',
        );

        expect(okUpdate, isTrue);
        expect(provider.error, isNull);
        expect(provider.recruiter?.nombre, 'Mateo Ortiz Peña');
        expect(provider.recruiter?.empresa.nombre, 'Startup XYZ Global');
        expect(
          provider.recruiter?.empresa.descripcion,
          'Plataforma global de logística impulsada por IA.',
        );
        expect(provider.recruiter?.empresa.monograma, 'XYZ');

        // Verificar repositorio
        final reclutadorRepo = await repository.obtenerReclutadorConEmpresa(
          provider.recruiter!.id,
        );
        expect(reclutadorRepo['nombre'], 'Mateo Ortiz Peña');
        final empresaRepo =
            reclutadorRepo['empresas'] as Map<String, dynamic>;
        expect(empresaRepo['nombre'], 'Startup XYZ Global');
        expect(
          empresaRepo['descripcion'],
          'Plataforma global de logística impulsada por IA.',
        );
        expect(empresaRepo['monograma'], 'XYZ');
      },
    );

    test(
      'updateRecruiterProfile: valida que la descripción no supere los 280 caracteres y monograma sea válido',
      () async {
        await provider.signUpRecruiter(
          nombre: 'Mateo Ortiz',
          email: 'mateo@startup.com',
          password: 'password123',
          empresaNombre: 'Startup XYZ',
          empresaDescripcion: 'Empresa inicial',
          empresaMonograma: 'SXYZ',
        );

        // Descripción > 280
        final failDesc = await provider.updateRecruiterProfile(
          nombre: 'Mateo Ortiz',
          empresaNombre: 'Startup XYZ',
          empresaDescripcion: 'D' * 281,
          empresaMonograma: 'XYZ',
        );
        expect(failDesc, isFalse);
        expect(
          provider.error,
          'La descripción de la empresa no puede superar los 280 caracteres',
        );

        // Monograma vacío o > 3 caracteres
        final failMono = await provider.updateRecruiterProfile(
          nombre: 'Mateo Ortiz',
          empresaNombre: 'Startup XYZ',
          empresaDescripcion: 'Descripción válida',
          empresaMonograma: 'ABCD',
        );
        expect(failMono, isFalse);
        expect(provider.error, 'El monograma debe tener entre 1 y 3 letras');
      },
    );
  });
}
