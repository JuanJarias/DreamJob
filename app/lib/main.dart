import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'auth/state/auth_provider.dart';
import 'router/app_router.dart';
import 'theme.dart';

void main() {
  runApp(const DreamJobApp());
}

class DreamJobApp extends StatefulWidget {
  final AuthProvider? authProvider;
  final String initialLocation;

  const DreamJobApp({
    super.key,
    this.authProvider,
    this.initialLocation = '/splash',
  });

  @override
  State<DreamJobApp> createState() => _DreamJobAppState();
}

class _DreamJobAppState extends State<DreamJobApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = widget.authProvider ?? AuthProvider();
    _router = createAppRouter(
      _authProvider,
      initialLocation: widget.initialLocation,
    );
  }

  @override
  void dispose() {
    _router.dispose();
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
      child: MaterialApp.router(
        title: 'DreamJob',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: theme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
