import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/profile/edit_profile_screen.dart';
import 'package:dreamjob/profile/profile_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'helpers/fake_auth_provider.dart';

void main() {
  group('HU-08: EditProfileScreen Widget Tests', () {
    testWidgets(
      'Candidato: precarga correctamente nombre, ciudad y resumen',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setCandidate(
            nombre: 'Valentina Restrepo',
            email: 'valentina@ejemplo.com',
            ciudad: 'Medellín',
            resumenPerfil: 'Desarrolladora Flutter con experiencia en Bloc',
          );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const EditProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Valentina Restrepo'), findsOneWidget);
        expect(find.text('Medellín'), findsOneWidget);
        expect(
          find.text('Desarrolladora Flutter con experiencia en Bloc'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Candidato: valida campos obligatorios (nombre y ciudad vacíos)',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setCandidate(
            nombre: 'Carlos Pérez',
            email: 'carlos@ejemplo.com',
            ciudad: 'Bogotá',
          );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const EditProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Borrar nombre y ciudad
        final nombreField = find.widgetWithText(TextFormField, 'Carlos Pérez');
        final ciudadField = find.widgetWithText(TextFormField, 'Bogotá');

        await tester.enterText(nombreField, '   ');
        await tester.enterText(ciudadField, '   ');

        final saveBtn = find.text('Guardar cambios');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        expect(
          find.text('El nombre completo es obligatorio'),
          findsOneWidget,
        );
        expect(find.text('La ciudad es obligatorio'), findsOneWidget);
        expect(fakeAuth.updateCandidateCalled, isFalse);
      },
    );

    testWidgets(
      'Candidato: actualiza datos correctamente y llama a updateCandidateProfile',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setCandidate(
            nombre: 'Carlos Pérez',
            email: 'carlos@ejemplo.com',
            ciudad: 'Bogotá',
            resumenPerfil: 'Resumen inicial',
          );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const EditProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final nombreField = find.widgetWithText(TextFormField, 'Carlos Pérez');
        final ciudadField = find.widgetWithText(TextFormField, 'Bogotá');
        final resumenField = find.widgetWithText(
          TextFormField,
          'Resumen inicial',
        );

        await tester.enterText(nombreField, 'Carlos Arturo Pérez');
        await tester.enterText(ciudadField, 'Cali');
        await tester.enterText(
          resumenField,
          'Desarrollador fullstack especializado en Dart y Supabase.',
        );

        final saveBtn = find.text('Guardar cambios');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        expect(fakeAuth.updateCandidateCalled, isTrue);
        expect(
          fakeAuth.lastUpdateCandidateArgs?['nombre'],
          'Carlos Arturo Pérez',
        );
        expect(fakeAuth.lastUpdateCandidateArgs?['ciudad'], 'Cali');
        expect(
          fakeAuth.lastUpdateCandidateArgs?['resumenPerfil'],
          'Desarrollador fullstack especializado en Dart y Supabase.',
        );
      },
    );

    testWidgets(
      'Reclutador: precarga nombre y datos de la empresa',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setRecruiter(
            nombre: 'Sofía Morales',
            email: 'sofia@globex.com',
            empresaNombre: 'Globex Corp',
            empresaDescripcion: 'Empresa global de innovación tecnológica',
            empresaMonograma: 'GBX',
          );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const EditProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sofía Morales'), findsOneWidget);
        expect(find.text('Globex Corp'), findsWidgets);
        expect(
          find.text('Empresa global de innovación tecnológica'),
          findsOneWidget,
        );
        expect(find.text('GBX'), findsWidgets);
      },
    );

    testWidgets(
      'Reclutador: valida monograma inválido y campos requeridos',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setRecruiter(
            nombre: 'Sofía Morales',
            email: 'sofia@globex.com',
            empresaNombre: 'Globex Corp',
            empresaDescripcion: 'Empresa tecnológica',
            empresaMonograma: 'GBX',
          );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const EditProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final monoField = find.widgetWithText(TextFormField, 'GBX');
        await tester.enterText(monoField, '');

        final saveBtn = find.text('Guardar cambios');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        expect(find.text('Este campo es obligatorio'), findsOneWidget);
        expect(fakeAuth.updateRecruiterCalled, isFalse);
      },
    );

    testWidgets(
      'Reclutador: actualiza datos de la empresa y llama a updateRecruiterProfile',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setRecruiter(
            nombre: 'Sofía Morales',
            email: 'sofia@globex.com',
            empresaNombre: 'Globex Corp',
            empresaDescripcion: 'Empresa tecnológica',
            empresaMonograma: 'GBX',
          );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const EditProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final nombreField = find.widgetWithText(TextFormField, 'Sofía Morales');
        final empresaField = find.widgetWithText(TextFormField, 'Globex Corp');
        final descField = find.widgetWithText(
          TextFormField,
          'Empresa tecnológica',
        );
        final monoField = find.widgetWithText(TextFormField, 'GBX');

        await tester.enterText(nombreField, 'Sofía Morales Rivas');
        await tester.enterText(empresaField, 'Globex Internacional');
        await tester.enterText(
          descField,
          'Líderes mundiales en soluciones de software inteligente.',
        );
        await tester.enterText(monoField, 'GXI');

        final saveBtn = find.text('Guardar cambios');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        expect(fakeAuth.updateRecruiterCalled, isTrue);
        expect(
          fakeAuth.lastUpdateRecruiterArgs?['nombre'],
          'Sofía Morales Rivas',
        );
        expect(
          fakeAuth.lastUpdateRecruiterArgs?['empresaNombre'],
          'Globex Internacional',
        );
        expect(
          fakeAuth.lastUpdateRecruiterArgs?['empresaDescripcion'],
          'Líderes mundiales en soluciones de software inteligente.',
        );
        expect(fakeAuth.lastUpdateRecruiterArgs?['empresaMonograma'], 'GXI');
      },
    );

    testWidgets(
      'Flujo integrado: navegar desde ProfileSummaryScreen, editar y reflejar de inmediato en perfil',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setCandidate(
            nombre: 'Andrés López',
            email: 'andres@correo.com',
            ciudad: 'Pereira',
            resumenPerfil: 'Junior Flutter',
          );

        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>.value(
            value: fakeAuth,
            child: MaterialApp(
              routes: {
                '/login': (_) => const SizedBox.shrink(),
                '/profile/edit': (_) => const EditProfileScreen(),
              },
              home: const ProfileSummaryScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Andrés López'), findsOneWidget);
        expect(find.text('Pereira'), findsOneWidget);
        expect(find.text('Junior Flutter'), findsOneWidget);

        // Tocar botón "Editar perfil"
        final editButton = find.widgetWithText(FilledButton, 'Editar perfil');
        await tester.ensureVisible(editButton);
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        // Estamos en EditProfileScreen
        expect(find.text('Editar perfil'), findsOneWidget);

        // Modificar los campos
        final nombreField = find.widgetWithText(TextFormField, 'Andrés López');
        final ciudadField = find.widgetWithText(TextFormField, 'Pereira');
        final resumenField = find.widgetWithText(
          TextFormField,
          'Junior Flutter',
        );

        await tester.enterText(nombreField, 'Andrés Felipe López');
        await tester.enterText(ciudadField, 'Manizales');
        await tester.enterText(
          resumenField,
          'Semi-Senior Mobile Engineer Flutter & Kotlin',
        );

        final saveBtn = find.text('Guardar cambios');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        // Regresó al resumen de perfil y los datos se ven actualizados de inmediato
        expect(find.text('Andrés Felipe López'), findsOneWidget);
        expect(find.text('Manizales'), findsOneWidget);
        expect(
          find.text('Semi-Senior Mobile Engineer Flutter & Kotlin'),
          findsOneWidget,
        );
      },
    );
  });
}
