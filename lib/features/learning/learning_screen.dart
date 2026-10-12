import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final rows = [
      (Icons.bookmark_rounded, 'Bookmarks', AppColors.violet),
      (Icons.download_done_rounded, 'Downloaded books', AppColors.teal),
      (Icons.checklist_rounded, 'Saved MCQs', AppColors.amber),
      (Icons.edit_note_rounded, 'Saved notes', AppColors.pink),
      (Icons.error_outline_rounded, 'Wrong answers', AppColors.violet),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('My Learning')),
      body: ListView(padding: const EdgeInsets.fromLTRB(Sp.m, 0, Sp.m, Sp.l), children: [
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PressableCard(
              onTap: () => openSoon(context, r.$2, r.$1, 'This section works once the related feature is built.'),
              child: Row(children: [
                IconBadge(r.$1, r.$3),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.$2, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text('Nothing saved yet', style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
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
