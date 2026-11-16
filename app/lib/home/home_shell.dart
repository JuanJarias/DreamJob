import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/data/models.dart';
import '../auth/state/auth_provider.dart';
import '../profile/profile_summary_screen.dart';
import '../theme.dart';
import '../widgets/common.dart';

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
            _PlaceholderTab(
              appBarTitle: 'Explorar vacantes',
              heading: 'Deck de vacantes',
              description:
                  'Aquí explorarás las vacantes compatibles mediante tarjetas deslizables para postularte u omitir.',
              icon: Icons.style_outlined,
            ),
            _PlaceholderTab(
              appBarTitle: 'Mis postulaciones',
              heading: 'Vacantes de interés',
              description:
                  'Aquí verás el historial de vacantes a las que les diste swipe positivo.',
              icon: Icons.work_outline,
            ),
            ProfileSummaryScreen(),
          ]
        : <Widget>[
            _PlaceholderTab(
              appBarTitle: 'Mis vacantes',
              heading: 'Vacantes publicadas',
              description:
                  'Aquí podrás crear, editar y administrar las ofertas laborales de tu empresa.',
              icon: Icons.business_center_outlined,
              actionLabel: 'Publicar vacante',
              actionIcon: Icons.add_circle_outline,
              onAction: () => Navigator.pushNamed(context, '/vacancies/new'),
            ),
            const ProfileSummaryScreen(),
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

class _PlaceholderTab extends StatelessWidget {
  final String appBarTitle;
  final String heading;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const _PlaceholderTab({
    required this.appBarTitle,
    required this.heading,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrostedTop(
        title: Text(
          appBarTitle,
          style: const TextStyle(
            color: DjColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: onAction != null
            ? [
                IconButton(
                  icon: Icon(actionIcon ?? Icons.add, color: DjColors.navy),
                  tooltip: actionLabel ?? 'Acción',
                  onPressed: onAction,
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: DjCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: DjColors.tint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, color: DjColors.navy, size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    heading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: DjColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: DjColors.muted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (onAction != null && actionLabel != null) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: onAction,
                        icon: Icon(actionIcon ?? Icons.add, size: 18),
                        label: Text(actionLabel!),
                        style: FilledButton.styleFrom(
                          backgroundColor: DjColors.navy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
