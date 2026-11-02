import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/data/models.dart';
import '../auth/state/auth_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileSummaryScreen extends StatelessWidget {
  const ProfileSummaryScreen({super.key});

  String _getInitials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: DjColors.muted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: DjColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: DjColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateView(BuildContext context, CandidateProfile candidate) {
    final age = _calculateAge(candidate.fechaNacimiento);
    final formattedDate = _formatDate(candidate.fechaNacimiento);
    final birthDateWithAge = '$formattedDate ($age años)';
    final resumen =
        (candidate.resumenPerfil == null ||
                candidate.resumenPerfil!.trim().isEmpty)
            ? 'Sin resumen'
            : candidate.resumenPerfil!.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: DjColors.navy,
                child: Text(
                  _getInitials(candidate.nombre),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                candidate.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DjColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                candidate.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DjColors.muted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              const StatusPill(
                label: 'Candidato',
                fg: DjColors.sky,
                bg: DjColors.tint,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DjCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Ciudad',
                value: candidate.ciudad,
              ),
              const SizedBox(height: 16),
              const Divider(color: DjColors.line, height: 1),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.cake_outlined,
                label: 'Fecha de nacimiento',
                value: birthDateWithAge,
              ),
              const SizedBox(height: 16),
              const Divider(color: DjColors.line, height: 1),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.description_outlined,
                label: 'Resumen de perfil',
                value: resumen,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecruiterView(BuildContext context, RecruiterProfile recruiter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: DjColors.navy,
                child: Text(
                  _getInitials(recruiter.nombre),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                recruiter.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DjColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                recruiter.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DjColors.muted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              const StatusPill(
                label: 'Reclutador',
                fg: DjColors.blue,
                bg: DjColors.tint,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DjCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CompanyMark(
                    company: recruiter.empresa.nombre,
                    mono: recruiter.empresa.monograma,
                    size: 56,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Empresa',
                          style: TextStyle(
                            color: DjColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          recruiter.empresa.nombre,
                          style: const TextStyle(
                            color: DjColors.ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Monograma: ${recruiter.empresa.monograma}',
                          style: const TextStyle(
                            color: DjColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: DjColors.line, height: 1),
              const SizedBox(height: 14),
              const Text(
                'Descripción',
                style: TextStyle(
                  color: DjColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recruiter.empresa.descripcion,
                style: const TextStyle(
                  color: DjColors.ink,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.loading ||
        auth.role == null ||
        (auth.role == UserRole.candidato && auth.candidate == null) ||
        (auth.role == UserRole.reclutador && auth.recruiter == null)) {
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrostedTop(
        title: const Text(
          'Mi perfil',
          style: TextStyle(
            color: DjColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: DjColors.muted, size: 20),
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isCandidato)
                _buildCandidateView(context, auth.candidate!)
              else
                _buildRecruiterView(context, auth.recruiter!),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => context.read<AuthProvider>().signOut(),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DjColors.errorInk,
                    side: const BorderSide(color: DjColors.errorLine),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
