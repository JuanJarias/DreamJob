import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/state/auth_provider.dart';

class ProfileSummaryScreen extends StatelessWidget {
  const ProfileSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final nombre =
        auth.candidate?.nombre ?? auth.recruiter?.nombre ?? 'Usuario';
    final email = auth.candidate?.email ?? auth.recruiter?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('ProfileSummaryScreen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ProfileSummaryScreen (Placeholder)'),
              const SizedBox(height: 8),
              Text(nombre),
              if (email.isNotEmpty) Text(email),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<AuthProvider>().signOut(),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
