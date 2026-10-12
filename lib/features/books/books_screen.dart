import 'package:flutter/material.dart';
import '../../core/widgets.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});
  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  static const _boards = ['Sindh Textbook Board', 'Punjab Textbook Board', 'Federal Board', 'Other boards'];
  static final _classes = List.generate(12, (i) => 'Class ${i + 1}');
  static const _subjects = ['Biology', 'Chemistry', 'Physics', 'English', 'Mathematics', 'Computer Science', 'Other'];
  String? _board, _class, _subject;

  Widget _group(String title, List<String> opts, String? sel, ValueChanged<String> on) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final o in opts) ChoiceChip(label: Text(o), selected: o == sel, onSelected: (_) => on(o)),
      ]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final picked = [_board, _class, _subject].whereType<String>().join(', ');
    return Scaffold(
      appBar: AppBar(title: const Text('Books')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
        const TextField(
          enabled: false,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Search books (coming soon)',
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          ),
        ),
        _group('Board', _boards, _board, (v) => setState(() => _board = v)),
        _group('Class', _classes, _class, (v) => setState(() => _class = v)),
        _group('Subject', _subjects, _subject, (v) => setState(() => _subject = v)),
        const SectionHeader('Books'),
        PressableCard(
          child: Column(children: [
            if (picked.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('Selected: $picked', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(
              height: 170,
              child: EmptyState(
                icon: Icons.menu_book_rounded,
                title: 'No books available yet',
                message: 'The book library is built in a later step. Your selection above will filter it then.',
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
