/// OCR abstraction for scanned or low-quality PDFs.
///
/// Default implementation stays dependency-free so standard builds remain
/// stable. Wire a concrete OCR backend in environments where native OCR
/// toolchains are available.
class PdfOcrService {
  const PdfOcrService();

  Future<String?> extractText(String filePath) async {
    return null;
  }
}
