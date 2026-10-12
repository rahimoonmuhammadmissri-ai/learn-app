import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'book_detail_screen.dart';
import 'book_widgets.dart';
import 'books_data.dart';
import 'books_store.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});
  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _store = BooksStore.instance;
  final _q = TextEditingController();
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    if (!_store.ready) _store.init();
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Widget _chips(String label, List<String> labels, int sel, ValueChanged<int> on) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(labels[i]), selected: i == sel, onSelected: (_) => on(i)),
            ),
        ]),
      ),
    ]);
  }

  Widget _header(BuildContext context, int count) {
    final cs = Theme.of(context).colorScheme;
    final lib = _tab == 0;
    final subs = _store.classNo == null ? allSubjects : subjectsForClass(_store.classNo!);
    final active = _q.text.isNotEmpty || (lib && _store.hasFilters);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SegmentedButton<int>(
        segments: [
          const ButtonSegment(value: 0, label: Text('Library'), icon: Icon(Icons.library_books_rounded)),
          ButtonSegment(value: 1, label: Text('Downloaded (${_store.downloaded.length})'), icon: const Icon(Icons.download_done_rounded)),
        ],
        selected: {_tab},
        onSelectionChanged: (s) => setState(() => _tab = s.first),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _q,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          hintText: 'Search book, subject, class or board',
          suffixIcon: _q.text.isEmpty
              ? null
              : IconButton(tooltip: 'Clear search', icon: const Icon(Icons.close_rounded), onPressed: () => setState(_q.clear)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      if (_store.initError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('Saved filters and downloads are unavailable: ${_store.initError}', style: TextStyle(color: cs.error)),
        ),
      if (lib) ...[
        _chips('Board', ['All', for (final b in boards) b.short], _store.board == null ? 0 : 1 + boards.indexWhere((b) => b.id == _store.board),
            (i) => _store.setBoard(i == 0 ? null : boards[i - 1].id)),
        _chips('Class', ['All', for (var c = 1; c <= 12; c++) 'Class $c'], _store.classNo ?? 0, (i) => _store.setClass(i == 0 ? null : i)),
        _chips('Subject', ['All', ...subs], _store.subject == null ? 0 : 1 + subs.indexOf(_store.subject!),
            (i) => _store.setSubject(i == 0 ? null : subs[i - 1])),
        const SizedBox(height: 12),
        Text(
          'Books can be downloaded only when a verified official PDF source has been added.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
      Row(children: [
        Expanded(child: Text('$count ${count == 1 ? 'book' : 'books'}', style: Theme.of(context).textTheme.labelLarge)),
        if (active)
          TextButton(
            onPressed: () => setState(() {
              _q.clear();
              _store.clearFilters();
            }),
            child: const Text('Clear all'),
          ),
      ]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Books')),
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          if (!_store.ready) return const Center(child: CircularProgressIndicator());
          final lib = _tab == 0;
          final items = _store.filter(_q.text, library: lib);
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: items.isEmpty ? 2 : items.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) return _header(context, items.length);
              if (items.isEmpty) {
                return lib
                    ? const EmptyState(icon: Icons.search_off_rounded, title: 'No books found', message: 'Try a different search or clear the filters.')
                    : const EmptyState(
                        icon: Icons.cloud_download_outlined,
                        title: 'Nothing downloaded yet',
                        message: 'Books with a verified source can be downloaded from their details page.');
              }
              final b = items[i - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BookCard(
                  book: b,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BookDetailScreen(book: b))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
