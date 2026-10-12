import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onGo});
  final void Function(int) onGo;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final items = [
      (Icons.menu_book_rounded, 'Books', 'Class 1-12 library', AppColors.violet, 1),
      (Icons.auto_awesome_rounded, 'AI Lab', 'MCQs and notes', AppColors.teal, 2),
      (Icons.quiz_rounded, 'Tests', 'Practice and mocks', AppColors.amber, 3),
      (Icons.school_rounded, 'My Learning', 'Saved material', AppColors.pink, 4),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(Sp.m, 0, Sp.m, Sp.l), children: [
        Container(
          padding: const EdgeInsets.all(Sp.l),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.navy, AppColors.violet]),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Welcome to Learn', style: t.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Your study space for books, practice and revision.', style: t.bodyMedium?.copyWith(color: Colors.white70)),
          ]),
        ),
        const SectionHeader('Quick start'),
        LayoutBuilder(builder: (context, box) {
          final w = (box.maxWidth - 12) / 2;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            for (final it in items)
              SizedBox(
                width: w,
                child: PressableCard(
                  onTap: () => onGo(it.$5),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    IconBadge(it.$1, it.$4),
                    const SizedBox(height: 12),
                    Text(it.$2, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text(it.$3, style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ]),
                ),
              ),
          ]);
        }),
        const SectionHeader('Recent activity'),
        PressableCard(
          child: const SizedBox(
            height: 180,
            child: EmptyState(
              icon: Icons.history_rounded,
              title: 'Nothing here yet',
              message: 'Your study activity will show up here once you start learning.',
            ),
          ),
        ),
      ]),
    );
  }
}
