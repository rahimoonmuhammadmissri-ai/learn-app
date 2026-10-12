class Board {
  const Board(this.id, this.name, this.short);
  final String id, name, short;
}

const boards = [
  Board('stbb', 'Sindh Textbook Board', 'STBB'),
  Board('punjab', 'Punjab Board', 'Punjab'),
  Board('federal', 'Federal Board', 'Federal'),
  Board('kpk', 'Khyber Pakhtunkhwa Board', 'KPK'),
  Board('balochistan', 'Balochistan Board', 'Balochistan'),
];

Board boardById(String id) => boards.firstWhere((b) => b.id == id);

class Book {
  const Book({
    required this.id,
    required this.board,
    required this.classNo,
    required this.subject,
    this.language,
    this.sourceUrl,
    this.sourceName,
  });
  final String id, board, subject;
  final int classNo;
  final String? language, sourceUrl, sourceName;
  bool get hasSource => sourceUrl != null;
}

/// Subjects offered per class. A general list, not a claim about any one board's exact books.
List<String> subjectsForClass(int c) {
  if (c <= 5) return ['English', 'Urdu', 'Mathematics', 'General Science', 'Islamiyat', 'Social Studies'];
  if (c <= 8) return ['English', 'Urdu', 'Mathematics', 'General Science', 'Computer Science', 'Islamiyat', 'Social Studies'];
  return ['Biology', 'Chemistry', 'Physics', 'Mathematics', 'English', 'Urdu', 'Computer Science', 'Islamiyat', 'Pakistan Studies'];
}

final allSubjects = <String>{for (var c = 1; c <= 12; c++) ...subjectsForClass(c)}.toList();

/// Verified official PDF sources. Key = book id, value = [direct PDF url, source name].
/// EMPTY ON PURPOSE: only add a link after confirming it is an official or properly licensed source.
/// Example: 'punjab-9-physics': ['https://<official-site>/<file>.pdf', 'Official site name'],
const Map<String, List<String>> verifiedSources = {};

/// Catalog entries (board x class x subject). Without a verified source they show "Source not added yet".
final List<Book> catalog = [
  for (final b in boards)
    for (var c = 1; c <= 12; c++)
      for (final s in subjectsForClass(c))
        () {
          final id = '${b.id}-$c-${s.toLowerCase().replaceAll(' ', '-')}';
          final src = verifiedSources[id];
          return Book(
            id: id,
            board: b.id,
            classNo: c,
            subject: s,
            language: s == 'English' ? 'English' : (s == 'Urdu' ? 'Urdu' : null),
            sourceUrl: src?[0],
            sourceName: src?[1],
          );
        }(),
];
