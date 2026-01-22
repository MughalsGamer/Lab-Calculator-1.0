// pdf_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import 'Model class.dart';
import 'Party Model.dart';

class PdfService {
  // Color scheme - نیچے والے فائل کا ڈیزائن
  static final PdfColor _primaryColor = PdfColor.fromInt(0xFFFFA500); // Orange
  static final PdfColor _secondaryColor = PdfColor.fromInt(0xFF4A6572); // Dark Blue
  static final PdfColor _accentColor = PdfColor.fromInt(0xFF0D47A1); // Blue Accent
  static final PdfColor _lightBg = PdfColor.fromInt(0xFFF5F5F5);
  static final PdfColor _darkText = PdfColor.fromInt(0xFF263238);

  // Text styles
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

  // Load image as pw.Image widget - اوپر والے فائل سے
  static Future<pw.Image?> _loadImage(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      return pw.Image(pw.MemoryImage(bytes));
    } catch (e) {
      return null;
    }
  }

  // Table header cell - اوپر والے فائل سے
  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: _detailLabelStyle.copyWith(color: PdfColors.white),
      ),
    );
  }

  // Table data cell - اوپر والے فائل سے
  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
    );
  }

  // Build detail row - اوپر والے فائل سے
  static pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: _detailLabelStyle),
          pw.SizedBox(width: 10),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  // Build amount row - اوپر والے فائل سے
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

  // Build summary row - اوپر والے فائل سے
  static pw.Widget _buildPdfSummaryRow(String label, String value, {bool isHighlighted = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: isHighlighted ? _totalStyle : _detailLabelStyle),
          pw.Text(value, style: isHighlighted ? _totalStyle : null),
        ],
      ),
    );
  }

  // Build PDF section - اوپر والے فائل سے
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

  // نیچے والے فائل کا ڈیزائن سٹیٹ کارڈ
  static pw.Container _buildStatCard(String title, String value, PdfColor color) {
    return pw.Container(
      width: 100,
      height: 70,
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColors.grey300,
            blurRadius: 3,
          ),
        ],
      ),
      child: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Generate Inventory PDF ====================
  // اوپر والے فائل کا فنکشن نیچے والے فائل کے ڈیزائن میں
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
    final logo = await _loadImage('assets/images/logos.png');
    final currencyFormat = NumberFormat.currency(symbol: 'Rs', decimalDigits: 2);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 36,
          marginBottom: 36,
        ),
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            child: pw.Column(
              children: [
                if (logo != null)
                  pw.Container(
                    child: logo,
                    height: 60,
                  ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Project Details Report',
                  style: _headerStyle,
                ),
                pw.Divider(thickness: 1, height: 16),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated on: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // نیچے والے فائل کا سٹیٹ کارڈ ڈیزائن
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Report Date: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Amount', 'Rs $totalAmount', PdfColors.blue100),
                    _buildStatCard('Advance', 'Rs $advance', PdfColors.green100),
                    _buildStatCard('Balance', 'Rs $remainingBalance', PdfColors.orange100),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],
            ),

            // Party Information - اوپر والے فائل کا سیکشن
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: _lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PARTY INFORMATION', style: _sectionTitleStyle),
                  pw.Divider(color: _primaryColor, height: 1),
                  pw.SizedBox(height: 10),
                  _buildPdfDetailRow('Name:', customerName),
                  _buildPdfDetailRow('Phone:', phone),
                  _buildPdfDetailRow('Address:', address),
                  _buildPdfDetailRow('Date:', date),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Project Details
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: _lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PROJECT DETAILS', style: _sectionTitleStyle),
                  pw.Divider(color: _primaryColor, height: 1),
                  pw.SizedBox(height: 10),
                  _buildPdfDetailRow('Room:', room),
                  _buildPdfDetailRow('Material Type:', fileType),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Dimensions - اوپر والے فائل کا ٹیبل
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: _lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('DIMENSIONS', style: _sectionTitleStyle),
                  pw.Divider(color: _primaryColor, height: 1),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
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
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Financial Summary - اوپر والے فائل کا سیکشن
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: _lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('FINANCIAL SUMMARY', style: _sectionTitleStyle),
                  pw.Divider(color: _primaryColor, height: 1),
                  pw.SizedBox(height: 10),
                  _buildPdfAmountRow('Rate per Sq.ft:', 'Rs $rate'),
                  _buildPdfAmountRow('Total Area:', '$totalSqFt sq.ft'),
                  _buildPdfAmountRow('Additional Charges:', 'Rs $additionalCharges'),
                  _buildPdfAmountRow('Total Amount:', 'Rs $totalAmount'),
                  _buildPdfAmountRow('Advance:', 'Rs $advance'),
                  _buildPdfAmountRow('Remaining Balance:', 'Rs $remainingBalance', isTotal: true),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Center(
              child: pw.Text(
                'Thank you for choosing Graphics Lab!',
                style: pw.TextStyle(color: _primaryColor),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==================== Generate Party PDF ====================
  // اوپر والے فائل کا فنکشن نیچے والے فائل کے ڈیزائن میں
  static Future<Uint8List> generatePartyPdf({
    required PartyModel party,
    required List<CustomerModel> projects,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: 'Rs', decimalDigits: 2);
    final totalProjects = projects.length;
    final logo = await _loadImage('assets/images/logos.png');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 36,
          marginBottom: 36,
        ),
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            child: pw.Column(
              children: [
                if (logo != null)
                  pw.Container(
                    child: logo,
                    height: 60,
                  ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Party Report',
                  style: _headerStyle,
                ),
                pw.Divider(thickness: 1, height: 16),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated on: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // نیچے والے فائل کا سٹیٹ کارڈ ڈیزائن
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Report Period: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Projects', totalProjects.toString(), PdfColors.blue100),
                    _buildStatCard('Amount', currencyFormat.format(projects.fold(0.0, (sum, item) => sum + item.totalAmount)), PdfColors.green100),
                    _buildStatCard('Balance', currencyFormat.format(projects.fold(0.0, (sum, item) => sum + item.remainingBalance)), PdfColors.orange100),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],
            ),

            // Party Information - اوپر والے فائل کا ڈیزائن
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: _lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${party.type.toUpperCase()} DETAILS',
                    style: _titleStyle.copyWith(color: _accentColor),
                  ),
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

            // Summary - اوپر والے فائل کا سیکشن
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: _lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SUMMARY', style: _titleStyle.copyWith(color: _accentColor)),
                  pw.Divider(color: _primaryColor, height: 1.5),
                  pw.SizedBox(height: 10),
                  _buildPdfAmountRow('Total Inventory:', totalProjects.toString()),
                  _buildPdfAmountRow(
                    'Total Amount:',
                    currencyFormat.format(projects.fold(0.0, (sum, item) => sum + item.totalAmount)),
                  ),
                  _buildPdfAmountRow(
                    'Total Advance:',
                    currencyFormat.format(projects.fold(0.0, (sum, item) => sum + item.advance)),
                  ),
                  _buildPdfAmountRow(
                    'Total Remaining Balance:',
                    currencyFormat.format(projects.fold(0.0, (sum, item) => sum + item.remainingBalance)),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Projects List - اوپر والے فائل کا ڈیزائن
            pw.Text('PROJECTS LIST', style: _sectionTitleStyle),
            pw.SizedBox(height: 10),
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
                      pw.Text('Rs ${project.totalAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Balance:', style: _detailLabelStyle),
                      pw.Text(
                        'Rs ${project.remainingBalance.toStringAsFixed(2)}',
                        style: pw.TextStyle(color: _primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            )).toList(),
            pw.SizedBox(height: 30),
            pw.Center(
              child: pw.Text(
                'Thank you for choosing Graphics Lab!',
                style: pw.TextStyle(color: _primaryColor, fontSize: 16),
              ),
            )
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==================== Generate Party Projects PDF ====================
  // اوپر والے فائل کا فنکشن نیچے والے فائل کے ڈیزائن میں
  static Future<Uint8List> generatePartyProjectsPdf({
    required PartyModel party,
    required List<CustomerModel> projects,
  }) async {
    final pdf = pw.Document();
    final logo = await _loadImage('assets/images/logos.png');
    final currencyFormat = NumberFormat.currency(symbol: 'Rs', decimalDigits: 2);

    // Calculate totals - اوپر والے فائل کا کیلکولیشن
    double totalRoofSqFt = 0.0;
    double totalWallSqFt = 0.0;
    double totalRoofAmount = 0.0;
    double totalWallAmount = 0.0;
    double totalAdvance = 0.0;
    double totalRemaining = 0.0;

    for (var project in projects) {
      double projectRoofSqFt = 0.0;
      double projectWallSqFt = 0.0;

      for (var dim in project.dimensions) {
        String wallName = dim['wall']?.toString().toLowerCase() ?? '';
        double sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0.0;

        if (wallName.contains('roof')) {
          projectRoofSqFt += sqFt;
        } else {
          projectWallSqFt += sqFt;
        }
      }

      double roofAmount = projectRoofSqFt * project.rate;
      double wallAmount = projectWallSqFt * project.rate;

      totalRoofSqFt += projectRoofSqFt;
      totalWallSqFt += projectWallSqFt;
      totalRoofAmount += roofAmount;
      totalWallAmount += wallAmount;
      totalAdvance += project.advance;
      totalRemaining += project.remainingBalance;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 36,
          marginBottom: 36,
        ),
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            child: pw.Column(
              children: [
                if (logo != null)
                  pw.Container(
                    child: logo,
                    height: 60,
                  ),
                pw.SizedBox(height: 10),
                pw.Text(
                  '${party.name} - Detailed Report',
                  style: _headerStyle,
                ),
                pw.Divider(thickness: 1, height: 16),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          List<pw.Widget> projectWidgets = [];

          for (var project in projects) {
            double projectRoofSqFt = 0.0;
            double projectWallSqFt = 0.0;

            for (var dim in project.dimensions) {
              String wallName = dim['wall']?.toString().toLowerCase() ?? '';
              double sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0.0;

              if (wallName.contains('roof')) {
                projectRoofSqFt += sqFt;
              } else {
                projectWallSqFt += sqFt;
              }
            }

            projectWidgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(project.date, style: _detailLabelStyle),
                        pw.Text('Room: ${project.room}', style: _detailLabelStyle),
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
                    pw.SizedBox(height: 10),
                    pw.Text('Area Breakdown:', style: _detailLabelStyle.copyWith(color: _accentColor)),
                    pw.SizedBox(height: 8),
                    _buildPdfSummaryRow('Roof Area:', '${projectRoofSqFt.toStringAsFixed(2)} sq.ft'),
                    _buildPdfSummaryRow('Wall Area:', '${projectWallSqFt.toStringAsFixed(2)} sq.ft'),
                    pw.SizedBox(height: 8),
                    pw.Text('Dimensions:', style: _detailLabelStyle.copyWith(color: _accentColor)),
                    pw.SizedBox(height: 8),
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(1.5),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1),
                        3: const pw.FlexColumnWidth(1),
                        4: const pw.FlexColumnWidth(1),
                      },
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
                        ...project.dimensions.map((dim) => pw.TableRow(
                          children: [
                            _buildTableCell(dim['wall']?.toString() ?? ''),
                            _buildTableCell(dim['width']?.toString() ?? ''),
                            _buildTableCell(dim['height']?.toString() ?? ''),
                            _buildTableCell(dim['quantity']?.toString() ?? ''),
                            _buildTableCell(dim['sqFt']?.toString() ?? ''),
                          ],
                        )).toList(),
                      ],
                    ),
                    pw.SizedBox(height: 15),
                    _buildPdfSummaryRow('Rate per sq.ft:', currencyFormat.format(project.rate)),
                    _buildPdfSummaryRow('Additional Charges:', currencyFormat.format(project.additionalCharges)),
                    _buildPdfSummaryRow('Advance:', currencyFormat.format(project.advance)),
                    _buildPdfSummaryRow('Total Amount:', currencyFormat.format(project.totalAmount)),
                    _buildPdfSummaryRow('Remaining Balance:', currencyFormat.format(project.remainingBalance), isHighlighted: true),
                  ],
                ),
              ),
            );
          }

          return [
            // Party Information
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: _lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PARTY INFORMATION', style: _sectionTitleStyle),
                  pw.Divider(color: _primaryColor, height: 1),
                  pw.SizedBox(height: 10),
                  _buildPdfDetailRow('Name:', party.name),
                  _buildPdfDetailRow('Type:', party.type.toUpperCase()),
                  _buildPdfDetailRow('Phone:', party.phone),
                  _buildPdfDetailRow('Address:', party.address),
                  _buildPdfDetailRow('Created:', party.date),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // نیچے والے فائل کا سٹیٹ کارڈ ڈیزائن
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Projects', projects.length.toString(), PdfColors.blue100),
                _buildStatCard('Advance', currencyFormat.format(totalAdvance), PdfColors.green100),
                _buildStatCard('Balance', currencyFormat.format(totalRemaining), PdfColors.orange100),
              ],
            ),
            pw.SizedBox(height: 20),

            // Summary - اوپر والے فائل کا سیکشن
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: _lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SUMMARY', style: _sectionTitleStyle),
                  pw.Divider(color: _primaryColor, height: 1),
                  pw.SizedBox(height: 10),
                  _buildPdfSummaryRow('Total Inventory:', projects.length.toString()),
                  _buildPdfSummaryRow('Roofs Square Feet:', totalRoofSqFt.toStringAsFixed(2)),
                  _buildPdfSummaryRow('Walls Square Feet:', totalWallSqFt.toStringAsFixed(2)),
                  _buildPdfSummaryRow('Roof Amount:', currencyFormat.format(totalRoofAmount)),
                  _buildPdfSummaryRow('Walls Amount:', currencyFormat.format(totalWallAmount)),
                  _buildPdfSummaryRow('Total Advance:', currencyFormat.format(totalAdvance)),
                  _buildPdfSummaryRow('Total Remaining:', currencyFormat.format(totalRemaining), isHighlighted: true),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Text('INVENTORY DETAILS', style: _sectionTitleStyle),
            pw.SizedBox(height: 10),
            ...projectWidgets,
            pw.SizedBox(height: 30),
            pw.Center(
              child: pw.Text(
                'End of Report',
                style: pw.TextStyle(color: _primaryColor, fontSize: 16),
              ),
            )
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==================== نیچے والے فائل کے اضافی فنکشنز ====================

  // Save PDF to Device
  static Future<String> savePdf(Uint8List pdfBytes, String fileName) async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final file = File('${directory!.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      return file.path;
    } catch (e) {
      rethrow;
    }
  }

  // Print PDF - اوپر والے فائل کا فنکشن
  static Future<void> printPdf({
    required Uint8List pdfBytes,
    BuildContext? context,
  }) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Handle PDF Actions - اوپر والے فائل کا فنکشن نیچے والے فائل کے options کے ساتھ
  static Future<void> handlePdfActions({
    required BuildContext context,
    required Future<Uint8List> Function() generatePdf,
    required String fileName,
  }) async {
    // Show options dialog - نیچے والے فائل کا ڈائیلاگ
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('PDF Options', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.print, color: Colors.orange),
              title: const Text('Print PDF', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context, 'print');
              },
            ),
            ListTile(
              leading: const Icon(Icons.save, color: Colors.green),
              title: const Text('Save PDF', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context, 'save');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share PDF', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context, 'share');
              },
            ),
          ],
        ),
      ),
    );

    if (action == null) return;

    // Show loading - اوپر والے فائل کا لوڈنگ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );

    try {
      final pdfBytes = await generatePdf();

      if (action == 'print') {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: fileName,
        );
        if (context.mounted) Navigator.pop(context); // Close loading
      }
      else if (action == 'save') {
        try {
          // Save PDF
          final filePath = await savePdf(pdfBytes, fileName);

          if (context.mounted) {
            Navigator.pop(context); // Close loading

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF saved successfully: $fileName'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );

            // Open the saved PDF
            await OpenFile.open(filePath);
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context); // Close loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save PDF: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
      else if (action == 'share') {
        try {
          final output = await getTemporaryDirectory();
          final file = File('${output.path}/$fileName');
          await file.writeAsBytes(pdfBytes);

          await Share.shareXFiles(
            [XFile(file.path)],
            subject: 'Party Report - ${DateFormat('MMM yyyy').format(DateTime.now())}',
            text: 'Attached is your party report.',
          );

          if (context.mounted) Navigator.pop(context); // Close loading
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context); // Close loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to share PDF: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}