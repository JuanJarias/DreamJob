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
import 'profile/candidate_preferences_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/profile_summary_screen.dart';
import 'swipes/state/swipes_provider.dart';
import 'theme.dart';
import 'vacancies/data/models.dart';
import 'vacancies/screens/job_detail_screen.dart';
import 'vacancies/screens/vacancy_form_screen.dart';
import 'vacancies/state/vacancies_provider.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  runApp(const DreamJobApp());
}

class DreamJobApp extends StatefulWidget {
  final AuthProvider? authProvider;
  final VacanciesProvider? vacanciesProvider;
  final SwipesProvider? swipesProvider;
  final String initialRoute;

  const DreamJobApp({
    super.key,
    this.authProvider,
    this.vacanciesProvider,
    this.swipesProvider,
    this.initialRoute = '/splash',
  });

  @override
  State<DreamJobApp> createState() => _DreamJobAppState();
}

class _DreamJobAppState extends State<DreamJobApp> {
  late final AuthProvider _authProvider;
  late final VacanciesProvider _vacanciesProvider;
  late final SwipesProvider _swipesProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = widget.authProvider ?? AuthProvider();
    _vacanciesProvider = widget.vacanciesProvider ?? VacanciesProvider();
    _swipesProvider = widget.swipesProvider ?? SwipesProvider();
  }

  @override
  void dispose() {
    if (widget.authProvider == null) {
      _authProvider.dispose();
    }
    if (widget.vacanciesProvider == null) {
      _vacanciesProvider.dispose();
    }
    if (widget.swipesProvider == null) {
      _swipesProvider.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = buildDreamJobTheme();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<VacanciesProvider>.value(
          value: _vacanciesProvider,
        ),
        ChangeNotifierProvider<SwipesProvider>.value(value: _swipesProvider),
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
          '/profile/edit': (context) => const EditProfileScreen(),
          '/profile/preferences': (context) =>
              const CandidatePreferencesScreen(),
          '/vacancies/new': (context) => const VacancyFormScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/vacancies/edit') {
            final vacante = settings.arguments as Vacancy?;
            return MaterialPageRoute(
              builder: (context) => VacancyFormScreen(vacancy: vacante),
            );
          }
          if (settings.name == '/vacancies/detail') {
            final args = settings.arguments;
            if (args is JobDetailArguments) {
              return MaterialPageRoute(
                builder: (context) => JobDetailScreen(
                  vacancy: args.vacancy,
                  showActions: args.showActions,
                ),
              );
            }
            if (args is Vacancy) {
              return MaterialPageRoute(
                builder: (context) => JobDetailScreen(vacancy: args),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
