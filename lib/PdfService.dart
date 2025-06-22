import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<File> generateInventoryPdf({
    required String customerName,
    required String phone,
    required String address,
    required String date,
    required String room,
    required String fileType,
    required String rate,
    required String additionalCharges,
    required String advance,
    required String totalSqFt,
    required String totalAmount,
    required String remainingBalance,
    required List<Map<String, dynamic>> dimensions,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('LOCK DESIGN PROJECT',
                    style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange)),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Project Details', style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800)),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 15),

              // Customer Information
              _buildPdfSection('Customer Information', [
                _buildPdfDetailRow('Customer Name:', customerName),
                _buildPdfDetailRow('Phone:', phone),
                _buildPdfDetailRow('Address:', address),
                _buildPdfDetailRow('Date:', date),
              ]),

              pw.SizedBox(height: 20),

              // Project Details
              _buildPdfSection('Project Specifications', [
                _buildPdfDetailRow('Room:', room),
                _buildPdfDetailRow('Material Type:', fileType),
              ]),

              pw.SizedBox(height: 20),

              // Dimensions
              _buildPdfSection('Dimensions', [
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                            child: pw.Text('Wall',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            padding: pw.EdgeInsets.all(8)),
                        pw.Padding(
                            child: pw.Text('Width (ft)',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            padding: pw.EdgeInsets.all(8)),
                        pw.Padding(
                            child: pw.Text('Height (ft)',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            padding: pw.EdgeInsets.all(8)),
                        pw.Padding(
                            child: pw.Text('Sq.ft',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            padding: pw.EdgeInsets.all(8)),
                      ],
                    ),
                    ...dimensions.map((dim) => pw.TableRow(
                      children: [
                        pw.Padding(
                            child: pw.Text(dim['wall']?.toString() ?? 'Wall'),
                            padding: pw.EdgeInsets.all(8)),
                        pw.Padding(
                            child: pw.Text(dim['width']?.toString() ?? '0'),
                            padding: pw.EdgeInsets.all(8)),
                        pw.Padding(
                            child: pw.Text(dim['height']?.toString() ?? '0'),
                            padding: pw.EdgeInsets.all(8)),
                        pw.Padding(
                            child: pw.Text(dim['sqFt']?.toString() ?? '0'),
                            padding: pw.EdgeInsets.all(8)),
                      ],
                    )),
                  ],
                ),
              ]),

              pw.SizedBox(height: 20),

              // Financial Summary
              _buildPdfSection('Financial Summary', [
                _buildPdfAmountRow('Rate per Sq.ft:', 'Rs$rate'),
                _buildPdfAmountRow('Total Area:', '$totalSqFt sq.ft'),
                _buildPdfAmountRow('Additional Charges:', 'Rs$additionalCharges'),
                _buildPdfAmountRow('Total Amount:', 'Rs$totalAmount'),
                _buildPdfAmountRow('Advance:', 'Rs$advance'),
                _buildPdfAmountRow('Remaining Balance:', 'Rs$remainingBalance',
                    isTotal: true),
              ]),

              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Text('Thank you for choosing Lock Design Pro!',
                    style: pw.TextStyle(
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.orange)),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/project_${customerName}_$date.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildPdfSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 16,
              color: PdfColors.blueGrey800
          ),
        ),
        pw.SizedBox(height: 8),
        ...children,
      ],
    );
  }

  static pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style:  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 10),
          pw.Text(value),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfAmountRow(String label, String value, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
          )),
          pw.Text(value, style: pw.TextStyle(
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
          )),
        ],
      ),
    );
  }

  static Future<void> sharePdf(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.path.split('/').last,
    );
  }
}