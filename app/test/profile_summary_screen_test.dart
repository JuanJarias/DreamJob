import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/profile/profile_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'helpers/fake_auth_provider.dart';

void main() {
  group('ProfileSummaryScreen Widget Tests', () {
    testWidgets(
      'Rol candidato: se ven nombre, email y ciudad',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setCandidate(
            nombre: 'Mariana López',
            email: 'mariana.lopez@correo.com',
            ciudad: 'Cali',
            fechaNacimiento: DateTime(1998, 5, 20),
            resumenPerfil: 'Ingeniera de software con pasión por Flutter',
          );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const ProfileSummaryScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Criterio: se ven nombre, email y ciudad
        expect(find.text('Mariana López'), findsOneWidget);
        expect(find.text('mariana.lopez@correo.com'), findsOneWidget);
        expect(find.text('Cali'), findsOneWidget);

        // Avatar con iniciales, rol y resumen
        expect(find.text('ML'), findsOneWidget);
        expect(find.text('Candidato'), findsOneWidget);
        expect(
          find.text('Ingeniera de software con pasión por Flutter'),
          findsOneWidget,
        );
        expect(find.textContaining('1998-05-20'), findsOneWidget);
        expect(find.textContaining('años'), findsOneWidget);
      },
    );

    testWidgets(
      'Rol candidato con resumen vacío: muestra "Sin resumen"',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setCandidate(
            nombre: 'Juan Pérez',
            email: 'juan@correo.com',
            ciudad: 'Bogotá',
            resumenPerfil: null,
          );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const ProfileSummaryScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Juan Pérez'), findsOneWidget);
        expect(find.text('Sin resumen'), findsOneWidget);
      },
    );

    testWidgets(
      'Rol reclutador: se ve la empresa (nombre, descripción y monograma)',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setRecruiter(
            nombre: 'Roberto Gómez',
            email: 'roberto@bancoccidente.com',
            empresaNombre: 'Banco de Occidente',
            empresaDescripcion:
                'Entidad financiera líder en servicios corporativos',
            empresaMonograma: 'BDO',
          );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const ProfileSummaryScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Datos del reclutador
        expect(find.text('Roberto Gómez'), findsOneWidget);
        expect(find.text('roberto@bancoccidente.com'), findsOneWidget);
        expect(find.text('RG'), findsOneWidget);
        expect(find.text('Reclutador'), findsOneWidget);

        // Criterio: se ve la empresa
        expect(find.text('Banco de Occidente'), findsOneWidget);
        expect(
          find.text('Entidad financiera líder en servicios corporativos'),
          findsOneWidget,
        );
        expect(find.text('BDO'), findsWidgets);
        expect(find.text('Monograma: BDO'), findsOneWidget);
      },
    );

    testWidgets(
      'Cuando role es null o loading es true, muestra CircularProgressIndicator',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const ProfileSummaryScreen(),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Botón Cerrar sesión invoca signOut en AuthProvider',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider()
          ..setCandidate(
            nombre: 'Ana Gómez',
            email: 'ana@correo.com',
            ciudad: 'Medellín',
          );

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const ProfileSummaryScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final logoutBtn = find.text('Cerrar sesión');
        await tester.ensureVisible(logoutBtn);
        await tester.tap(logoutBtn);
        await tester.pump();

        expect(fakeAuth.signOutCalled, isTrue);
      },
    );
  });
}
