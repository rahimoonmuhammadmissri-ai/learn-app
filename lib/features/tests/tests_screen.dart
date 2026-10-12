import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final modes = [
      (Icons.edit_rounded, 'Practice test', 'Untimed questions by topic.', AppColors.violet),
      (Icons.timer_rounded, 'Timed mock exam', 'Exam practice with a countdown.', AppColors.amber),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Tests')),
      body: ListView(padding: const EdgeInsets.fromLTRB(Sp.m, 0, Sp.m, Sp.l), children: [
        for (final m in modes)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PressableCard(
              onTap: () => openSoon(context, m.$2, m.$1, 'Tests are planned for a later step.'),
              child: Row(children: [
                IconBadge(m.$1, m.$4),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.$2, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text(m.$3, style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ]),
                ),
              ]),
            ),
          ),
        const SectionHeader('Results'),
        const PressableCard(
          child: SizedBox(
            height: 180,
            child: EmptyState(
              icon: Icons.bar_chart_rounded,
              title: 'No results yet',
              message: 'Scores and weak topics will appear here after you take a test.',
            ),
          ),
        ),
      ]),
    );
  }
}
