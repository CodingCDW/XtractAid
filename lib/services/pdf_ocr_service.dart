/// OCR abstraction for scanned or low-quality PDFs.
///
/// Default implementation is intentionally a no-op to avoid extra native
/// dependencies in standard builds. A platform-specific implementation can be
/// wired in later (e.g. pdf_ocr) when OCR fallback is enabled.
class PdfOcrService {
  const PdfOcrService();

  Future<String?> extractText(String filePath) async {
    return null;
  }
}
