// pdf_service.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'Model class.dart';
import 'Party Model.dart';

class PdfService {
  // Simplified color scheme for better performance
  static final PdfColor _primaryColor = PdfColor.fromInt(0xFFFFA500);
  static final PdfColor _lightBg = PdfColor.fromInt(0xFFF5F5F5);

  // Simple text styles
  static pw.TextStyle get _headerStyle => pw.TextStyle(
    fontSize: 20,
    fontWeight: pw.FontWeight.bold,
  );

  static pw.TextStyle get _sectionStyle => pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
  );

  // Fast table cell builder
  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  // Simple row builder
  static pw.Widget _buildRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text('$label: ', style:  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(value),
      ],
    );
  }

  // ==================== Fast Generate Inventory PDF ====================
  static Future<Uint8List> generateInventoryPdf({
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

    // Use minimal styling for performance
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text('Project Report', style: _headerStyle),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Customer Info
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Customer Information', style: _sectionStyle),
                    pw.SizedBox(height: 8),
                    _buildRow('Name', customerName),
                    _buildRow('Phone', phone),
                    _buildRow('Address', address),
                    _buildRow('Date', date),
                    _buildRow('Room', room),
                    _buildRow('Material', fileType),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Dimensions Table
              pw.Text('Dimensions', style: _sectionStyle),
              pw.SizedBox(height: 5),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Wall'),
                      _buildTableCell('Width'),
                      _buildTableCell('Height'),
                      _buildTableCell('Sq.Ft'),
                    ],
                  ),
                  ...dimensions.map((dim) => pw.TableRow(
                    children: [
                      _buildTableCell(dim['wall']?.toString() ?? ''),
                      _buildTableCell(dim['width']?.toString() ?? ''),
                      _buildTableCell(dim['height']?.toString() ?? ''),
                      _buildTableCell(dim['sqFt']?.toString() ?? ''),
                    ],
                  )).toList(),
                ],
              ),
              pw.SizedBox(height: 15),

              // Financial Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Financial Summary', style: _sectionStyle),
                    pw.SizedBox(height: 8),
                    _buildRow('Total Area', '$totalSqFt sq.ft'),
                    _buildRow('Rate per Sq.ft', 'Rs $rate'),
                    _buildRow('Additional Charges', 'Rs $additionalCharges'),
                    _buildRow('Total Amount', 'Rs $totalAmount'),
                    _buildRow('Advance', 'Rs $advance'),
                    pw.Divider(),
                    pw.Row(
                      children: [
                        pw.Text('Remaining Balance: ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primaryColor)),
                        pw.Text('Rs $remainingBalance',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Generated on ${DateFormat('dd-MMM-yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ==================== Fast Generate Party PDF ====================
  static Future<Uint8List> generatePartyPdf({
    required PartyModel party,
    required List<CustomerModel> projects,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          double totalAmount = projects.fold(0.0, (sum, item) => sum + item.totalAmount);
          double totalAdvance = projects.fold(0.0, (sum, item) => sum + item.advance);
          double totalBalance = projects.fold(0.0, (sum, item) => sum + item.remainingBalance);

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('${party.type} Report - ${party.name}', style: _headerStyle),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Party Info
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Party Information', style: _sectionStyle),
                    pw.SizedBox(height: 8),
                    _buildRow('Name', party.name),
                    _buildRow('Phone', party.phone),
                    _buildRow('Address', party.address),
                    _buildRow('Type', party.type),
                    _buildRow('Total Projects', projects.length.toString()),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Summary', style: _sectionStyle),
                    pw.SizedBox(height: 8),
                    _buildRow('Total Amount', 'Rs ${totalAmount.toStringAsFixed(2)}'),
                    _buildRow('Total Advance', 'Rs ${totalAdvance.toStringAsFixed(2)}'),
                    pw.Divider(),
                    pw.Row(
                      children: [
                        pw.Text('Total Balance: ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primaryColor)),
                        pw.Text('Rs ${totalBalance.toStringAsFixed(2)}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Projects List
              if (projects.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Projects', style: _sectionStyle),
                    pw.SizedBox(height: 5),
                    ...projects.map((project) => pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 8),
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildRow('Date', project.date),
                          _buildRow('Room', project.room),
                          _buildRow('Amount', 'Rs ${project.totalAmount.toStringAsFixed(2)}'),
                          _buildRow('Balance', 'Rs ${project.remainingBalance.toStringAsFixed(2)}'),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Generated on ${DateFormat('dd-MMM-yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ==================== FAST SAVE AND OPEN PDF ====================
  static Future<void> saveAndOpenPdf({
    required BuildContext context,
    required Future<Uint8List> Function() generatePdf,
    required String fileName,
  }) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );

      // Generate PDF
      final pdfBytes = await generatePdf();

      // Get directory
      Directory directory;
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create file path
      final filePath = '${directory.path}/$fileName.pdf';
      final file = File(filePath);

      // Save file
      await file.writeAsBytes(pdfBytes);

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Open file
      await OpenFile.open(filePath);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ==================== Quick Save Only (without opening) ====================
  static Future<String?> savePdfOnly({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      Directory directory;
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          return null;
        }
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory.path}/$fileName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }
}