import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/widgets.dart';
import 'book_widgets.dart';
import 'books_data.dart';
import 'books_store.dart';
import 'pdf_reader_screen.dart';

String _mb(int b) => (b / 1048576).toStringAsFixed(1);

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

  Widget _actions(BuildContext context, BooksStore store) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    switch (store.statusOf(book)) {
      case BookStatus.downloading:
        final p = store.progress[book.id] ?? -1;
        final got = store.received[book.id] ?? 0;
        final total = store.totalBytes[book.id] ?? 0;
        return Column(children: [
          LinearProgressIndicator(value: p < 0 ? null : p, minHeight: 8, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 8),
          Text(total > 0 ? '${_mb(got)} / ${_mb(total)} MB' : '${_mb(got)} MB'),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => store.cancel(book), child: const Text('Cancel')),
        ]);
      case BookStatus.downloaded:
        final path = store.pathFor(book);
        final size = path != null && File(path).existsSync() ? ' (${_mb(File(path).lengthSync())} MB)' : '';
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Saved on this phone$size. It opens without internet.', style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PdfReaderScreen(book: book))),
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Read'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: () => _confirmDelete(context), icon: const Icon(Icons.delete_outline_rounded), label: const Text('Delete download')),
        ]);
      case BookStatus.unavailable:
        return PressableCard(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.block_rounded, color: cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Text('Unavailable. No working download link was found on the official portal.', style: t.bodyMedium)),
          ]),
        );
      case BookStatus.failed:
      case BookStatus.download:
        final err = store.errors[book.id];
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (err != null)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('Download failed: $err', style: TextStyle(color: cs.error))),
          Text('Large file. Wi-Fi is recommended.', style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => store.download(book),
            icon: const Icon(Icons.download_rounded),
            label: Text(err == null ? 'Download PDF' : 'Try again'),
          ),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = BooksStore.instance;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
          Center(child: BookCover(book, size: 110)),
          const SizedBox(height: 16),
          Text(book.title, textAlign: TextAlign.center, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Center(child: StatusChip(book)),
          const SizedBox(height: 20),
          PressableCard(
            child: Column(children: [
              _row(context, 'Board', boardById(book.board).name),
              _row(context, 'Class', book.classLabel),
              _row(context, 'Subject', book.subject),
              _row(context, 'Medium', book.medium),
              _row(context, 'Edition', '${book.edition} (as listed by STBB)'),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(width: 90, child: Text('Source')),
                Expanded(child: SelectableText(book.pageUrl, style: t.bodySmall)),
                IconButton(
                  tooltip: 'Copy official page link',
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: book.pageUrl));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Official page link copied')));
                  },
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          _actions(context, store),
        ]),
      ),
    );
  }
}
