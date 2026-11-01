import 'package:dreamjob/auth/screens/register_recruiter_screen.dart';
import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'helpers/fake_auth_provider.dart';

void main() {
  group('RegisterRecruiterScreen Widget Tests', () {
    testWidgets(
      'Enviar formulario vacío muestra errores de validación y NO llama a signUpRecruiter',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const RegisterRecruiterScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Registro de reclutador'), findsOneWidget);
        expect(find.text('Tus datos'), findsOneWidget);
        expect(find.text('Tu empresa'), findsOneWidget);
        expect(find.text('Vista previa del monograma'), findsOneWidget);

        final submitBtn = find.text('Crear cuenta');
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pump();

        // Criterio: muestra los errores de validación
        expect(find.text('Este campo es obligatorio'), findsNWidgets(5));
        expect(find.text('El correo electrónico es obligatorio'), findsOneWidget);
        expect(find.text('La contraseña es obligatoria'), findsOneWidget);

        // Criterio: NO llama a signUpRecruiter
        expect(fakeAuth.signUpRecruiterCalled, isFalse);
        expect(fakeAuth.signUpRecruiterCallCount, 0);
        expect(fakeAuth.lastSignUpRecruiterArgs, isNull);
      },
    );

    testWidgets(
      'Monograma se convierte a mayúsculas automáticamente y actualiza la vista previa',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const RegisterRecruiterScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final fields = find.byType(TextFormField);
        // fields: [0: Nombre, 1: Correo, 2: Password, 3: ConfirmPassword, 4: Empresa, 5: Descripción, 6: Monograma]
        await tester.enterText(fields.at(4), 'Acme Corporation');
        await tester.enterText(fields.at(6), 'acm');
        await tester.pump();

        // Monograma en mayúsculas
        expect(find.text('ACM'), findsWidgets);
        expect(find.text('Monograma: ACM'), findsOneWidget);
        expect(find.text('Acme Corporation'), findsWidgets);
      },
    );

    testWidgets(
      'Validación de contraseñas discordantes y contraseña corta no llama a signUpRecruiter',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const RegisterRecruiterScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'Carlos Recruiter');
        await tester.enterText(fields.at(1), 'carlos@acme.com');
        await tester.enterText(fields.at(2), '1234567'); // menor a 8 caracteres
        await tester.enterText(fields.at(3), 'diferentePassword');
        await tester.enterText(fields.at(4), 'Acme Inc');
        await tester.enterText(fields.at(5), 'Descripción válida');
        await tester.enterText(fields.at(6), 'AI');
        await tester.pump();

        final submitBtn = find.text('Crear cuenta');
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pump();

        expect(
          find.text('La contraseña debe tener al menos 8 caracteres'),
          findsOneWidget,
        );
        expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
        expect(fakeAuth.signUpRecruiterCalled, isFalse);
      },
    );

    testWidgets(
      'Formulario completo y válido llama a signUpRecruiter con los datos correctos',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthProvider();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>.value(
              value: fakeAuth,
              child: const RegisterRecruiterScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'Carlos Reclutador');
        await tester.enterText(fields.at(1), 'carlos@techcorp.com');
        await tester.enterText(fields.at(2), 'PasswordSegura2026!');
        await tester.enterText(fields.at(3), 'PasswordSegura2026!');
        await tester.enterText(fields.at(4), 'Tech Corp');
        await tester.enterText(fields.at(5), 'Líder en innovación tecnológica');
        await tester.enterText(fields.at(6), 'tc');
        await tester.pump();

        final submitBtn = find.text('Crear cuenta');
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pump();

        // Se llamó a signUpRecruiter
        expect(fakeAuth.signUpRecruiterCalled, isTrue);
        expect(fakeAuth.signUpRecruiterCallCount, 1);
        expect(fakeAuth.lastSignUpRecruiterArgs?['nombre'], 'Carlos Reclutador');
        expect(fakeAuth.lastSignUpRecruiterArgs?['email'], 'carlos@techcorp.com');
        expect(
          fakeAuth.lastSignUpRecruiterArgs?['password'],
          'PasswordSegura2026!',
        );
        expect(fakeAuth.lastSignUpRecruiterArgs?['empresaNombre'], 'Tech Corp');
        expect(
          fakeAuth.lastSignUpRecruiterArgs?['empresaDescripcion'],
          'Líder en innovación tecnológica',
        );
        expect(fakeAuth.lastSignUpRecruiterArgs?['empresaMonograma'], 'TC');
      },
    );
  });
}
