import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class RegisterRoleScreen extends StatelessWidget {
  const RegisterRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrostedTop(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(
            child: CircleBack(onTap: () => context.go('/login')),
          ),
        ),
        title: const Text(
          'Crear cuenta',
          style: TextStyle(
            color: DjColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿Cómo quieres usar DreamJob?',
                style: TextStyle(
                  color: DjColors.ink,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Elige tu perfil para configurar tu cuenta.',
                style: TextStyle(
                  color: DjColors.muted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              _RoleOptionCard(
                title: 'Soy candidato',
                description:
                    'Busco prácticas profesionales o vacantes que encajen con mi perfil.',
                icon: Icons.person_outline,
                onTap: () => context.go('/register/candidato'),
              ),
              const SizedBox(height: 16),
              _RoleOptionCard(
                title: 'Soy reclutador',
                description:
                    'Represento a una empresa y busco conectar con talento compatible.',
                icon: Icons.business_outlined,
                onTap: () => context.go('/register/reclutador'),
              ),
              const Spacer(),
              SecondaryPill(
                label: 'Volver a iniciar sesión',
                onTap: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: DjCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: DjColors.tint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: DjColors.navy, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: DjColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: DjColors.muted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: DjColors.muted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
