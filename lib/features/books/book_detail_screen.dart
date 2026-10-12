import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'book_widgets.dart';
import 'books_data.dart';
import 'books_store.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.book});
  final Book book;

  Widget _row(BuildContext context, String k, String v) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 90, child: Text(k, style: TextStyle(color: cs.onSurfaceVariant))),
        Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete download?'),
        content: const Text('The PDF will be removed from this phone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) await BooksStore.instance.delete(book);
  }

  @override
  Widget build(BuildContext context) {
    final store = BooksStore.instance;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(book.subject)),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final p = store.progress[book.id];
          final done = store.downloaded.contains(book.id);
          final err = store.errors[book.id];
          return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
            Center(child: BookCover(book, size: 110)),
            const SizedBox(height: 16),
            Text('${book.subject}, Class ${book.classNo}', textAlign: TextAlign.center, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Center(child: StatusChip(book)),
            const SizedBox(height: 20),
            PressableCard(
              child: Column(children: [
                _row(context, 'Board', boardById(book.board).name),
                _row(context, 'Class', 'Class ${book.classNo}'),
                _row(context, 'Subject', book.subject),
                _row(context, 'Language', book.language ?? 'Not verified'),
                _row(context, 'Source', book.sourceName ?? 'Not added yet'),
              ]),
            ),
            const SizedBox(height: 16),
            if (p != null) ...[
              LinearProgressIndicator(value: p < 0 ? null : p, minHeight: 8, borderRadius: BorderRadius.circular(8)),
              const SizedBox(height: 8),
              Text(p < 0 ? 'Downloading...' : '${(p * 100).round()}%', textAlign: TextAlign.center),
            ] else if (done) ...[
              Text('Saved on this phone. The PDF reader will be added in a later step.', style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),
              OutlinedButton.icon(onPressed: () => _confirmDelete(context), icon: const Icon(Icons.delete_outline_rounded), label: const Text('Delete download')),
            ] else if (book.hasSource) ...[
              if (err != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(err, style: TextStyle(color: cs.error))),
              FilledButton.icon(onPressed: () => store.download(book), icon: const Icon(Icons.download_rounded), label: const Text('Download PDF')),
            ] else
              PressableCard(
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Source not added yet. This entry lists the subject for browsing, but no verified official PDF link has been added, so nothing can be downloaded.',
                      style: t.bodyMedium,
                    ),
                  ),
                ]),
              ),
          ]);
        },
      ),
    );
  }
}
