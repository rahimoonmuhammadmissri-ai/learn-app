import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'books_data.dart';

/// Holds library filters (saved across restarts) and downloaded PDFs (saved in app storage).
class BooksStore extends ChangeNotifier {
  BooksStore._();
  static final instance = BooksStore._();

  SharedPreferences? _p;
  Directory? _dir;
  bool ready = false;
  String? initError;
  String? board, subject;
  int? classNo;
  final Set<String> downloaded = {};
  final Map<String, double> progress = {}; // 0..1, -1 = size unknown
  final Map<String, String> errors = {};

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      _p = p;
      final b = p.getString('lib_board');
      board = boards.any((x) => x.id == b) ? b : null;
      final c = p.getInt('lib_class');
      classNo = (c != null && c >= 1 && c <= 12) ? c : null;
      final s = p.getString('lib_subject');
      subject = (s != null && allSubjects.contains(s) && (classNo == null || subjectsForClass(classNo!).contains(s))) ? s : null;
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/books')..createSync(recursive: true);
      _dir = dir;
      for (final f in dir.listSync()) {
        if (f is File && f.path.endsWith('.pdf')) downloaded.add(f.uri.pathSegments.last.replaceAll('.pdf', ''));
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
    _put('lib_subject', subject);
    notifyListeners();
  }

  void setBoard(String? v) {
    board = v;
    _save();
  }

  void setClass(int? v) {
    classNo = v;
    if (v != null && subject != null && !subjectsForClass(v).contains(subject)) subject = null;
    _save();
  }

  void setSubject(String? v) {
    subject = v;
    _save();
  }

  void clearFilters() {
    board = null;
    classNo = null;
    subject = null;
    _save();
  }

  bool get hasFilters => board != null || classNo != null || subject != null;

  /// Library: filters + search. Downloaded: only downloaded books, search only.
  List<Book> filter(String q, {required bool library}) {
    final words = q.trim().toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return catalog.where((b) {
      if (!library && !downloaded.contains(b.id)) return false;
      if (library) {
        if (board != null && b.board != board) return false;
        if (classNo != null && b.classNo != classNo) return false;
        if (subject != null && b.subject != subject) return false;
      }
      if (words.isEmpty) return true;
      final bd = boardById(b.board);
      final hay = '${b.subject} class ${b.classNo} ${bd.name} ${bd.short} ${b.language ?? ''}'.toLowerCase();
      return words.every((w) => hay.contains(w));
    }).toList();
  }

  String? pathFor(Book b) => _dir == null ? null : '${_dir!.path}/${b.id}.pdf';

  Future<void> download(Book b) async {
    final url = b.sourceUrl;
    final path = pathFor(b);
    if (url == null || path == null || progress.containsKey(b.id)) return;
    errors.remove(b.id);
    progress[b.id] = 0;
    notifyListeners();
    final tmp = File('$path.part');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    IOSink? sink;
    try {
      final res = await (await client.getUrl(Uri.parse(url))).close();
      if (res.statusCode != 200) throw 'Server returned ${res.statusCode}';
      final total = res.contentLength;
      sink = tmp.openWrite();
      var got = 0;
      var first = true;
      await for (final chunk in res) {
        if (first) {
          first = false;
          if (chunk.length < 4 || String.fromCharCodes(chunk.take(4)) != '%PDF') throw 'The link did not return a PDF file';
        }
        sink.add(chunk);
        got += chunk.length;
        progress[b.id] = total > 0 ? got / total : -1;
        notifyListeners();
      }
      await sink.flush();
      await sink.close();
      sink = null;
      await tmp.rename(path);
      downloaded.add(b.id);
    } catch (e) {
      try {
        await sink?.close();
      } catch (_) {}
      if (tmp.existsSync()) tmp.deleteSync();
      errors[b.id] = '$e'.contains('SocketException') ? 'No internet connection, or the server is not reachable.' : '$e';
    } finally {
      client.close();
      progress.remove(b.id);
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
