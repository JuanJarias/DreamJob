import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Login y selector de rol navegan correctamente y validan campos vacíos',
    (WidgetTester tester) async {
      final auth = AuthProvider();
      await tester.pumpWidget(
        DreamJobApp(authProvider: auth, initialLocation: '/login'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Te damos la bienvenida a DreamJob'), findsOneWidget);

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(find.text('El correo electrónico es obligatorio'), findsOneWidget);
      expect(find.text('Este campo es obligatorio'), findsOneWidget);

      final createAccountBtn = find.text('¿No tienes cuenta? Crear cuenta');
      await tester.ensureVisible(createAccountBtn);
      await tester.tap(createAccountBtn);
      await tester.pumpAndSettle();

      expect(find.text('¿Cómo quieres usar DreamJob?'), findsOneWidget);
      expect(find.text('Soy candidato'), findsOneWidget);
      expect(find.text('Soy reclutador'), findsOneWidget);
    },
  );

  testWidgets(
    'RegisterCandidateScreen valida campos vacíos, email inválido y contraseña corta',
    (WidgetTester tester) async {
      final auth = AuthProvider();
      await tester.pumpWidget(
        DreamJobApp(authProvider: auth, initialLocation: '/register/candidato'),
      );
      await tester.pumpAndSettle();

      final submitBtn = find.text('Crear cuenta');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('Este campo es obligatorio'), findsNWidgets(3));
      expect(find.text('El correo electrónico es obligatorio'), findsOneWidget);
      expect(find.text('La contraseña es obligatoria'), findsOneWidget);
      expect(find.text('La fecha de nacimiento es obligatoria'), findsOneWidget);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), 'correo-invalido');
      await tester.enterText(fields.at(2), '1234567');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('Ingresa un correo electrónico válido'), findsOneWidget);
      expect(
        find.text('La contraseña debe tener al menos 8 caracteres'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Registrar candidato exitoso redirige automáticamente a /profile',
    (WidgetTester tester) async {
      final auth = AuthProvider();
      await tester.pumpWidget(
        DreamJobApp(authProvider: auth, initialLocation: '/register/candidato'),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Valentina Rodríguez');
      await tester.enterText(fields.at(1), 'valentina@icesi.edu.co');
      await tester.enterText(fields.at(2), 'DreamJob2026!');
      await tester.enterText(fields.at(3), 'DreamJob2026!');
      await tester.enterText(fields.at(4), 'Cali');

      await tester.ensureVisible(fields.at(5));
      await tester.tap(fields.at(5));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      final submitBtn = find.text('Crear cuenta');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Valentina Rodríguez'), findsOneWidget);
      expect(find.text('valentina@icesi.edu.co'), findsOneWidget);
    },
  );
}
