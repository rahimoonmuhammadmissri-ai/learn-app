import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../core/widgets.dart';
import 'books_data.dart';
import 'books_store.dart';

/// Reads a downloaded PDF from phone storage. No internet needed.
class PdfReaderScreen extends StatelessWidget {
  const PdfReaderScreen({super.key, required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final path = BooksStore.instance.pathFor(book);
    final exists = path != null && File(path).existsSync();
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: exists
          ? PdfViewer.file(path)
          : const EmptyState(icon: Icons.error_outline_rounded, title: 'File not found', message: 'This book is not on the phone. Download it again from the book page.'),
    );
  }
}
