import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
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
                child: pw.Text('Inventory Details',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              _buildDetailRow('Customer Name:', customerName),
              _buildDetailRow('Phone:', phone),
              _buildDetailRow('Address:', address),
              _buildDetailRow('Date:', date),
              _buildDetailRow('Room:', room),
              _buildDetailRow('File Type:', fileType),
              pw.SizedBox(height: 20),
              pw.Text('Dimensions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        child: pw.Text('Wall', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        padding: pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text('Width (ft)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        padding: pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text('Height (ft)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        padding: pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text('Sq.ft', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        padding: pw.EdgeInsets.all(4),
                      ),
                    ],
                  ),
                  ...dimensions.map((dim) => pw.TableRow(
                    children: [
                      pw.Padding(
                        child: pw.Text(dim['wall'] ?? 'Wall'),
                        padding: pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text(dim['width'].toString()),
                        padding: pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text(dim['height'].toString()),
                        padding: pw.EdgeInsets.all(4),
                      ),
                      pw.Padding(
                        child: pw.Text(dim['sqFt'].toString()),
                        padding: pw.EdgeInsets.all(4),
                      ),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 20),
              _buildAmountRow('Rate per Sq.ft:', 'Rs$rate'),
              _buildAmountRow('Total Sq.ft:', '$totalSqFt sq.ft'),
              _buildAmountRow('Additional Charges:', 'Rs$additionalCharges'),
              _buildAmountRow('Total Amount:', 'Rs$totalAmount'),
              _buildAmountRow('Advance:', 'Rs$advance'),
              _buildAmountRow('Remaining Balance:', 'Rs$remainingBalance',
                  isTotal: true),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('Thank you for your business!',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF to a temporary file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/inventory_${customerName}_$date.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 10),
        pw.Text(value),
      ],
    );
  }

  static pw.Widget _buildAmountRow(String label, String value, {bool isTotal = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
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

  static Future<void> printPdf(File pdfFile) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => await pdfFile.readAsBytes(),
    );
  }
}