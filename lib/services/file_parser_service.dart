import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as xls;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart' as xml;

import '../data/models/item.dart';

/// Result of parsing a file or folder.
class ParseResult {
  final List<Item> items;
  final List<String> warnings;

  const ParseResult({required this.items, this.warnings = const []});
}

/// Progress event emitted during folder parsing.
class ParseProgressEvent {
  final String currentFile;
  final int filesProcessed;
  final int totalFiles;

  const ParseProgressEvent({
    required this.currentFile,
    required this.filesProcessed,
    required this.totalFiles,
  });

  double get progress =>
      totalFiles > 0 ? filesProcessed / totalFiles : 0;
}

class FileParserService {
  static const int _maxCumulativeChars = 5000000; // 5M chars warning threshold

  /// Parse an Excel file. Expects columns for ID and Item text.
  Future<ParseResult> parseExcel(
    String filePath, {
    String? sheetName,
    String idColumn = 'ID',
    String itemColumn = 'Item',
  }) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = xls.Excel.decodeBytes(bytes);

    final sheet = sheetName != null
        ? excel[sheetName]
        : excel.tables.values.first;

    if (sheet.rows.isEmpty) {
      return const ParseResult(
        items: [],
        warnings: ['Excel file is empty.'],
      );
    }

    // Find column indices from header row
    final headerRow = sheet.rows.first;
    int idIdx = -1;
    int itemIdx = -1;

    for (var i = 0; i < headerRow.length; i++) {
      final cellValue = headerRow[i]?.value?.toString().trim() ?? '';
      if (cellValue.toLowerCase() == idColumn.toLowerCase()) idIdx = i;
      if (cellValue.toLowerCase() == itemColumn.toLowerCase()) itemIdx = i;
    }

    final warnings = <String>[];
    if (idIdx == -1) {
      warnings.add('Column "$idColumn" not found. Using row numbers as IDs.');
    }
    if (itemIdx == -1) {
      // Try to use second column as item
      if (headerRow.length >= 2) {
        itemIdx = idIdx == 0 ? 1 : 0;
        warnings.add(
          'Column "$itemColumn" not found. Using column ${itemIdx + 1} as item text.',
        );
      } else {
        return ParseResult(items: [], warnings: ['Column "$itemColumn" not found.']);
      }
    }

    final items = <Item>[];
    for (var rowIdx = 1; rowIdx < sheet.rows.length; rowIdx++) {
      final row = sheet.rows[rowIdx];
      final id = idIdx >= 0 && idIdx < row.length
          ? row[idIdx]?.value?.toString().trim() ?? 'R$rowIdx'
          : 'R$rowIdx';
      final text = itemIdx < row.length
          ? row[itemIdx]?.value?.toString().trim() ?? ''
          : '';
      if (text.isNotEmpty) {
        items.add(Item(id: id, text: text, source: filePath));
      }
    }

    return ParseResult(items: items, warnings: warnings);
  }

  /// Parse a CSV file.
  Future<ParseResult> parseCsv(
    String filePath, {
    String separator = ',',
    String idColumn = 'ID',
    String itemColumn = 'Item',
  }) async {
    final content = await File(filePath).readAsString(encoding: utf8);
    final lines = const LineSplitter().convert(content);
    if (lines.isEmpty) {
      return const ParseResult(items: [], warnings: ['CSV file is empty.']);
    }

    final headers = lines.first.split(separator).map((h) => h.trim()).toList();
    final idIdx = headers.indexWhere(
      (h) => h.toLowerCase() == idColumn.toLowerCase(),
    );
    final itemIdx = headers.indexWhere(
      (h) => h.toLowerCase() == itemColumn.toLowerCase(),
    );

    final warnings = <String>[];
    if (idIdx == -1) {
      warnings.add('Column "$idColumn" not found. Using row numbers.');
    }
    if (itemIdx == -1) {
      return ParseResult(
        items: [],
        warnings: ['Column "$itemColumn" not found in CSV.'],
      );
    }

    final items = <Item>[];
    for (var i = 1; i < lines.length; i++) {
      final cols = lines[i].split(separator);
      final id = idIdx >= 0 && idIdx < cols.length
          ? cols[idIdx].trim()
          : 'R$i';
      final text = itemIdx < cols.length ? cols[itemIdx].trim() : '';
      if (text.isNotEmpty) {
        items.add(Item(id: id, text: text, source: filePath));
      }
    }

    return ParseResult(items: items, warnings: warnings);
  }

  /// Parse a plain text or markdown file as a single item.
  Future<ParseResult> parseTextFile(String filePath) async {
    final file = File(filePath);
    final text = await file.readAsString(encoding: utf8);
    if (text.trim().isEmpty) {
      return ParseResult(
        items: [],
        warnings: ['File is empty: $filePath'],
      );
    }

    final fileName = file.uri.pathSegments.last;
    final id = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    return ParseResult(
      items: [Item(id: id, text: text.trim(), source: filePath)],
    );
  }

  /// Extract text from a PDF file.
  Future<ParseResult> parsePdf(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);

    try {
      final extractor = PdfTextExtractor(document);
      final text = extractor.extractText();

      if (text.trim().isEmpty) {
        return ParseResult(
          items: [],
          warnings: ['PDF contains no extractable text: $filePath'],
        );
      }

      final fileName = File(filePath).uri.pathSegments.last;
      final id = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
      return ParseResult(
        items: [Item(id: id, text: text.trim(), source: filePath)],
      );
    } finally {
      document.dispose();
    }
  }

  /// Extract text from a DOCX file (manual ZIP + XML parsing).
  Future<ParseResult> parseDocx(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final documentFile = archive.findFile('word/document.xml');
    if (documentFile == null) {
      return ParseResult(
        items: [],
        warnings: ['Invalid DOCX: word/document.xml not found in $filePath'],
      );
    }

    final xmlContent = utf8.decode(documentFile.content as List<int>);
    final doc = xml.XmlDocument.parse(xmlContent);

    // Extract text from all <w:t> elements within <w:p> paragraphs
    final paragraphs = <String>[];
    for (final paragraph in doc.findAllElements('w:p')) {
      final texts = paragraph
          .findAllElements('w:t')
          .map((e) => e.innerText)
          .join('');
      if (texts.isNotEmpty) {
        paragraphs.add(texts);
      }
    }

    final text = paragraphs.join('\n');
    if (text.trim().isEmpty) {
      return ParseResult(
        items: [],
        warnings: ['DOCX contains no text: $filePath'],
      );
    }

    final fileName = File(filePath).uri.pathSegments.last;
    final id = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    return ParseResult(
      items: [Item(id: id, text: text.trim(), source: filePath)],
    );
  }

  /// Parse a single file based on its extension.
  Future<ParseResult> parseFile(String filePath) async {
    final ext = filePath.toLowerCase().split('.').last;
    switch (ext) {
      case 'xlsx':
      case 'xls':
        return parseExcel(filePath);
      case 'csv':
        return parseCsv(filePath);
      case 'pdf':
        return parsePdf(filePath);
      case 'docx':
        return parseDocx(filePath);
      case 'txt':
      case 'md':
        return parseTextFile(filePath);
      default:
        return ParseResult(
          items: [],
          warnings: ['Unsupported file type: .$ext ($filePath)'],
        );
    }
  }

  /// Parse all supported files in a folder as a stream with progress events.
  Stream<ParseProgressEvent> parseFolderStream(
    String folderPath, {
    required void Function(List<Item> items, List<String> warnings) onComplete,
  }) async* {
    final dir = Directory(folderPath);
    final supportedExtensions = {'.xlsx', '.xls', '.csv', '.pdf', '.docx', '.txt', '.md'};

    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) {
          final ext = f.path.toLowerCase().split('.').last;
          return supportedExtensions.contains('.$ext');
        })
        .toList();

    final allItems = <Item>[];
    final allWarnings = <String>[];
    var cumulativeChars = 0;

    for (var i = 0; i < files.length; i++) {
      yield ParseProgressEvent(
        currentFile: files[i].path,
        filesProcessed: i,
        totalFiles: files.length,
      );

      final result = await parseFile(files[i].path);
      allItems.addAll(result.items);
      allWarnings.addAll(result.warnings);

      for (final item in result.items) {
        cumulativeChars += item.text.length;
      }

      if (cumulativeChars > _maxCumulativeChars && allWarnings.every((w) => !w.contains('cumulative'))) {
        allWarnings.add(
          'Warning: Cumulative text exceeds ${_maxCumulativeChars ~/ 1000000}M characters. '
          'This may result in high API costs.',
        );
      }
    }

    yield ParseProgressEvent(
      currentFile: '',
      filesProcessed: files.length,
      totalFiles: files.length,
    );

    onComplete(allItems, allWarnings);
  }
}
