import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as xls;
import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:xml/xml.dart' as xml;

import '../core/constants/app_constants.dart';
import '../data/models/item.dart';
import 'pdf_ocr_service.dart';

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

  double get progress => totalFiles > 0 ? filesProcessed / totalFiles : 0;
}

class FileParserService {
  static const int _maxCumulativeChars = 5000000; // 5M chars warning threshold

  FileParserService({bool? enableOcrFallback, PdfOcrService? pdfOcrService})
    : _enableOcrFallback = enableOcrFallback ?? AppConstants.enableOcrFallback,
      _pdfOcrService = pdfOcrService ?? const PdfOcrService();

  final bool _enableOcrFallback;
  final PdfOcrService _pdfOcrService;

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
      return const ParseResult(items: [], warnings: ['Excel file is empty.']);
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
        return ParseResult(
          items: [],
          warnings: ['Column "$itemColumn" not found.'],
        );
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
      final id = idIdx >= 0 && idIdx < cols.length ? cols[idIdx].trim() : 'R$i';
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
      return ParseResult(items: [], warnings: ['File is empty: $filePath']);
    }

    final fileName = file.uri.pathSegments.last;
    final id = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    return ParseResult(
      items: [Item(id: id, text: text.trim(), source: filePath)],
    );
  }

  /// Extract text from a PDF file.
  Future<ParseResult> parsePdf(String filePath) async {
    final warnings = <String>[];
    final document = await PdfDocument.openFile(filePath);
    final buffer = StringBuffer();

    try {
      for (final page in document.pages) {
        final rawText = await page.loadText();
        final pageText = rawText.fullText;
        if (pageText.trim().isNotEmpty) {
          if (buffer.isNotEmpty) {
            buffer.writeln();
            buffer.writeln();
          }
          buffer.write(pageText.trim());
        }
      }
    } finally {
      document.dispose();
    }

    var text = buffer.toString().trim();
    if (text.isEmpty) {
      return ParseResult(
        items: [],
        warnings: ['PDF contains no extractable text: $filePath'],
      );
    }

    if (_isLowQualityPdfText(text)) {
      if (_enableOcrFallback) {
        final ocrText =
            (await _pdfOcrService.extractText(filePath))?.trim() ?? '';
        if (ocrText.isNotEmpty) {
          text = ocrText;
          warnings.add(
            'OCR fallback applied due to low-quality digital extraction: $filePath',
          );
        } else {
          warnings.add(
            'PDF text quality appears low and OCR fallback returned no text: $filePath',
          );
        }
      } else {
        warnings.add(
          'PDF text quality appears low. OCR fallback is disabled: $filePath',
        );
      }
    }

    final fileName = File(filePath).uri.pathSegments.last;
    final id = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    return ParseResult(
      items: [Item(id: id, text: text, source: filePath)],
      warnings: warnings,
    );
  }

  /// Extract text from a DOCX file.
  Future<ParseResult> parseDocx(String filePath) async {
    final extracted = await compute(_extractDocxPayload, filePath);
    final text = (extracted['text'] as String? ?? '').trim();
    final warnings = List<String>.from(
      extracted['warnings'] as List<dynamic>? ?? const [],
    );

    if (text.isEmpty) {
      return ParseResult(
        items: [],
        warnings: [...warnings, 'DOCX contains no extractable text: $filePath'],
      );
    }

    final fileName = File(filePath).uri.pathSegments.last;
    final id = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    return ParseResult(
      items: [Item(id: id, text: text, source: filePath)],
      warnings: warnings,
    );
  }

  bool _isLowQualityPdfText(String text) {
    if (text.length < 32) {
      return true;
    }

    final printableCount = text.runes.where((rune) {
      final isWhitespace = rune == 9 || rune == 10 || rune == 13 || rune == 32;
      final isAsciiPrintable = rune >= 33 && rune <= 126;
      final isLatinSupplement = rune >= 160 && rune <= 591;
      return isWhitespace || isAsciiPrintable || isLatinSupplement;
    }).length;

    final printableRatio = printableCount / text.runes.length;
    if (printableRatio < 0.7) {
      return true;
    }

    final compact = text.replaceAll(RegExp(r'\s+'), '');
    if (compact.isEmpty) {
      return true;
    }

    final uniqueChars = compact.runes.toSet().length;
    final uniquenessRatio = uniqueChars / compact.runes.length;
    return uniquenessRatio < 0.05;
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
    final supportedExtensions = {
      '.xlsx',
      '.xls',
      '.csv',
      '.pdf',
      '.docx',
      '.txt',
      '.md',
    };

    final files = dir.listSync(recursive: true).whereType<File>().where((f) {
      final ext = f.path.toLowerCase().split('.').last;
      return supportedExtensions.contains('.$ext');
    }).toList();

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

      if (cumulativeChars > _maxCumulativeChars &&
          allWarnings.every((w) => !w.contains('cumulative'))) {
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

Map<String, Object?> _extractDocxPayload(String filePath) {
  final warnings = <String>[];

  try {
    final bytes = File(filePath).readAsBytesSync();
    final zip = ZipDecoder().decodeBytes(bytes);

    final xmlCandidates = <String>[];
    for (final file in zip.files) {
      final name = file.name;
      if (!name.startsWith('word/')) {
        continue;
      }
      if (name == 'word/document.xml' ||
          name == 'word/footnotes.xml' ||
          name == 'word/endnotes.xml' ||
          name.startsWith('word/header') ||
          name.startsWith('word/footer')) {
        xmlCandidates.add(name);
      }
    }

    if (!xmlCandidates.contains('word/document.xml')) {
      return <String, Object?>{
        'text': '',
        'warnings': <String>[
          'Invalid DOCX: word/document.xml not found in $filePath',
        ],
      };
    }

    xmlCandidates.sort((a, b) {
      if (a == 'word/document.xml') {
        return -1;
      }
      if (b == 'word/document.xml') {
        return 1;
      }
      return a.compareTo(b);
    });

    final parts = <String>[];
    for (final xmlPath in xmlCandidates) {
      final entry = zip.findFile(xmlPath);
      if (entry == null) {
        continue;
      }

      final content = _archiveFileContentAsBytes(entry);
      if (content == null || content.isEmpty) {
        continue;
      }

      final parsedText = _extractWordprocessingMlText(content);
      if (parsedText.isNotEmpty) {
        parts.add(parsedText);
      }
    }

    final text = parts.join('\n\n').trim();
    if (text.isEmpty) {
      warnings.add('DOCX parsed but produced empty text body.');
    }

    return <String, Object?>{'text': text, 'warnings': warnings};
  } catch (e) {
    return <String, Object?>{
      'text': '',
      'warnings': <String>['DOCX parsing failed: $e'],
    };
  }
}

List<int>? _archiveFileContentAsBytes(ArchiveFile file) {
  final content = file.content;
  if (content is List<int>) {
    return content;
  }
  if (content is Uint8List) {
    return content;
  }
  return null;
}

String _extractWordprocessingMlText(List<int> xmlBytes) {
  final content = utf8.decode(xmlBytes, allowMalformed: true);
  final doc = xml.XmlDocument.parse(content);

  final paragraphs = <String>[];
  final paragraphElements = doc.descendants.whereType<xml.XmlElement>().where(
    (element) => element.name.local == 'p',
  );

  for (final paragraph in paragraphElements) {
    final text = _extractParagraphText(paragraph).trim();
    if (text.isNotEmpty) {
      paragraphs.add(text);
    }
  }

  if (paragraphs.isNotEmpty) {
    return paragraphs.join('\n');
  }

  // Fallback: flatten all text nodes when paragraph structure is missing.
  final fallback = doc.descendants
      .whereType<xml.XmlElement>()
      .where((element) => element.name.local == 't')
      .map((element) => element.innerText)
      .join(' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  return fallback;
}

String _extractParagraphText(xml.XmlElement paragraph) {
  final buffer = StringBuffer();

  for (final node in paragraph.descendants.whereType<xml.XmlNode>()) {
    if (node is! xml.XmlElement) {
      continue;
    }

    switch (node.name.local) {
      case 't':
        buffer.write(node.innerText);
        break;
      case 'tab':
        buffer.write('\t');
        break;
      case 'br':
      case 'cr':
        buffer.write('\n');
        break;
    }
  }

  return buffer.toString();
}
