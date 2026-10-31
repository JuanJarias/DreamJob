import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/register_candidate_screen.dart';
import '../auth/screens/register_recruiter_screen.dart';
import '../auth/screens/register_role_screen.dart';
import '../auth/state/auth_provider.dart';
import '../profile/profile_summary_screen.dart';
import '../theme.dart';
import '../widgets/common.dart';

GoRouter createAppRouter(
  AuthProvider authProvider, {
  String initialLocation = '/splash',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: authProvider,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final loc = state.matchedLocation;

      if (loc == '/splash') {
        return null;
      }

      final isAuthRoute = loc == '/login' || loc.startsWith('/register');
      if (isLoggedIn && isAuthRoute) {
        return '/profile';
      }
      if (!isLoggedIn && loc == '/profile') {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(authProvider: authProvider),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterRoleScreen(),
      ),
      GoRoute(
        path: '/register/candidato',
        builder: (context, state) => const RegisterCandidateScreen(),
      ),
      GoRoute(
        path: '/register/reclutador',
        builder: (context, state) => const RegisterRecruiterScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileSummaryScreen(),
      ),
    ],
  );
}

class SplashScreen extends StatefulWidget {
  final AuthProvider authProvider;
  const SplashScreen({super.key, required this.authProvider});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = widget.authProvider.isAuthenticated ? '/profile' : '/login';
      context.go(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OwlBadge(size: 92),
            SizedBox(height: 20),
            Text(
              'dreamJob',
              style: TextStyle(
                color: DjColors.ink,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'DESLIZA  •  CONECTA  •  CONTRATADO',
              style: TextStyle(
                color: DjColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
