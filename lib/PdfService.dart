// pdf_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'Model class.dart';
import 'Party Model.dart';
import 'PartyWithProjects.dart';

class PdfService {
  // Color scheme
  static final PdfColor _primaryColor = PdfColor.fromInt(0xFFFFA500);
  static final PdfColor _secondaryColor = PdfColor.fromInt(0xFF4A6572);
  static final PdfColor _accentColor = PdfColor.fromInt(0xFF0D47A1);
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

  // Load image as pw.Image widget
  static Future<pw.Image?> _loadImage(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      return pw.Image(pw.MemoryImage(bytes));
    } catch (e) {
      return null;
    }
  }

  // Build project content
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
      ]),
      pw.SizedBox(height: 20),
      _buildPdfSection('Specifications', [
        _buildPdfDetailRow('Room:', room),
        _buildPdfDetailRow('Material Type:', fileType),
      ]),
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
        _buildPdfAmountRow('Rate per Sq.ft:', 'Rs $rate'),
        _buildPdfAmountRow('Total Area:', '$totalSqFt sq.ft'),
        _buildPdfAmountRow('Additional Charges:', 'Rs $additionalCharges'),
        _buildPdfAmountRow('Total Amount:', 'Rs $totalAmount'),
        _buildPdfAmountRow('Advance:', 'Rs $advance'),
        _buildPdfAmountRow('Remaining Balance:', 'Rs $remainingBalance', isTotal: true),
      ]),
      pw.SizedBox(height: 30),
      pw.Center(
        child: pw.Text(
          'Thank you for choosing Graphics Lab!',
          style: pw.TextStyle(color: _primaryColor),
        ),
      )
    ];
  }

  // Table header cell
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

  // Table data cell
  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
    );
  }

  // Build PDF section
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

  // Build detail row
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

  // Build amount row
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

  // Build summary row
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

  // ==================== Generate Inventory PDF ====================
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
                  if (logo != null)
                    pw.Container(
                      child: logo,
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
                      pw.Text(
                        'From Designing To Printing, Exactly According To Your Idea',
                        style: pw.TextStyle(color: _secondaryColor),
                      ),
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

    return pdf.save();
  }

  // ==================== Generate Party PDF ====================
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
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    if (logo != null)
                      pw.Container(
                        child: logo,
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
                        pw.Text(
                          'From Designing To Printing, Exactly According To Your Idea',
                          style: pw.TextStyle(color: _secondaryColor),
                        ),
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
              ],
            )
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==================== Generate Party Projects PDF ====================
  static Future<Uint8List> generatePartyProjectsPdf({
    required PartyModel party,
    required List<CustomerModel> projects,
  }) async {
    final pdf = pw.Document();
    final logo = await _loadImage('assets/images/logos.png');
    final currencyFormat = NumberFormat.currency(symbol: 'Rs', decimalDigits: 2);

    // Calculate totals
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
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
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
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    if (logo != null)
                      pw.Container(
                        child: logo,
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
                        pw.Text(
                          '${party.name} - Report',
                          style: pw.TextStyle(color: _secondaryColor),
                        ),
                        pw.Text(
                          'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    )
                  ],
                ),
                pw.SizedBox(height: 30),
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
              ],
            )
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==================== Print PDF ====================
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

  // ==================== Handle PDF Actions ====================
  static Future<void> handlePdfActions({
    required BuildContext context,
    required Future<Uint8List> Function() generatePdf,
    required String fileName,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );

    try {
      final pdfBytes = await generatePdf();
      Navigator.pop(context);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: fileName,
      );
    } catch (e) {
      Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }
}