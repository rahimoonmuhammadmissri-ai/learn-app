import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'books_data.dart';
import 'books_store.dart';

const _palette = [AppColors.violet, AppColors.teal, AppColors.amber, AppColors.pink, Color(0xFF3B82F6)];

Color subjectColor(String s) => _palette[s.codeUnits.fold(0, (a, b) => a + b) % _palette.length];

IconData subjectIcon(String s) => switch (s) {
      'Biology' => Icons.eco_rounded,
      'Chemistry' || 'General Science' => Icons.science_rounded,
      'Physics' => Icons.bolt_rounded,
      'Mathematics' => Icons.calculate_rounded,
      'English' || 'Urdu' => Icons.translate_rounded,
      'Computer Science' => Icons.computer_rounded,
      'Social Studies' => Icons.public_rounded,
      'Pakistan Studies' => Icons.flag_rounded,
      _ => Icons.auto_stories_rounded,
    };

/// Generated cover (no real cover images).
class BookCover extends StatelessWidget {
  const BookCover(this.book, {super.key, this.size = 56});
  final Book book;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = subjectColor(book.subject);
    return Container(
      width: size,
      height: size * 1.3,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .18),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c, AppColors.navy]),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(subjectIcon(book.subject), color: Colors.white, size: size * .4),
        const SizedBox(height: 4),
        FittedBox(child: Text(book.classLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.book, {super.key});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final s = BooksStore.instance;
    final p = s.progress[book.id];
    final (String, Color, IconData) v = switch (s.statusOf(book)) {
      BookStatus.downloaded => ('Downloaded', AppColors.teal, Icons.download_done_rounded),
      BookStatus.downloading => (p == null || p < 0 ? 'Downloading' : 'Downloading ${(p * 100).round()}%', AppColors.violet, Icons.downloading_rounded),
      BookStatus.failed => ('Download failed', const Color(0xFFE5484D), Icons.error_outline_rounded),
      BookStatus.unavailable => ('Unavailable', Colors.grey, Icons.block_rounded),
      BookStatus.download => ('Download', AppColors.violet, Icons.cloud_download_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: v.$2.withValues(alpha: .16), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(v.$3, size: 14, color: v.$2),
        const SizedBox(width: 4),
        Flexible(child: Text(v.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface))),
      ]),
    );
  }
}

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book, required this.onTap});
  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return PressableCard(
      onTap: onTap,
      child: Row(children: [
        BookCover(book),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(book.title, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text('${boardById(book.board).short}, ${book.classLabel}, ${book.subject}', style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            Text('${book.medium} medium, ${book.edition}', style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            StatusChip(book),
          ]),
        ),
      ]),
    );
  }
}
