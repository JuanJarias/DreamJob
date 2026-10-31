import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class OwlBadge extends StatelessWidget {
  final double size;
  const OwlBadge({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.30),
        color: DjColors.navy,
        boxShadow: [
          BoxShadow(
            color: DjColors.navy.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.62,
          height: size * 0.52,
          child: CustomPaint(painter: _OwlPainter()),
        ),
      ),
    );
  }
}

class _OwlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white;
    final navy = Paint()..color = DjColors.navy;
    final eyeR = size.width * 0.24;
    final leftC = Offset(size.width * 0.26, size.height * 0.44);
    final rightC = Offset(size.width * 0.74, size.height * 0.44);
    canvas.drawCircle(leftC, eyeR, white);
    canvas.drawCircle(rightC, eyeR, white);
    canvas.drawCircle(leftC, eyeR * 0.48, navy);
    canvas.drawCircle(rightC, eyeR * 0.48, navy);
    canvas.drawCircle(
      leftC + Offset(eyeR * 0.18, -eyeR * 0.18),
      eyeR * 0.14,
      white,
    );
    canvas.drawCircle(
      rightC + Offset(eyeR * 0.18, -eyeR * 0.18),
      eyeR * 0.14,
      white,
    );
    final frame = Paint()
      ..color = DjColors.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07;
    canvas.drawCircle(leftC, eyeR * 1.08, frame);
    canvas.drawCircle(rightC, eyeR * 1.08, frame);
    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.40),
      Offset(size.width * 0.52, size.height * 0.40),
      frame,
    );
    final beak = Path()
      ..moveTo(size.width * 0.44, size.height * 0.72)
      ..lineTo(size.width * 0.56, size.height * 0.72)
      ..lineTo(size.width * 0.50, size.height * 0.84)
      ..close();
    canvas.drawPath(beak, Paint()..color = DjColors.skySoft);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FrostedTop extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  const FrostedTop({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            border: const Border(bottom: BorderSide(color: DjColors.line)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 52,
            leadingWidth: 40,
            titleSpacing: 4,
            leading: leading,
            title: title,
            actions: actions,
          ),
        ),
      ),
    );
  }
}

class CircleBack extends StatelessWidget {
  final VoidCallback? onTap;
  const CircleBack({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.maybePop(context),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: DjColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back, color: DjColors.ink, size: 16),
      ),
    );
  }
}

class PrimaryPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  const PrimaryPill({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: DjColors.navy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DjColors.navy.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class SecondaryPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const SecondaryPill({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: DjColors.navy,
          side: const BorderSide(color: DjColors.line, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class WashField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData? prefix;
  const WashField({
    super.key,
    this.controller,
    required this.hint,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: DjColors.ink, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: DjColors.muted),
        prefixIcon: prefix == null ? null : Icon(prefix, color: DjColors.muted),
        filled: true,
        fillColor: DjColors.wash,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class DjCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const DjCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DjColors.line),
        boxShadow: [
          BoxShadow(
            color: DjColors.navy.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  const StatusPill({
    super.key,
    required this.label,
    required this.fg,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class SectionHead extends StatelessWidget {
  final String title;
  final String? sub;
  const SectionHead({super.key, required this.title, this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: DjColors.ink,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        if (sub != null) ...[
          const SizedBox(height: 4),
          Text(
            sub!,
            style: const TextStyle(
              color: DjColors.muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class CompanyMark extends StatelessWidget {
  final String company;
  final String mono;
  final double size;
  const CompanyMark({
    super.key,
    required this.company,
    required this.mono,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final displayMono = mono.trim().isEmpty ? '?' : mono.trim().toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: DjColors.tint,
        borderRadius: BorderRadius.circular(size * 0.27),
        border: Border.all(color: DjColors.line),
      ),
      child: Center(
        child: Text(
          displayMono,
          style: TextStyle(
            color: DjColors.navy,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
