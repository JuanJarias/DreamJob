import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/data/models.dart';
import '../auth/state/auth_provider.dart';
import '../profile/profile_summary_screen.dart';
import '../theme.dart';
import '../vacancies/screens/candidate_liked_jobs_screen.dart';
import '../vacancies/screens/deck_screen.dart';
import '../vacancies/screens/recruiter_vacancies_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  bool _redirectingToLogin = false;

  void _redirectIfUnauthenticated(AuthProvider auth) {
    if (_redirectingToLogin || auth.loading || auth.isAuthenticated) {
      return;
    }
    _redirectingToLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(DjColors.navy),
          ),
        ),
      );
    }

    if (!auth.isAuthenticated) {
      _redirectIfUnauthenticated(auth);
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(DjColors.navy),
          ),
        ),
      );
    }

    final isCandidato = auth.role == UserRole.candidato;
    final pages = isCandidato
        ? const <Widget>[
            DeckScreen(),
            CandidateLikedJobsScreen(),
            ProfileSummaryScreen(),
          ]
        : const <Widget>[
            RecruiterVacanciesScreen(),
            ProfileSummaryScreen(),
          ];

    final navItems = isCandidato
        ? const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.style_outlined),
              activeIcon: Icon(Icons.style),
              label: 'Deck',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work),
              label: 'Postulaciones',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ]
        : const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.business_center_outlined),
              activeIcon: Icon(Icons.business_center),
              label: 'Vacantes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ];

    final safeIndex = _currentIndex.clamp(0, pages.length - 1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: DjColors.line)),
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: DjColors.navy,
          unselectedItemColor: DjColors.muted,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          type: BottomNavigationBarType.fixed,
          items: navItems,
        ),
      ),
    );
  }
}
