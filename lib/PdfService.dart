// pdf_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional imports
import 'dart:io' if (dart.library.io) 'dart:io';
import 'dart:html' if (dart.library.html) 'dart:html' as html;

import 'Model class.dart';
import 'Party Model.dart';

class PdfService {
  // Company details
  static const String companyName = 'Graphics Lab';
  static const String companyAddress = 'Karachi, Pakistan';
  static const String companyPhone = '+92 300 1234567';
  static const String companyEmail = 'info@graphicslab.com';

  // Color scheme
  static final PdfColor _primaryColor = PdfColor.fromInt(0xFFFFA500); // Orange
  static final PdfColor _secondaryColor = PdfColor.fromInt(0xFF4A6572); // Dark Blue
  static final PdfColor _accentColor = PdfColor.fromInt(0xFF0D47A1); // Blue Accent
  static final PdfColor _lightBg = PdfColor.fromInt(0xFFF5F5F5);
  static final PdfColor _darkText = PdfColor.fromInt(0xFF263238);
  static final PdfColor _successColor = PdfColor.fromInt(0xFF4CAF50);
  static final PdfColor _warningColor = PdfColor.fromInt(0xFFFF9800);

  // Text styles
  static pw.TextStyle get _companyHeaderStyle => pw.TextStyle(
    fontSize: 28,
    fontWeight: pw.FontWeight.bold,
    color: _primaryColor,
  );

  static pw.TextStyle get _reportTitleStyle => pw.TextStyle(
    fontSize: 22,
    fontWeight: pw.FontWeight.bold,
    color: _secondaryColor,
  );

  static pw.TextStyle get _sectionTitleStyle => pw.TextStyle(
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
    color: _accentColor,
  );

  static pw.TextStyle get _subtitleStyle => pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: _darkText,
  );

  static pw.TextStyle get _labelStyle => pw.TextStyle(
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
    color: _darkText,
  );

  static pw.TextStyle get _valueStyle => pw.TextStyle(
    fontSize: 11,
    color: _darkText,
  );

  static pw.TextStyle get _totalStyle => pw.TextStyle(
    fontSize: 12,
    fontWeight: pw.FontWeight.bold,
    color: _primaryColor,
  );

  static pw.TextStyle get _amountStyle => pw.TextStyle(
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
    color: _accentColor,
  );

  // ==================== Company Header Widget ====================
  static pw.Widget _buildCompanyHeader() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        children: [
          // Company Name
          pw.Text(
            companyName,
            style: _companyHeaderStyle,
            textAlign: pw.TextAlign.center,
          ),

          // Company Details
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 5),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  companyAddress,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  '•',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey400,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  companyPhone,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  '•',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey400,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  companyEmail,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(vertical: 10),
            height: 2,
            color: _primaryColor,
          ),
        ],
      ),
    );
  }

  // ==================== Report Footer ====================
  static pw.Widget _buildReportFooter() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _lightBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for choosing $companyName!',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'For any queries, please contact us at $companyPhone or $companyEmail',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== Section Container ====================
  static pw.Container _buildSectionContainer(String title, pw.Widget child) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(
              title,
              style: _sectionTitleStyle,
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _lightBg,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  // ==================== Information Row ====================
  static pw.Row _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: isTotal ? _totalStyle : _labelStyle,
        ),
        pw.Text(
          value,
          style: isTotal ? _totalStyle : _valueStyle,
        ),
      ],
    );
  }

  // ==================== Financial Row ====================
  static pw.Row _buildFinancialRow(String label, String value, {bool isTotal = false, bool isRemaining = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: isTotal ? _totalStyle : _labelStyle,
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isTotal ? 12 : 11,
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isRemaining ? _primaryColor : (isTotal ? _accentColor : _darkText),
          ),
        ),
      ],
    );
  }

  // ==================== Dimensions Table ====================
  static pw.Widget _buildDimensionsTable(List<Map<String, dynamic>> dimensions) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 0.5,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.8), // Wall
        1: const pw.FlexColumnWidth(1.2), // Width
        2: const pw.FlexColumnWidth(1.2), // Height
        3: const pw.FlexColumnWidth(0.8), // Qty
        4: const pw.FlexColumnWidth(1.2), // Sq.Ft
        5: const pw.FlexColumnWidth(1.5), // Area (W×H)
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: _secondaryColor,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(4),
              topRight: pw.Radius.circular(4),
            ),
          ),
          children: [
            _buildTableHeaderCell('Wall Name'),
            _buildTableHeaderCell('Width (ft)'),
            _buildTableHeaderCell('Height (ft)'),
            _buildTableHeaderCell('Qty'),
            _buildTableHeaderCell('Sq. Ft'),
            _buildTableHeaderCell('Area (W×H)'),
          ],
        ),

        // Table Rows
        ...dimensions.map((dim) {
          final width = double.tryParse(dim['width']?.toString() ?? '0') ?? 0;
          final height = double.tryParse(dim['height']?.toString() ?? '0') ?? 0;
          final quantity = int.tryParse(dim['quantity']?.toString() ?? '1') ?? 1;
          final area = width * height;
          final sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: dimensions.indexOf(dim) % 2 == 0
                  ? PdfColors.white
                  : PdfColors.grey50,
            ),
            children: [
              _buildTableCell(dim['wall']?.toString() ?? 'N/A', isHeader: false),
              _buildTableCell(width.toStringAsFixed(2), isHeader: false),
              _buildTableCell(height.toStringAsFixed(2), isHeader: false),
              _buildTableCell(quantity.toString(), isHeader: false),
              _buildTableCell(sqFt.toStringAsFixed(2), isHeader: false),
              _buildTableCell('${area.toStringAsFixed(2)} sq.ft', isHeader: false),
            ],
          );
        }).toList(),

        // Total Row
        if (dimensions.isNotEmpty)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: _lightBg,
            ),
            children: [
              _buildTableCell('TOTAL', isHeader: true),
              _buildTableCell('', isHeader: false),
              _buildTableCell('', isHeader: false),
              _buildTableCell('', isHeader: false),
              _buildTableCell(
                dimensions.fold(0.0, (sum, dim) {
                  final sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0;
                  return sum + sqFt;
                }).toStringAsFixed(2),
                isHeader: true,
              ),
              _buildTableCell('', isHeader: false),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style:  pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? _accentColor : _darkText,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // ==================== Payment History Table ====================
  static pw.Widget _buildPaymentHistoryTable(List<Map<String, dynamic>> paymentHistory) {
    if (paymentHistory.isEmpty) {
      return pw.Text(
        'No payment history available',
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 0.5,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5), // Date
        1: const pw.FlexColumnWidth(1.2), // Time
        2: const pw.FlexColumnWidth(1.5), // Amount
        3: const pw.FlexColumnWidth(1.5), // Balance After
        4: const pw.FlexColumnWidth(1.3), // Type
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: _secondaryColor,
          ),
          children: [
            _buildTableHeaderCell('Date'),
            _buildTableHeaderCell('Time'),
            _buildTableHeaderCell('Amount (Rs)'),
            _buildTableHeaderCell('Balance After'),
            _buildTableHeaderCell('Type'),
          ],
        ),

        // Table Rows
        ...paymentHistory.map((payment) {
          final amount = (payment['amount'] as num?)?.toDouble() ?? 0;
          final remaining = (payment['remainingAfter'] as num?)?.toDouble() ?? 0;
          final isFullyPaid = remaining <= 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: paymentHistory.indexOf(payment) % 2 == 0
                  ? PdfColors.white
                  : PdfColors.grey50,
            ),
            children: [
              _buildTableCell(payment['date']?.toString() ?? '', isHeader: false),
              _buildTableCell(payment['time']?.toString() ?? '', isHeader: false),
              _buildTableCell(
                'Rs ${amount.toStringAsFixed(2)}',
                isHeader: false,
              ),
              _buildTableCell(
                'Rs ${remaining.toStringAsFixed(2)}',
                isHeader: false,
              ),
              _buildTableCell(
                payment['type']?.toString().replaceAll('_', ' ') ?? '',
                isHeader: false,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // ==================== Single Project PDF ====================
  static Future<Uint8List> generateProjectDetailPdf({
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
    required List<Map<String, dynamic>> paymentHistory,
  }) async {
    final pdf = pw.Document();

    // Calculate totals
    final totalSqFtNum = double.tryParse(totalSqFt) ?? 0;
    final rateNum = double.tryParse(rate) ?? 0;
    final additionalNum = double.tryParse(additionalCharges) ?? 0;
    final advanceNum = double.tryParse(advance) ?? 0;
    final totalAmountNum = double.tryParse(totalAmount) ?? 0;
    final remainingNum = double.tryParse(remainingBalance) ?? 0;

    // Calculate total from dimensions
    final calculatedTotalSqFt = dimensions.fold(0.0, (sum, dim) {
      final sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0;
      return sum + sqFt;
    });

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Company Header
              _buildCompanyHeader(),

              // Report Title
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Center(
                  child: pw.Text(
                    'PROJECT DETAILED REPORT',
                    style: _reportTitleStyle,
                  ),
                ),
              ),

              // Report Info
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Report Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'Project ID: ${DateFormat('yyyyMMdd').format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),

              // Party Information Section
              _buildSectionContainer(
                'PARTY INFORMATION',
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Customer Name:', customerName),
                    pw.SizedBox(height: 4),
                    _buildInfoRow('Phone Number:', phone),
                    pw.SizedBox(height: 4),
                    _buildInfoRow('Address:', address),
                    pw.SizedBox(height: 4),
                    _buildInfoRow('Project Date:', date),
                  ],
                ),
              ),

              // Project Details Section
              _buildSectionContainer(
                'PROJECT DETAILS',
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Room:', room),
                    pw.SizedBox(height: 4),
                    _buildInfoRow('Material Type:', fileType),
                    pw.SizedBox(height: 4),
                    _buildInfoRow('Project Status:', remainingNum <= 0 ? 'Paid' : 'Pending'),
                  ],
                ),
              ),

              // Dimensions Section
              _buildSectionContainer(
                'DIMENSIONS DETAIL',
                _buildDimensionsTable(dimensions),
              ),

              // Financial Summary Section
              _buildSectionContainer(
                'FINANCIAL SUMMARY',
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildFinancialRow('Rate per Sq. Ft:', 'Rs ${rateNum.toStringAsFixed(2)}'),
                              pw.SizedBox(height: 4),
                              _buildFinancialRow('Total Area:', '${calculatedTotalSqFt.toStringAsFixed(2)} sq.ft'),
                              pw.SizedBox(height: 4),
                              _buildFinancialRow('Additional Charges:', 'Rs ${additionalNum.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            margin: const pw.EdgeInsets.only(left: 10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildFinancialRow('Base Amount:', 'Rs ${(calculatedTotalSqFt * rateNum).toStringAsFixed(2)}'),
                                pw.SizedBox(height: 4),
                                _buildFinancialRow('Total Amount:', 'Rs $totalAmount', isTotal: true),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    pw.Divider(color: PdfColors.grey300, height: 15),

                    pw.Container(
                      decoration: pw.BoxDecoration(
                        color: remainingNum <= 0 ? PdfColors.green50 : PdfColors.orange50,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        border: pw.Border.all(
                          color: remainingNum <= 0 ? _successColor : _warningColor,
                          width: 1,
                        ),
                      ),
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Column(
                        children: [
                          _buildFinancialRow(
                            'Advance Payment:',
                            'Rs ${advanceNum.toStringAsFixed(2)}',
                          ),
                          pw.SizedBox(height: 6),
                          _buildFinancialRow(
                            'Remaining Balance:',
                            'Rs ${remainingNum.toStringAsFixed(2)}',
                            isRemaining: true,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Payment History Section
              _buildSectionContainer(
                'PAYMENT HISTORY',
                _buildPaymentHistoryTable(paymentHistory),
              ),

              // Footer
              _buildReportFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ==================== Party Projects PDF ====================
  static Future<Uint8List> generatePartyProjectsPdf({
    required PartyModel party,
    required List<CustomerModel> projects,
  }) async {
    final pdf = pw.Document();

    // Calculate totals
    double totalProjects = projects.length.toDouble();
    double totalAmount = projects.fold(0.0, (sum, item) => sum + item.totalAmount);
    double totalAdvance = projects.fold(0.0, (sum, item) => sum + item.advance);
    double totalRemaining = projects.fold(0.0, (sum, item) => sum + item.remainingBalance);
    double totalSqFt = projects.fold(0.0, (sum, item) => sum + item.totalSqFt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Company Header
              _buildCompanyHeader(),

              // Report Title
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Center(
                  child: pw.Text(
                    '${party.type.toUpperCase()} PROJECTS REPORT',
                    style: _reportTitleStyle,
                  ),
                ),
              ),

              // Report Info
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Report Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'Party ID: ${party.id.substring(0, 8)}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),

              // Party Information Section
              _buildSectionContainer(
                '${party.type.toUpperCase()} INFORMATION',
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('${party.type} Name:', party.name),
                    pw.SizedBox(height: 4),
                    _buildInfoRow('Phone Number:', party.phone),
                    pw.SizedBox(height: 4),
                    _buildInfoRow('Address:', party.address),
                    pw.SizedBox(height: 4),
                    _buildInfoRow('Registration Date:', party.date),
                  ],
                ),
              ),

              // Summary Section
              _buildSectionContainer(
                'SUMMARY OVERVIEW',
                pw.Row(
                  children: [
                    // Summary Cards
                    pw.Expanded(
                      child: _buildSummaryCard(
                        'Total Projects',
                        totalProjects.toStringAsFixed(0),
                        PdfColors.blue100,
                        Icons.account_balance_wallet,
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: _buildSummaryCard(
                        'Total Area',
                        '${totalSqFt.toStringAsFixed(2)} sq.ft',
                        PdfColors.green100,
                        Icons.aspect_ratio,
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: _buildSummaryCard(
                        'Total Amount',
                        'Rs ${totalAmount.toStringAsFixed(2)}',
                        PdfColors.orange100,
                        Icons.attach_money,
                      ),
                    ),
                  ],
                ),
              ),

              // Financial Summary Section
              _buildSectionContainer(
                'FINANCIAL SUMMARY',
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildFinancialCard(
                            'Total Advance',
                            'Rs ${totalAdvance.toStringAsFixed(2)}',
                            PdfColors.green,
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          child: _buildFinancialCard(
                            'Remaining Balance',
                            'Rs ${totalRemaining.toStringAsFixed(2)}',
                            totalRemaining <= 0 ? PdfColors.green : PdfColors.orange,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: totalRemaining <= 0 ? PdfColors.green50 : PdfColors.orange50,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        border: pw.Border.all(
                          color: totalRemaining <= 0 ? _successColor : _warningColor,
                          width: 1,
                        ),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          totalRemaining <= 0
                              ? '✓ FULLY PAID - NO OUTSTANDING BALANCE'
                              : '⚠ PENDING BALANCE - Rs ${totalRemaining.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: totalRemaining <= 0 ? _successColor : _warningColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Projects List Section
              _buildSectionContainer(
                'PROJECTS LIST',
                _buildProjectsTable(projects),
              ),

              // Footer
              _buildReportFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ==================== Projects Table ====================
  static pw.Widget _buildProjectsTable(List<CustomerModel> projects) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 0.5,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2), // Date
        1: const pw.FlexColumnWidth(1.5), // Room
        2: const pw.FlexColumnWidth(1.5), // Material
        3: const pw.FlexColumnWidth(1.2), // Area
        4: const pw.FlexColumnWidth(1.5), // Total Amount
        5: const pw.FlexColumnWidth(1.5), // Advance
        6: const pw.FlexColumnWidth(1.5), // Balance
        7: const pw.FlexColumnWidth(1.0), // Status
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: _secondaryColor,
          ),
          children: [
            _buildTableHeaderCell('Date'),
            _buildTableHeaderCell('Room'),
            _buildTableHeaderCell('Material'),
            _buildTableHeaderCell('Area (sq.ft)'),
            _buildTableHeaderCell('Total Amount'),
            _buildTableHeaderCell('Advance'),
            _buildTableHeaderCell('Balance'),
            _buildTableHeaderCell('Status'),
          ],
        ),

        // Table Rows
        ...projects.map((project) {
          final isPaid = project.remainingBalance <= 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: projects.indexOf(project) % 2 == 0
                  ? PdfColors.white
                  : PdfColors.grey50,
            ),
            children: [
              _buildTableCell(project.date, isHeader: false),
              _buildTableCell(project.room, isHeader: false),
              _buildTableCell(project.fileType, isHeader: false),
              _buildTableCell(project.totalSqFt.toStringAsFixed(2), isHeader: false),
              _buildTableCell('Rs ${project.totalAmount.toStringAsFixed(2)}', isHeader: false),
              _buildTableCell('Rs ${project.advance.toStringAsFixed(2)}', isHeader: false),
              _buildTableCell('Rs ${project.remainingBalance.toStringAsFixed(2)}', isHeader: false),
              _buildTableCell(
                isPaid ? 'Paid' : 'Pending',
                isHeader: false,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // ==================== Summary Card ====================
  static pw.Container _buildSummaryCard(String title, String value, PdfColor color, IconData icon) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style:  pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _accentColor,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== Financial Card ====================
  static pw.Container _buildFinancialCard(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: color, width: 1.5),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== PDF Save and Open Function ====================
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

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Check platform and handle accordingly
      if (kIsWeb) {
        // Web platform - use download
        _downloadPdfForWeb(pdfBytes, '$fileName.pdf');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF download started!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Mobile platform - save to device
        await _savePdfForMobile(pdfBytes, fileName, context);
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ==================== WEB PDF Download ====================
  static void _downloadPdfForWeb(Uint8List bytes, String fileName) {
    // This will only compile on web
    if (kIsWeb) {
      try {
        // Create a blob and download link
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..style.display = 'none';

        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);
      } catch (e) {
        print('Web download error: $e');
      }
    }
  }

  // ==================== MOBILE PDF Save and Open ====================
  static Future<void> _savePdfForMobile(Uint8List pdfBytes, String fileName, BuildContext context) async {
    // This will only compile on mobile
    if (!kIsWeb) {
      try {
        // Show loading again for mobile
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          ),
        );

        // Get directory
        Directory directory;

        if (Platform.isAndroid) {
          // For Android, try to get external storage first
          try {
            directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              directory = await getApplicationDocumentsDirectory();
            }
          } catch (e) {
            directory = await getApplicationDocumentsDirectory();
          }
        } else if (Platform.isIOS) {
          // For iOS, use documents directory
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

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('PDF saved successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Open the file
        await OpenFile.open(filePath);

      } catch (e) {
        // Close loading dialog
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Show error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save PDF: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Helper function to get application documents directory (mobile only)
  static Future<Directory> getApplicationDocumentsDirectory() async {
    // Import path_provider
    return await getApplicationDocumentsDirectory();
  }

  // Helper function to open file (mobile only)
  static Future<void> openFile(String path) async {
    // Import open_file
    await OpenFile.open(path);
  }
}