import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/screens/login_screen.dart';
import 'auth/screens/register_candidate_screen.dart';
import 'auth/screens/register_recruiter_screen.dart';
import 'auth/screens/register_role_screen.dart';
import 'auth/screens/splash_screen.dart';
import 'auth/state/auth_provider.dart';
import 'home/home_shell.dart';
import 'profile/profile_summary_screen.dart';
import 'theme.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  runApp(const DreamJobApp());
}

class DreamJobApp extends StatefulWidget {
  final AuthProvider? authProvider;
  final String initialRoute;

  const DreamJobApp({
    super.key,
    this.authProvider,
    this.initialRoute = '/splash',
  });

  @override
  State<DreamJobApp> createState() => _DreamJobAppState();
}

class _DreamJobAppState extends State<DreamJobApp> {
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = widget.authProvider ?? AuthProvider();
  }

  @override
  void dispose() {
    if (widget.authProvider == null) {
      _authProvider.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = buildDreamJobTheme();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
      ],
      child: MaterialApp(
        title: 'DreamJob',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: theme,
        themeMode: ThemeMode.light,
        initialRoute: widget.initialRoute,
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterRoleScreen(),
          '/register/candidato': (context) => const RegisterCandidateScreen(),
          '/register/reclutador': (context) => const RegisterRecruiterScreen(),
          '/home': (context) => const HomeShell(),
          '/profile': (context) => const ProfileSummaryScreen(),
        },
      ),
    );
  }
}
