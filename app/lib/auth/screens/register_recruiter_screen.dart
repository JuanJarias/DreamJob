import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterRecruiterScreen extends StatelessWidget {
  const RegisterRecruiterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/register'),
        ),
        title: const Text('RegisterRecruiterScreen'),
      ),
      body: const Center(
        child: Text('RegisterRecruiterScreen (Placeholder)'),
      ),
    );
  }
}
