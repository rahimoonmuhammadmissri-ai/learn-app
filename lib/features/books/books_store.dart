import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'books_data.dart';

enum BookStatus { download, downloading, downloaded, failed, unavailable }

/// Library filters (saved across restarts) and downloaded PDFs (saved in app storage).
class BooksStore extends ChangeNotifier {
  BooksStore._();
  static final instance = BooksStore._();

  SharedPreferences? _p;
  Directory? _dir;
  bool ready = false;
  String? initError;
  String? board, subject, medium;
  int? classNo;
  final Set<String> downloaded = {};
  final Map<String, double> progress = {}; // 0..1, -1 = size unknown
  final Map<String, int> received = {}, totalBytes = {};
  final Map<String, String> errors = {};
  final Set<String> _cancelling = {};

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      _p = p;
      final b = p.getString('lib_board');
      board = boards.any((x) => x.id == b) ? b : null;
      final c = p.getInt('lib_class');
      classNo = (c != null && c >= 0 && c <= 12) ? c : null;
      final m = p.getString('lib_medium');
      medium = mediums.contains(m) ? m : null;
      subject = p.getString('lib_subject');
      _fixSubject();
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/books')..createSync(recursive: true);
      _dir = dir;
      final known = catalog.map((x) => x.id).toSet();
      for (final f in dir.listSync()) {
        if (f is! File) continue;
        if (f.path.endsWith('.part')) {
          f.deleteSync();
        } else if (f.path.endsWith('.pdf')) {
          final id = f.uri.pathSegments.last.replaceAll('.pdf', '');
          if (known.contains(id) && f.lengthSync() > 0) downloaded.add(id);
        }
      }
    } catch (e) {
      initError = '$e';
    }
    ready = true;
    notifyListeners();
  }

  void _put(String k, Object? v) {
    final p = _p;
    if (p == null) return;
    if (v == null) {
      p.remove(k);
    } else if (v is int) {
      p.setInt(k, v);
    } else {
      p.setString(k, v as String);
    }
  }

  void _save() {
    _put('lib_board', board);
    _put('lib_class', classNo);
    _put('lib_medium', medium);
    _put('lib_subject', subject);
    notifyListeners();
  }

  void _fixSubject() {
    if (subject != null && !subjects().contains(subject)) subject = null;
  }

  void setBoard(String? v) {
    board = v;
    _fixSubject();
    _save();
  }

  void setClass(int? v) {
    classNo = v;
    _fixSubject();
    _save();
  }

  void setMedium(String? v) {
    medium = v;
    _fixSubject();
    _save();
  }

  void setSubject(String? v) {
    subject = v;
    _save();
  }

  void clearFilters() {
    board = classNo = medium = subject = null;
    _save();
  }

  bool get hasFilters => board != null || classNo != null || subject != null || medium != null;

  /// Subjects that exist in the catalog for the current board/class/medium selection.
  List<String> subjects() {
    final s = <String>{};
    for (final b in catalog) {
      if ((board == null || b.board == board) && (classNo == null || b.classNo == classNo) && (medium == null || b.medium == medium)) {
        s.add(b.subject);
      }
    }
    return s.toList()..sort();
  }

  /// Library: filters + search. Downloaded: only downloaded books, search only.
  List<Book> filter(String q, {required bool library}) {
    final words = q.trim().toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return catalog.where((b) {
      if (!library && !downloaded.contains(b.id)) return false;
      if (library) {
        if (board != null && b.board != board) return false;
        if (classNo != null && b.classNo != classNo) return false;
        if (medium != null && b.medium != medium) return false;
        if (subject != null && b.subject != subject) return false;
      }
      if (words.isEmpty) return true;
      final bd = boardById(b.board);
      final hay = '${b.title} ${b.subject} ${b.classLabel} ${bd.name} ${bd.short} ${b.medium} ${b.edition}'.toLowerCase();
      return words.every((w) => hay.contains(w));
    }).toList();
  }

  BookStatus statusOf(Book b) {
    if (downloaded.contains(b.id)) return BookStatus.downloaded;
    if (progress.containsKey(b.id)) return BookStatus.downloading;
    if (b.pdfUrl == null) return BookStatus.unavailable;
    if (errors.containsKey(b.id)) return BookStatus.failed;
    return BookStatus.download;
  }

  String? pathFor(Book b) => _dir == null ? null : '${_dir!.path}/${b.id}.pdf';

  void cancel(Book b) => _cancelling.add(b.id);

  String _friendly(Object e) {
    if (e is SocketException) return 'No internet connection, or the STBB server could not be reached.';
    if (e is HandshakeException) return 'Secure connection failed. Check the phone date and time.';
    return '$e';
  }

  Future<void> download(Book b) async {
    final url = b.pdfUrl;
    final path = pathFor(b);
    if (url == null || path == null || progress.containsKey(b.id)) return;
    errors.remove(b.id);
    _cancelling.remove(b.id);
    progress[b.id] = 0;
    received[b.id] = 0;
    totalBytes[b.id] = 0;
    notifyListeners();
    final tmp = File('$path.part');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    IOSink? sink;
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.userAgentHeader, 'LearnStudyApp/0.3 (Android)');
      req.headers.set(HttpHeaders.acceptHeader, 'application/pdf');
      final res = await req.close();
      if (res.statusCode != 200) throw 'Server returned ${res.statusCode}';
      final total = res.contentLength;
      totalBytes[b.id] = total > 0 ? total : 0;
      sink = tmp.openWrite();
      var got = 0;
      var first = true;
      await for (final chunk in res) {
        if (_cancelling.contains(b.id)) throw 'Cancelled';
        if (first) {
          first = false;
          if (chunk.length < 4 || String.fromCharCodes(chunk.take(4)) != '%PDF') throw 'The server did not return a PDF file';
        }
        sink.add(chunk);
        got += chunk.length;
        received[b.id] = got;
        progress[b.id] = total > 0 ? got / total : -1;
        notifyListeners();
      }
      await sink.flush();
      await sink.close();
      sink = null;
      if (total > 0 && got < total) throw 'Download incomplete ($got of $total bytes)';
      if (got < 1024) throw 'The file is too small to be a book';
      await tmp.rename(path);
      downloaded.add(b.id);
    } catch (e) {
      try {
        await sink?.close();
      } catch (_) {}
      if (tmp.existsSync()) tmp.deleteSync();
      if ('$e' != 'Cancelled') errors[b.id] = _friendly(e);
    } finally {
      client.close();
      progress.remove(b.id);
      received.remove(b.id);
      totalBytes.remove(b.id);
      _cancelling.remove(b.id);
      notifyListeners();
    }
  }

  Future<void> delete(Book b) async {
    final p = pathFor(b);
    if (p != null) {
      final f = File(p);
      if (f.existsSync()) await f.delete();
    }
    downloaded.remove(b.id);
    notifyListeners();
  }
}
