// STBB proof of concept. Makes about 9 polite requests, sequentially, with delays.
// Reads robots.txt first and stops if it is missing, unclear or disallows our paths.
// Writes poc_report.md and poc_raw/. Does not modify anything in the repository.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

const host = 'portal.stbb.edu.pk';
const origin = 'https://$host';
const base = '$origin/ebooks';
const ua = 'LearnStudyApp-POC/0.1 (small catalog check; contact via GitHub repo learn-app)';

const listingTargets = [
  ('class3_english', 'Class III, English', '$base/class.php?id=4&medium=English'),
  ('class9_english', 'Class IX, English', '$base/class.php?id=10&medium=English'),
];
const bookTargets = [(85, 'class3_english'), (117, 'class9_english'), (174, 'class9_english')];

final reqLog = <String>[];
DateTime? _lastReq;
int requests = 0;

class Abort implements Exception {
  Abort(this.msg);
  final String msg;
}

void log(String s) => stdout.writeln(s);

Future<void> pace() async {
  final l = _lastReq;
  if (l != null) {
    final wait = const Duration(seconds: 2) - DateTime.now().difference(l);
    if (wait > Duration.zero) await Future<void>.delayed(wait);
  }
  _lastReq = DateTime.now();
}

class Resp {
  Resp(this.status, this.headers, this.bytes, this.url);
  final int status;
  final Map<String, String> headers;
  final List<int> bytes;
  final Uri url;
  String get text => utf8.decode(bytes, allowMalformed: true);
}

/// Sequential GET. 403/429 = stop at once. Timeout/5xx = one retry after 10 s, then stop.
/// Redirects are followed only inside the same host. probe = read at most the first 1 KB.
Future<Resp> get(String url, {bool probe = false, int maxBytes = 2000000}) async {
  for (var attempt = 0; attempt < 2; attempt++) {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20)
      ..autoUncompress = !probe;
    try {
      var u = Uri.parse(url);
      for (var hop = 0; hop < 4; hop++) {
        await pace();
        requests++;
        final sw = Stopwatch()..start();
        final req = await client.getUrl(u);
        req.followRedirects = false;
        req.headers.set(HttpHeaders.userAgentHeader, ua);
        if (probe) {
          req.headers.set(HttpHeaders.rangeHeader, 'bytes=0-1023');
          req.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
        }
        final res = await req.close().timeout(const Duration(seconds: 30));
        final hdr = <String, String>{};
        res.headers.forEach((k, v) => hdr[k.toLowerCase()] = v.join(', '));
        final code = res.statusCode;
        if (code == 301 || code == 302 || code == 303 || code == 307 || code == 308) {
          await res.drain<void>();
          final loc = hdr['location'];
          if (loc == null) throw Abort('Redirect without Location header at $u');
          final next = u.resolve(loc);
          reqLog.add('$code ${sw.elapsedMilliseconds}ms redirect $u -> $next');
          log(reqLog.last);
          if (next.host != host) throw Abort('Redirected to another host (${next.host}); not followed. Stopping.');
          u = next;
          continue;
        }
        final bytes = <int>[];
        final limit = probe ? 1024 : maxBytes;
        await for (final c in res.timeout(const Duration(seconds: 30))) {
          bytes.addAll(c);
          if (bytes.length >= limit) break;
        }
        reqLog.add('$code ${sw.elapsedMilliseconds}ms ${bytes.length}B $u');
        log(reqLog.last);
        if (code == 403 || code == 429) {
          throw Abort('HTTP $code from $u: blocked or rate-limited. Stopping; nothing was bypassed.');
        }
        if (code >= 500) throw HttpException('HTTP $code');
        return Resp(code, hdr, bytes, u);
      }
      throw Abort('Too many redirects for $url');
    } on Abort {
      rethrow;
    } catch (e) {
      reqLog.add('ERROR attempt ${attempt + 1}: ${e.runtimeType} $e  $url');
      log(reqLog.last);
      if (attempt == 0) {
        log('Retrying once after 10 seconds...');
        await Future<void>.delayed(const Duration(seconds: 10));
        continue;
      }
      throw Abort('Failed after one retry (${e.runtimeType}): $url');
    } finally {
      client.close(force: true);
    }
  }
  throw Abort('Unreachable');
}

// ---------- robots.txt (RFC 9309 style, longest match wins) ----------
String robotsNote = 'not checked';

bool _match(String pat, String path) {
  var esc = RegExp.escape(pat).replaceAll(r'\*', '.*');
  if (pat.endsWith(r'$')) {
    esc = '${esc.substring(0, esc.length - 2)}\$';
  }
  return RegExp('^$esc').hasMatch(path);
}

Future<bool> robotsAllows(List<String> paths) async {
  Resp r;
  try {
    r = await get('$origin/robots.txt', maxBytes: 200000);
  } on Abort catch (e) {
    robotsNote = 'robots.txt could not be fetched (${e.msg}). Stopping; permission not assumed.';
    return false;
  }
  File('poc_raw/robots.txt').writeAsStringSync('HTTP ${r.status}\n\n${r.text}');
  if (r.status != 200) {
    robotsNote = 'robots.txt returned HTTP ${r.status} (missing or unavailable). Stopping; permission not assumed.';
    return false;
  }
  final t = r.text;
  final looksHtml = RegExp(r'<\s*(html|!doctype)', caseSensitive: false).hasMatch(t);
  if (looksHtml || !RegExp(r'user-agent', caseSensitive: false).hasMatch(t)) {
    robotsNote = 'robots.txt is unclear (HTML page or no User-agent line). Stopping; permission not assumed.';
    return false;
  }
  final groups = <List<String>>[]; // each: agents (prefixed a:) and rules (prefixed A: / D:)
  List<String>? cur;
  var lastWasAgent = false;
  for (final raw in t.split(RegExp(r'\r?\n'))) {
    final line = raw.split('#').first.trim();
    final i = line.indexOf(':');
    if (i < 0) continue;
    final k = line.substring(0, i).trim().toLowerCase();
    final v = line.substring(i + 1).trim();
    if (k == 'user-agent') {
      if (!lastWasAgent || cur == null) {
        cur = <String>[];
        groups.add(cur);
      }
      cur.add('a:${v.toLowerCase()}');
      lastWasAgent = true;
    } else if ((k == 'allow' || k == 'disallow') && cur != null) {
      cur.add('${k == 'allow' ? 'A' : 'D'}:$v');
      lastWasAgent = false;
    } else {
      lastWasAgent = false;
    }
  }
  bool has(List<String> g, bool Function(String) f) => g.any((x) => x.startsWith('a:') && f(x.substring(2)));
  var sel = groups.where((g) => has(g, (a) => a.contains('learnstudyapp'))).toList();
  if (sel.isEmpty) sel = groups.where((g) => has(g, (a) => a == '*')).toList();
  final rules = <String>[for (final g in sel) ...g.where((x) => !x.startsWith('a:'))];
  final blocked = <String>[];
  for (final p in paths) {
    var bestLen = -1;
    var allow = true;
    for (final rule in rules) {
      final pat = rule.substring(2);
      if (pat.isEmpty) continue;
      if (_match(pat, p) && pat.length >= bestLen) {
        if (pat.length > bestLen || rule.startsWith('A')) allow = rule.startsWith('A');
        bestLen = pat.length;
      }
    }
    if (!allow) blocked.add(p);
  }
  if (blocked.isNotEmpty) {
    robotsNote = 'robots.txt DISALLOWS: ${blocked.join(', ')}. Stopping.';
    return false;
  }
  robotsNote = 'robots.txt fetched (HTTP 200) and does not disallow ${paths.join(', ')} for this client (${sel.length} matching group(s), ${rules.length} rule(s)).';
  return true;
}

// ---------- parsing (first attempt, from the real HTML; any miss is reported as NO-DATA) ----------
String decodeEnt(String s) => s
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&amp;', '&');

List<String> textLines(String html) {
  var h = html.replaceAll(RegExp(r'<(script|style)\b[^>]*>.*?</\1>', caseSensitive: false, dotAll: true), ' ');
  h = h.replaceAll(RegExp(r'<[^>]+>'), '\n');
  return decodeEnt(h).split('\n').map((l) => l.replaceAll(RegExp(r'\s+'), ' ').trim()).where((l) => l.isNotEmpty).toList();
}

String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

class ListEntry {
  ListEntry(this.id, this.title, this.medium, this.cls, this.year, this.text);
  final int id;
  final String? title, medium, cls, year;
  final String text;
}

Map<int, ListEntry> parseListing(String html) {
  final out = <int, ListEntry>{};
  final re = RegExp(r'''<a\b[^>]*?href\s*=\s*["']([^"']*book\.php\?id=(\d+)[^"']*)["'][^>]*>(.*?)</a>''', caseSensitive: false, dotAll: true);
  for (final m in re.allMatches(html)) {
    final id = int.parse(m.group(2)!);
    final lines = textLines(m.group(3)!);
    final joined = lines.join(' ');
    final med = RegExp(r'(English|Urdu|Sindhi)').allMatches(joined);
    final cy = RegExp(r'(\S+)\s*\u2022\s*(\d{4}(?:-\d{2,4})?)').firstMatch(joined);
    final e = ListEntry(id, lines.isEmpty ? null : lines.first, med.isEmpty ? null : med.first.group(1), cy?.group(1), cy?.group(2), joined);
    final old = out[id];
    if (old == null || (old.year == null && e.year != null)) out[id] = e;
  }
  return out;
}

class DetailInfo {
  DetailInfo(this.title, this.cls, this.medium, this.year, this.link, this.linkId);
  final String? title, cls, medium, year, link;
  final int? linkId;
}

DetailInfo parseDetail(String html, Uri pageUrl) {
  final h1 = RegExp(r'<h1\b[^>]*>(.*?)</h1>', caseSensitive: false, dotAll: true).firstMatch(html);
  final title = h1 == null ? null : textLines(h1.group(1)!).join(' ');
  final lines = textLines(html);
  String? after(String label) {
    final i = lines.indexWhere((l) => l.toLowerCase() == label);
    return (i >= 0 && i + 1 < lines.length) ? lines[i + 1] : null;
  }

  final links = RegExp(r'''href\s*=\s*["']([^"']*pdf_proxy\.php\?id=(\d+)[^"']*)["']''', caseSensitive: false).allMatches(html).toList();
  RegExpMatch? pick;
  for (final m in links) {
    if (m.group(1)!.contains('download=1')) {
      pick = m;
      break;
    }
  }
  pick ??= links.isEmpty ? null : links.first;
  final link = pick == null ? null : pageUrl.resolve(decodeEnt(pick.group(1)!)).toString();
  return DetailInfo(title, after('class'), after('medium'), after('year'), link, pick == null ? null : int.parse(pick.group(2)!));
}

class PdfInfo {
  PdfInfo(this.status, this.first, this.size, this.range, this.headers);
  final int status;
  final String first, range;
  final int? size;
  final Map<String, String> headers;
}

Future<PdfInfo> probePdf(String url) async {
  final r = await get(url, probe: true);
  final first = String.fromCharCodes(r.bytes.take(5).map((b) => (b >= 32 && b < 127) ? b : 63));
  final cr = r.headers['content-range'];
  final cm = cr == null ? null : RegExp(r'/(\d+)$').firstMatch(cr);
  int? size;
  if (cm != null) {
    size = int.parse(cm.group(1)!);
  } else if (r.status == 200) {
    size = int.tryParse(r.headers['content-length'] ?? '');
  }
  final range = (r.status == 206 && cr != null) ? 'supported' : (r.status == 200 ? 'unsupported' : 'unknown');
  final keep = <String, String>{};
  for (final k in ['content-type', 'content-length', 'content-range', 'accept-ranges', 'content-disposition']) {
    if (r.headers[k] != null) keep[k] = r.headers[k]!;
  }
  return PdfInfo(r.status, first, size, range, keep);
}

// ---------- collected data ----------
final listingStatus = <String, String>{};
final listings = <String, Map<int, ListEntry>>{};
final listingHtml = <String, String>{};
final detailStatus = <int, String>{};
final details = <int, DetailInfo>{};
final detailHtml = <int, String>{};
final pdfs = <int, PdfInfo>{};

class Check {
  Check(this.name, this.status, [this.note = '']);
  final String name, status, note;
}

Check cmp(String name, String? a, String? b) {
  if (a == null || b == null) return Check(name, 'NO-DATA', 'listing=${a ?? 'n/a'} detail=${b ?? 'n/a'}');
  return norm(a) == norm(b) ? Check(name, 'PASS', a) : Check(name, 'FAIL', 'listing "$a" vs detail "$b"');
}

List<Check> checksFor(int id, String key) {
  final le = listings[key]?[id];
  final di = details[id];
  final pi = pdfs[id];
  final c = <Check>[];
  c.add(le != null ? Check('Listing entry found', 'PASS') : Check('Listing entry found', listings[key] == null ? 'NO-DATA' : 'FAIL', 'listing fetched? ${listings[key] != null}'));
  c.add(di != null ? Check('Detail page parsed', 'PASS') : Check('Detail page parsed', 'NO-DATA', detailStatus[id] ?? 'not fetched'));
  c.add(di?.link != null ? Check('Download link on detail page', 'PASS', di!.link!) : Check('Download link on detail page', 'NO-DATA'));
  c.add(di?.linkId == null ? Check('Link id equals book id', 'NO-DATA') : (di!.linkId == id ? Check('Link id equals book id', 'PASS') : Check('Link id equals book id', 'FAIL', 'link id ${di.linkId}')));
  c.add(cmp('Title (listing vs detail)', le?.title, di?.title));
  c.add(cmp('Class (listing vs detail)', le?.cls, di?.cls));
  c.add(cmp('Medium (listing vs detail)', le?.medium, di?.medium));
  c.add(cmp('Year (listing vs detail)', le?.year, di?.year));
  if (pi == null) {
    c.add(Check('PDF starts with %PDF', 'NO-DATA', 'not probed'));
  } else if (pi.status != 200 && pi.status != 206) {
    c.add(Check('PDF starts with %PDF', 'FAIL', 'HTTP ${pi.status}'));
  } else {
    c.add(pi.first.startsWith('%PDF') ? Check('PDF starts with %PDF', 'PASS', pi.first) : Check('PDF starts with %PDF', 'FAIL', 'first bytes: ${pi.first}'));
  }
  return c;
}

String snippet(String html, String needle) {
  var i = html.indexOf(needle);
  if (i < 0) i = 0;
  return html.substring(max(0, i - 600), min(html.length, i + 900)).replaceAll('```', "'''");
}

String cell(String s) => s.replaceAll('|', '/').replaceAll('\n', ' ');

void writeReport(String? abortMsg, DateTime started) {
  final b = StringBuffer();
  b.writeln('# STBB proof-of-concept report');
  b.writeln('');
  b.writeln('NOT verified until reviewed by a human. Script output only. Started ${started.toIso8601String()} UTC. Dart ${Platform.version.split(' ').first}.');
  b.writeln('');
  b.writeln('Requests made: $requests (sequential, 2 s apart, User-Agent: `$ua`)');
  if (abortMsg != null) b.writeln('\n**STOPPED: $abortMsg**');
  b.writeln('\n## 1. robots.txt\n$robotsNote');
  b.writeln('\n## 2. Request log\n```');
  for (final l in reqLog) {
    b.writeln(l);
  }
  b.writeln('```');
  b.writeln('\n## 3. Listing pages');
  for (final t in listingTargets) {
    final n = listings[t.$1]?.length;
    b.writeln('- ${t.$2}: ${listingStatus[t.$1] ?? 'not fetched'}; book links parsed: ${n ?? 'n/a'} (ids: ${listings[t.$1]?.keys.take(12).join(', ') ?? 'n/a'})');
  }
  var verified = 0, failed = 0, unverified = 0;
  final sample = <Map<String, Object?>>[];
  b.writeln('\n## 4. Per-book cross-check');
  for (final t in bookTargets) {
    final id = t.$1;
    final cs = checksFor(id, t.$2);
    final anyFail = cs.any((c) => c.status == 'FAIL');
    final allPass = cs.every((c) => c.status == 'PASS');
    if (allPass) {
      verified++;
    } else if (anyFail) {
      failed++;
    } else {
      unverified++;
    }
    b.writeln('\n### Book id $id: ${allPass ? 'ALL CHECKS PASS' : (anyFail ? 'HAS FAILURES' : 'UNVERIFIED (missing data)')}');
    b.writeln('| check | status | note |\n|---|---|---|');
    for (final c in cs) {
      b.writeln('| ${cell(c.name)} | ${c.status} | ${cell(c.note)} |');
    }
    final pi = pdfs[id];
    if (pi != null) {
      b.writeln('\nPDF probe: HTTP ${pi.status}; Range: **${pi.range}**${pi.range == 'unsupported' ? ' (server ignored Range; only the first 1 KB was read and the connection was closed. This does not mean the PDF is invalid)' : ''}; total size: ${pi.size ?? 'unknown'} bytes; headers: ${cell(pi.headers.toString())}');
    }
    final di = details[id];
    sample.add({
      'id': id,
      'title': di?.title,
      'class': di?.cls,
      'medium': di?.medium,
      'year': di?.year,
      'pageUrl': '$base/book.php?id=$id',
      'pdfUrl': di?.link,
      'pdfSizeBytes': pi?.size,
      'rangeSupport': pi?.range ?? 'not probed',
      'checks': {for (final c in cs) c.name: c.status},
      'verified': allPass,
    });
  }
  b.writeln('\n## 5. Counts (this POC only, 3 books)');
  final okPages = listingStatus.values.where((s) => s.startsWith('HTTP 200')).length + detailStatus.values.where((s) => s.startsWith('HTTP 200')).length;
  final parsedDetails = details.values.where((d) => d.title != null && d.link != null).length;
  b.writeln('- Pages fetched with HTTP 200 (listing + detail): $okPages of ${listingTargets.length + bookTargets.length}');
  b.writeln('- Detail pages parsed (title and download link found): $parsedDetails of ${bookTargets.length}');
  b.writeln('- Books verified (all checks PASS): $verified');
  b.writeln('- Books with failures: $failed');
  b.writeln('- Books unverified (missing data or not fetched): $unverified');
  b.writeln('\n## 6. Sample JSON (from detail pages; for review only)');
  b.writeln('```json\n${const JsonEncoder.withIndent('  ').convert(sample)}\n```');
  b.writeln('\n## 7. Raw HTML around the parsed parts (so the parser can be checked against the real page)');
  for (final k in listingHtml.keys) {
    b.writeln('\n<details><summary>Listing $k</summary>\n\n```html\n${snippet(listingHtml[k]!, 'book.php?id=')}\n```\n\n</details>');
  }
  for (final id in detailHtml.keys) {
    b.writeln('\n<details><summary>Detail page $id</summary>\n\n```html\n${snippet(detailHtml[id]!, 'pdf_proxy')}\n```\n\n</details>');
  }
  File('poc_report.md').writeAsStringSync(b.toString());
}

Future<void> main() async {
  Directory('poc_raw').createSync(recursive: true);
  final started = DateTime.now().toUtc();
  String? abortMsg;
  try {
    final ok = await robotsAllows(['/ebooks/class.php', '/ebooks/book.php', '/ebooks/pdf_proxy.php']);
    log(robotsNote);
    if (ok) {
      for (final t in listingTargets) {
        final r = await get(t.$3);
        listingStatus[t.$1] = 'HTTP ${r.status}';
        listingHtml[t.$1] = r.text;
        File('poc_raw/listing_${t.$1}.html').writeAsStringSync(r.text);
        if (r.status == 200) listings[t.$1] = parseListing(r.text);
      }
      for (final t in bookTargets) {
        final id = t.$1;
        final r = await get('$base/book.php?id=$id');
        detailStatus[id] = 'HTTP ${r.status}';
        detailHtml[id] = r.text;
        File('poc_raw/detail_$id.html').writeAsStringSync(r.text);
        if (r.status == 200) details[id] = parseDetail(r.text, r.url);
      }
      for (final t in bookTargets) {
        final link = details[t.$1]?.link;
        if (link == null) continue;
        final p = await probePdf(link);
        pdfs[t.$1] = p;
        File('poc_raw/pdf_probe_${t.$1}.txt').writeAsStringSync('HTTP ${p.status}\nfirst bytes: ${p.first}\nrange: ${p.range}\nsize: ${p.size}\n${p.headers}\n');
      }
    }
  } on Abort catch (e) {
    abortMsg = e.msg;
    log('STOPPED: $abortMsg');
  } catch (e) {
    abortMsg = 'Unexpected error: ${e.runtimeType} $e';
    log(abortMsg);
  } finally {
    writeReport(abortMsg, started);
  }
}
