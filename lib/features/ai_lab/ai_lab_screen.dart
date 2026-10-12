import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class AiLabScreen extends StatelessWidget {
  const AiLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final tools = [
      (Icons.checklist_rounded, 'AI MCQs', 'Make exam-style questions from a topic.', AppColors.violet, 'MCQs are planned for a later step.'),
      (Icons.edit_note_rounded, 'AI Notes', 'Get simple, detailed notes on any topic.', AppColors.teal, 'Notes are planned for a later step.'),
      (Icons.chat_bubble_outline_rounded, 'Ask AI', 'Ask questions about your study material.', AppColors.pink, 'Ask AI is planned for a later phase.'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('AI Lab')),
      body: ListView(padding: const EdgeInsets.fromLTRB(Sp.m, 0, Sp.m, Sp.l), children: [
        Text('AI tools will need internet and use free services with limits. We will ask before sending any text.',
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: Sp.m),
        for (final x in tools)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PressableCard(
              onTap: () => openSoon(context, x.$2, x.$1, x.$5),
              child: Row(children: [
                IconBadge(x.$1, x.$4),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(x.$2, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text(x.$3, style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ]),
            ),
          ),
      ]),
    );
  }
}
