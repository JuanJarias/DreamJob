import 'package:dreamjob/auth/state/auth_provider.dart';
import 'package:dreamjob/main.dart';
import 'package:dreamjob/profile/profile_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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

  testWidgets(
    'RegisterRecruiterScreen muestra secciones, valida campos vacíos y botón volver',
    (WidgetTester tester) async {
      final auth = AuthProvider();
      await tester.pumpWidget(
        DreamJobApp(authProvider: auth, initialLocation: '/register/reclutador'),
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

      expect(find.text('Este campo es obligatorio'), findsNWidgets(5));
      expect(find.text('El correo electrónico es obligatorio'), findsOneWidget);
      expect(find.text('La contraseña es obligatoria'), findsOneWidget);

      // Probar botón volver a /register
      final backBtn = find.byIcon(Icons.arrow_back);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.text('¿Cómo quieres usar DreamJob?'), findsOneWidget);
    },
  );

  testWidgets(
    'RegisterRecruiterScreen valida formato de email, contraseñas y monograma con vista previa',
    (WidgetTester tester) async {
      final auth = AuthProvider();
      await tester.pumpWidget(
        DreamJobApp(authProvider: auth, initialLocation: '/register/reclutador'),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      // 0: Nombre, 1: Correo, 2: Password, 3: ConfirmPassword, 4: Empresa, 5: Descripción, 6: Monograma
      await tester.enterText(fields.at(0), 'Carlos Reclutador');
      await tester.enterText(fields.at(1), 'correo-invalido');
      await tester.enterText(fields.at(2), '1234567');
      await tester.enterText(fields.at(3), 'otra-contraseña');
      await tester.enterText(fields.at(4), 'Acme Corp');
      await tester.enterText(fields.at(5), 'Empresa de tecnología');
      await tester.enterText(fields.at(6), 'acm');
      await tester.pump();

      // Verificar que el monograma se convirtió a mayúsculas automáticamente
      expect(find.text('ACM'), findsWidgets);
      expect(find.text('Monograma: ACM'), findsOneWidget);
      expect(find.text('Acme Corp'), findsWidgets);

      final submitBtn = find.text('Crear cuenta');
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
    'RegisterRecruiterScreen valida que las contraseñas coincidan',
    (WidgetTester tester) async {
      final auth = AuthProvider();
      await tester.pumpWidget(
        DreamJobApp(authProvider: auth, initialLocation: '/register/reclutador'),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Carlos Reclutador');
      await tester.enterText(fields.at(1), 'carlos@acme.com');
      await tester.enterText(fields.at(2), 'Password123!');
      await tester.enterText(fields.at(3), 'PasswordDistinta!');
      await tester.enterText(fields.at(4), 'Acme Corp');
      await tester.enterText(fields.at(5), 'Empresa de tecnología');
      await tester.enterText(fields.at(6), 'ACM');
      await tester.pump();

      final submitBtn = find.text('Crear cuenta');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    },
  );

  testWidgets(
    'Registrar reclutador exitoso redirige automáticamente a /profile y maneja duplicado',
    (WidgetTester tester) async {
      final auth = AuthProvider();
      await tester.pumpWidget(
        DreamJobApp(authProvider: auth, initialLocation: '/register/reclutador'),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Carlos Reclutador');
      await tester.enterText(fields.at(1), 'carlos@acme.com');
      await tester.enterText(fields.at(2), 'Password123!');
      await tester.enterText(fields.at(3), 'Password123!');
      await tester.enterText(fields.at(4), 'Acme Corp');
      await tester.enterText(fields.at(5), 'Empresa de software y analítica');
      await tester.enterText(fields.at(6), 'ACM');
      await tester.pump();

      final submitBtn = find.text('Crear cuenta');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Redirigido a /profile automáticamente
      expect(find.text('Carlos Reclutador'), findsOneWidget);
      expect(find.text('carlos@acme.com'), findsOneWidget);

      // Ahora cerrar sesión e intentar registrar reclutador con el mismo correo
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      // Volvemos a /login, vamos a /register/reclutador
      final createAccountBtn = find.text('¿No tienes cuenta? Crear cuenta');
      await tester.ensureVisible(createAccountBtn);
      await tester.tap(createAccountBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Soy reclutador'));
      await tester.pumpAndSettle();

      final fields2 = find.byType(TextFormField);
      await tester.enterText(fields2.at(0), 'Carlos Reclutador 2');
      await tester.enterText(fields2.at(1), 'carlos@acme.com');
      await tester.enterText(fields2.at(2), 'Password123!');
      await tester.enterText(fields2.at(3), 'Password123!');
      await tester.enterText(fields2.at(4), 'Otra Corp');
      await tester.enterText(fields2.at(5), 'Otra descripción');
      await tester.enterText(fields2.at(6), 'OTC');
      await tester.pump();

      final submitBtn2 = find.text('Crear cuenta');
      await tester.ensureVisible(submitBtn2);
      await tester.tap(submitBtn2);
      await tester.pumpAndSettle();

      // Manejo de error AuthProvider.error
      expect(
        find.text('Este correo electrónico ya está registrado'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'ProfileSummaryScreen muestra CircularProgressIndicator cuando role es null',
    (WidgetTester tester) async {
      final auth = AuthProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: const MaterialApp(
            home: ProfileSummaryScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'ProfileSummaryScreen para candidato muestra avatar, datos, edad calculada y resumen',
    (WidgetTester tester) async {
      final auth = AuthProvider();
      final future = auth.signUpCandidate(
        nombre: 'Valentina Rodríguez',
        email: 'valentina@correo.com',
        password: 'Password123!',
        ciudad: 'Cali',
        fechaNacimiento: DateTime(2000, 5, 15),
        resumenPerfil: 'Desarrolladora apasionada por Flutter y UX',
      );
      await tester.pump(const Duration(milliseconds: 300));
      await future;

      await tester.pumpWidget(
        DreamJobApp(authProvider: auth, initialLocation: '/profile'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mi perfil'), findsOneWidget);
      expect(find.text('VR'), findsOneWidget);
      expect(find.text('Valentina Rodríguez'), findsOneWidget);
      expect(find.text('valentina@correo.com'), findsOneWidget);
      expect(find.text('Candidato'), findsOneWidget);
      expect(find.text('Cali'), findsOneWidget);
      expect(find.textContaining('2000-05-15'), findsOneWidget);
      expect(find.textContaining('años'), findsOneWidget);
      expect(
        find.text('Desarrolladora apasionada por Flutter y UX'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'ProfileSummaryScreen para candidato sin resumen muestra "Sin resumen"',
    (WidgetTester tester) async {
      final auth = AuthProvider();
      final future = auth.signUpCandidate(
        nombre: 'Pedro Pérez',
        email: 'pedro@correo.com',
        password: 'Password123!',
        ciudad: 'Bogotá',
        fechaNacimiento: DateTime(1998, 1, 10),
        resumenPerfil: null,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await future;

      await tester.pumpWidget(
        DreamJobApp(authProvider: auth, initialLocation: '/profile'),
      );
      await tester.pumpAndSettle();

      expect(find.text('PP'), findsOneWidget);
      expect(find.text('Pedro Pérez'), findsOneWidget);
      expect(find.text('Sin resumen'), findsOneWidget);
    },
  );

  testWidgets(
    'ProfileSummaryScreen para reclutador muestra avatar, datos y tarjeta de empresa con monograma',
    (WidgetTester tester) async {
      final auth = AuthProvider();
      final future = auth.signUpRecruiter(
        nombre: 'Carlos Reclutador',
        email: 'carlos@empresa.com',
        password: 'Password123!',
        empresaNombre: 'Tech Corp',
        empresaDescripcion: 'Empresa líder en desarrollo de software',
        empresaMonograma: 'TC',
      );
      await tester.pump(const Duration(milliseconds: 300));
      await future;

      await tester.pumpWidget(
        DreamJobApp(authProvider: auth, initialLocation: '/profile'),
      );
      await tester.pumpAndSettle();

      expect(find.text('CR'), findsOneWidget);
      expect(find.text('Carlos Reclutador'), findsOneWidget);
      expect(find.text('carlos@empresa.com'), findsOneWidget);
      expect(find.text('Reclutador'), findsOneWidget);
      expect(find.text('Tech Corp'), findsWidgets);
      expect(
        find.text('Empresa líder en desarrollo de software'),
        findsOneWidget,
      );
      expect(find.text('TC'), findsWidgets);
      expect(find.text('Monograma: TC'), findsOneWidget);

      // Probar cerrar sesión
      final logoutBtn = find.text('Cerrar sesión');
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Vuelve automáticamente a /login
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(auth.isAuthenticated, isFalse);
    },
  );
}
