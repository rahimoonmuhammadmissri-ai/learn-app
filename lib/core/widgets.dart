import 'package:flutter/material.dart';
import 'theme.dart';

class PressableCard extends StatefulWidget {
  const PressableCard({super.key, required this.child, this.onTap, this.gradient});
  final Widget child;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _down = false;
  void _set(bool v) => setState(() => _down = v);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = BorderRadius.circular(20);
    return AnimatedScale(
      scale: _down ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: widget.gradient == null ? cs.surface : null,
            gradient: widget.gradient,
            borderRadius: r,
            border: Border.all(color: cs.outlineVariant),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: InkWell(
            borderRadius: r,
            onTap: widget.onTap,
            onTapDown: (_) => _set(true),
            onTapUp: (_) => _set(false),
            onTapCancel: () => _set(false),
            child: Padding(padding: const EdgeInsets.all(Sp.m), child: widget.child),
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: Sp.l, bottom: Sp.s),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        if (subtitle != null) Text(subtitle!, style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ]),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, this.color, {super.key});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color.withValues(alpha: .15), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: color),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sp.l),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 48, color: cs.primary.withValues(alpha: .7)),
          const SizedBox(height: Sp.m),
          Text(title, textAlign: TextAlign.center, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: Sp.s),
          Text(message, textAlign: TextAlign.center, style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.icon, required this.message});
  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: EmptyState(icon: icon, title: 'Not available yet', message: message),
      );
}

void openSoon(BuildContext context, String title, IconData icon, String message) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => ComingSoonScreen(title: title, icon: icon, message: message),
  ));
}
