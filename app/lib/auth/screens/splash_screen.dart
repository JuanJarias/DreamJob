import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../state/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthProvider? _auth;
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    if (_auth != auth) {
      _auth?.removeListener(_onAuthChanged);
      _auth = auth;
      _auth!.addListener(_onAuthChanged);
    }
    _checkSessionAndNavigate();
  }

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    _checkSessionAndNavigate();
  }

  void _checkSessionAndNavigate() {
    if (_navigated || _auth == null || _auth!.loading) {
      return;
    }
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetRoute = _auth!.isAuthenticated ? '/home' : '/login';
      Navigator.pushReplacementNamed(context, targetRoute);
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
