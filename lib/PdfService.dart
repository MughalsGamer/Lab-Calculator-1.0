import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

import 'Model class.dart';
import 'ListOfPartiesScreen.dart';

class PdfService {
  static final PdfColor _primaryColor = PdfColor.fromInt(0xFFFFA500);
  static final PdfColor _secondaryColor = PdfColor.fromInt(0xFF4A6572);
  static final PdfColor _accentColor = PdfColor.fromInt(0xFF0D47A1);
  static final PdfColor _lightBg = PdfColor.fromInt(0xFFF5F5F5);
  static final PdfColor _darkText = PdfColor.fromInt(0xFF263238);

  static pw.TextStyle get _headerStyle => pw.TextStyle(
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: _primaryColor,
  );

  static pw.TextStyle get _titleStyle => pw.TextStyle(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
    color: _secondaryColor,
  );

  static pw.TextStyle get _sectionTitleStyle => pw.TextStyle(
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
    color: _accentColor,
  );

  static pw.TextStyle get _detailLabelStyle => pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    color: _darkText,
  );

  static pw.TextStyle get _totalStyle => pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    color: _primaryColor,
    fontSize: 16,
  );

  static List<pw.Widget> _buildProjectContent(
      String customerName,
      String phone,
      String address,
      String date,
      String room,
      String fileType,
      String rate,
      String additionalCharges,
      String advance,
      String totalSqFt,
      String totalAmount,
      String remainingBalance,
      List<Map<String, dynamic>> dimensions,
      ) {
    return [
      pw.Container(
          child: pw.Text('Details', style: _titleStyle),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _lightBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
       ),
      pw.SizedBox(height: 15),
      _buildPdfSection('Party Information', [
        _buildPdfDetailRow('Name:', customerName),
        _buildPdfDetailRow('Phone:', phone),
        _buildPdfDetailRow('Address:', address),
        _buildPdfDetailRow('Date:', date),
      ]
      ),
      pw.SizedBox(height: 20),
      _buildPdfSection('Specifications', [
        _buildPdfDetailRow('Room:', room),
        _buildPdfDetailRow('Material Type:', fileType),
      ]
      ),
      pw.SizedBox(height: 20),
      _buildPdfSection('Dimensions', [
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: _secondaryColor),
              children: [
                _buildTableHeaderCell('Wall'),
                _buildTableHeaderCell('Width'),
                _buildTableHeaderCell('Height'),
                _buildTableHeaderCell('Qty'),
                _buildTableHeaderCell('Sq.Ft'),
              ],
            ),
            for (var dim in dimensions)
              pw.TableRow(
                children: [
                  _buildTableCell(dim['wall']?.toString() ?? 'N/A'),
                  _buildTableCell(dim['width']?.toString() ?? '0'),
                  _buildTableCell(dim['height']?.toString() ?? '0'),
                  _buildTableCell(dim['quantity']?.toString() ?? '1'),
                  _buildTableCell(dim['sqFt']?.toString() ?? '0'),
                ],
              ),
          ],
        ),
      ]),
      pw.SizedBox(height: 20),
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
        child: pw.Text('Thank you for choosing Graphics Lab!',
            style: pw.TextStyle(
                fontStyle: pw.FontStyle.italic,
                color: _primaryColor)),
      )
    ];
  }

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text,
          style: _detailLabelStyle.copyWith(color: PdfColors.white),
        ));
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
    );
  }

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
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await pw.Font.ttf(await rootBundle.load("assets/fonts/OpenSans-Regular.ttf")),
        bold: await pw.Font.ttf(await rootBundle.load("assets/fonts/OpenSans-Bold.ttf")),
      ),
    );

    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        header: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    child: pw.Image(logoImage),
                    width: 60,
                    height: 60,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: _primaryColor, width: 2),
                    ),
                  ),
                  pw.SizedBox(width: 15),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Graphics Lab', style: _headerStyle),
                      pw.Text('From Designing To Printing, Exactly According To Your Idea',
                          style: pw.TextStyle(color: _secondaryColor)),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(color: PdfColors.grey),
          ),
        ),
        build: (context) => _buildProjectContent(
          customerName,
          phone,
          address,
          date,
          room,
          fileType,
          rate,
          additionalCharges,
          advance,
          totalSqFt,
          totalAmount,
          remainingBalance,
          dimensions,
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${customerName}_$date.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<File> generatePartyPdf({
    required PartyModel party,
    required List<CustomerModel> projects,
  }) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await pw.Font.ttf(await rootBundle.load("assets/fonts/OpenSans-Regular.ttf")),
        bold: await pw.Font.ttf(await rootBundle.load("assets/fonts/OpenSans-Bold.ttf")),
      ),
    );

    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          final currencyFormat = NumberFormat.currency(symbol: 'Rs', decimalDigits: 2);
          final totalProjects = projects.length;

          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      child: pw.Image(logoImage),
                      width: 60,
                      height: 60,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: _primaryColor, width: 2),
                      ),
                    ),
                    pw.SizedBox(width: 15),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Graphics Lab', style: _headerStyle),
                        pw.Text('From Designing To Printing, Exactly According To Your Idea',
                            style: pw.TextStyle(color: _secondaryColor)),
                      ],
                    )
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: _lightBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${party.type.toUpperCase()} DETAILS',
                          style: _titleStyle.copyWith(color: _accentColor)),
                      pw.Divider(color: _primaryColor, height: 1.5),
                      pw.SizedBox(height: 10),
                      _buildPdfDetailRow('Name:', party.name),
                      _buildPdfDetailRow('Phone:', party.phone),
                      _buildPdfDetailRow('Address:', party.address),
                      _buildPdfDetailRow('Date:', DateFormat('dd MMM yyyy').format(DateTime.now())),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: _lightBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PROJECTS SUMMARY',
                          style: _titleStyle.copyWith(color: _accentColor)),
                      pw.Divider(color: _primaryColor, height: 1.5),
                      pw.SizedBox(height: 10),
                      _buildPdfAmountRow('Total Projects:', totalProjects.toString()),
                      _buildPdfAmountRow('Total Amount:', currencyFormat.format(projects.fold(0.0, (sum, item) => sum + (item.totalAmount)))),
                      _buildPdfAmountRow('Total Advance:', currencyFormat.format(projects.fold(0.0, (sum, item) => sum + (item.advance)))),
                      _buildPdfAmountRow('Total Remaining Balance:', currencyFormat.format(projects.fold(0.0, (sum, item) => sum + (item.remainingBalance))), isTotal: true),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                ...projects.map((project) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(project.date, style: _detailLabelStyle),
                          pw.Text('Room: ${project.room}'),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Material:', style: _detailLabelStyle),
                          pw.Text(project.fileType),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Amount:', style: _detailLabelStyle),
                          pw.Text('Rs${project.totalAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Balance:', style: _detailLabelStyle),
                          pw.Text('Rs${project.remainingBalance.toStringAsFixed(2)}',
                              style: pw.TextStyle(color: _primaryColor)),
                        ],
                      ),
                    ],
                  ),
                )).toList(),
                pw.SizedBox(height: 30),
                pw.Center(
                  child: pw.Text('Thank you for choosing Graphics Lab!',
                      style: pw.TextStyle(
                          fontStyle: pw.FontStyle.italic,
                          color: _primaryColor,
                          fontSize: 16)),
                )
              ],
            )];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${party.name}_projects.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildPdfSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: _sectionTitleStyle),
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
          pw.Text(label, style: _detailLabelStyle),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfAmountRow(String label, String value, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: isTotal ? _totalStyle : _detailLabelStyle),
          pw.Text(value, style: isTotal ? _totalStyle : null),
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