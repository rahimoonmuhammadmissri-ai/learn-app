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

const mediums = ['English', 'Urdu', 'Sindhi'];

Board boardById(String id) => boards.firstWhere((b) => b.id == id);

class Book {
  const Book({
    required this.id,
    required this.board,
    required this.classNo,
    required this.title,
    required this.subject,
    required this.medium,
    required this.edition,
    required this.pageUrl,
    this.pdfUrl,
  });

  /// App id, e.g. stbb-85 (board + official portal id).
  final String id, board, title, subject, medium, edition, pageUrl;

  /// 0 = ECCE / Katchi, 1-12 = Class 1-12.
  final int classNo;

  /// Official direct download link. null = no verified download link, shown as Unavailable.
  final String? pdfUrl;

  String get classLabel => classNo == 0 ? 'ECCE' : 'Class $classNo';
}

/// Only books verified against the official portal are listed here.
/// Each entry: detail page opened, "Download PDF" button link copied from that page.
const List<Book> catalog = [
  // Verified 2026-10-12: https://portal.stbb.edu.pk/ebooks/book.php?id=85
  Book(
    id: 'stbb-85',
    board: 'stbb',
    classNo: 3,
    title: 'Math III',
    subject: 'Mathematics',
    medium: 'English',
    edition: '2024-25',
    pageUrl: 'https://portal.stbb.edu.pk/ebooks/book.php?id=85',
    pdfUrl: 'https://portal.stbb.edu.pk/ebooks/pdf_proxy.php?id=85&download=1',
  ),
];
