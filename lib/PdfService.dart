//
// // pdf_service.dart
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:open_file/open_file.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:path_provider/path_provider.dart';
//
// // Conditional imports
// import 'dart:io' if (dart.library.io) 'dart:io';
// import 'dart:html' if (dart.library.html) 'dart:html' as html;
//
// import 'Model class.dart';
// import 'Party Model.dart';
//
// class PdfService {
//   // Company details
//   static const String companyName = 'Graphics Lab';
//   static const String companyAddress = 'Karachi, Pakistan';
//   static const String companyPhone = '+92 300 1234567';
//   static const String companyEmail = 'info@graphicslab.com';
//   static const String slogan = 'We Deal all kinds of Printing';
//
//   // Color scheme
//   static final PdfColor _primaryColor = PdfColor.fromInt(0xFFFFA500); // Orange
//   static final PdfColor _secondaryColor = PdfColor.fromInt(0xFF4A6572); // Dark Blue
//   static final PdfColor _accentColor = PdfColor.fromInt(0xFF0D47A1); // Blue Accent
//   static final PdfColor _lightBg = PdfColor.fromInt(0xFFF5F5F5);
//   static final PdfColor _darkText = PdfColor.fromInt(0xFF263238);
//   static final PdfColor _successColor = PdfColor.fromInt(0xFF4CAF50);
//   static final PdfColor _warningColor = PdfColor.fromInt(0xFFFF9800);
//
//   // Text styles
//   static pw.TextStyle get _companyHeaderStyle => pw.TextStyle(
//     fontSize: 24,
//     fontWeight: pw.FontWeight.bold,
//     color: _primaryColor,
//   );
//
//   static pw.TextStyle get _reportTitleStyle => pw.TextStyle(
//     fontSize: 20,
//     fontWeight: pw.FontWeight.bold,
//     color: _secondaryColor,
//   );
//
//   static pw.TextStyle get _sectionTitleStyle => pw.TextStyle(
//     fontSize: 14,
//     fontWeight: pw.FontWeight.bold,
//     color: _accentColor,
//   );
//
//   static pw.TextStyle get _subtitleStyle => pw.TextStyle(
//     fontSize: 12,
//     fontWeight: pw.FontWeight.bold,
//     color: _darkText,
//   );
//
//   static pw.TextStyle get _labelStyle => pw.TextStyle(
//     fontSize: 10,
//     fontWeight: pw.FontWeight.bold,
//     color: _darkText,
//   );
//
//   static pw.TextStyle get _valueStyle => pw.TextStyle(
//     fontSize: 10,
//     color: _darkText,
//   );
//
//   static pw.TextStyle get _totalStyle => pw.TextStyle(
//     fontSize: 11,
//     fontWeight: pw.FontWeight.bold,
//     color: _primaryColor,
//   );
//
//   static pw.TextStyle get _amountStyle => pw.TextStyle(
//     fontSize: 10,
//     fontWeight: pw.FontWeight.bold,
//     color: _accentColor,
//   );
//
//   // ==================== New Header with Logo ====================
//   static pw.Widget _buildNewHeader(pw.Context context, {pw.ImageProvider? logoImage}) {
//     final dateTime = DateTime.now();
//     final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
//     final formattedTime = DateFormat('hh:mm a').format(dateTime);
//     final generatedBy = 'Generated: $formattedDate at $formattedTime';
//
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Row(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             // Logo Container
//             if (logoImage != null)
//               pw.Container(
//                 width: 80,
//                 height: 80,
//                 child: pw.Image(logoImage),
//               ),
//
//             pw.SizedBox(width: 20),
//
//             // Company Info
//             pw.Expanded(
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   // Company Name
//                   pw.Text(
//                     companyName,
//                     style: pw.TextStyle(
//                       fontSize: 22,
//                       fontWeight: pw.FontWeight.bold,
//                       color: _primaryColor,
//                     ),
//                   ),
//
//                   // Slogan
//                   pw.Text(
//                     slogan,
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       color: _secondaryColor,
//                       fontStyle: pw.FontStyle.italic,
//                     ),
//                   ),
//
//                   // Generated Date Time
//                   pw.Container(
//                     margin: const pw.EdgeInsets.only(top: 8),
//                     child: pw.Text(
//                       generatedBy,
//                       style: const pw.TextStyle(
//                         fontSize: 9,
//                         color: PdfColors.grey600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//
//         // Divider
//         pw.Container(
//           margin: const pw.EdgeInsets.symmetric(vertical: 15),
//           height: 2,
//           color: _primaryColor,
//         ),
//       ],
//     );
//   }
//
//   // ==================== Party Information Section ====================
//   static pw.Widget _buildPartyInfoSection(PartyModel party) {
//     return _buildSectionContainer(
//       'PARTY INFORMATION',
//       pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           _buildInfoRow('Name:', party.name),
//           pw.SizedBox(height: 4),
//           _buildInfoRow('Type:', party.type),
//           pw.SizedBox(height: 4),
//           _buildInfoRow('Phone #:', party.phone),
//           pw.SizedBox(height: 4),
//           _buildInfoRow('Address:', party.address),
//         ],
//       ),
//     );
//   }
//
//   // ==================== Party Summary Section ====================
//   static pw.Widget _buildPartySummarySection({
//     required int totalInventory,
//     required double roofSqFt,
//     required double wallsSqFt,
//     required double roofAmount,
//     required double wallsAmount,
//     required double totalAdvance,
//     required double totalRemaining,
//   }) {
//     final totalAmount = roofAmount + wallsAmount;
//
//     return _buildSectionContainer(
//       'SUMMARY',
//       pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           // First row
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Expanded(
//                 child: _buildSummaryItem('Total Inventory:', totalInventory.toString()),
//               ),
//               pw.SizedBox(width: 10),
//               pw.Expanded(
//                 child: _buildSummaryItem('Roof Square Feet:', '${roofSqFt.toStringAsFixed(2)} sq.ft'),
//               ),
//               pw.SizedBox(width: 10),
//               pw.Expanded(
//                 child: _buildSummaryItem('Walls Square Feet:', '${wallsSqFt.toStringAsFixed(2)} sq.ft'),
//               ),
//             ],
//           ),
//
//           pw.SizedBox(height: 10),
//
//           // Second row
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Expanded(
//                 child: _buildSummaryItem('Roof Amount:', 'Rs ${roofAmount.toStringAsFixed(2)}'),
//               ),
//               pw.SizedBox(width: 10),
//               pw.Expanded(
//                 child: _buildSummaryItem('Walls Amount:', 'Rs ${wallsAmount.toStringAsFixed(2)}'),
//               ),
//               pw.SizedBox(width: 10),
//               pw.Expanded(
//                 child: _buildSummaryItem('Total Amount:', 'Rs ${totalAmount.toStringAsFixed(2)}', isTotal: true),
//               ),
//             ],
//           ),
//
//           pw.SizedBox(height: 10),
//
//           // Third row
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Expanded(
//                 child: _buildSummaryItem('Total Advance:', 'Rs ${totalAdvance.toStringAsFixed(2)}'),
//               ),
//               pw.SizedBox(width: 10),
//               pw.Expanded(
//                 child: _buildSummaryItem('Total Remaining:', 'Rs ${totalRemaining.toStringAsFixed(2)}', isHighlighted: totalRemaining > 0),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   static pw.Widget _buildSummaryItem(String label, String value, {bool isTotal = false, bool isHighlighted = false}) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             fontSize: 9,
//             color: PdfColors.grey700,
//           ),
//         ),
//         pw.SizedBox(height: 2),
//         pw.Text(
//           value,
//           style: pw.TextStyle(
//             fontSize: 11,
//             fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
//             color: isHighlighted ? _primaryColor : (isTotal ? _accentColor : _darkText),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ==================== Inventory Details Section ====================
//   static pw.Widget _buildInventoryDetailsSection(CustomerModel project) {
//     // Calculate roof and walls area
//     double roofArea = 0;
//     double wallsArea = 0;
//
//     for (var dim in project.dimensions) {
//       final wallName = (dim['wall']?.toString() ?? '').toLowerCase();
//       final sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0;
//
//       if (wallName.contains('roof')) {
//         roofArea += sqFt;
//       } else {
//         wallsArea += sqFt;
//       }
//     }
//
//     final dateTime = DateTime.now();
//     final formattedDateTime = DateFormat('dd MMM yyyy hh:mm a').format(dateTime);
//
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         // Inventory Header
//         pw.Container(
//           margin: const pw.EdgeInsets.only(bottom: 10),
//           padding: const pw.EdgeInsets.all(10),
//           decoration: pw.BoxDecoration(
//             color: PdfColors.grey100,
//             borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
//             border: pw.Border.all(color: PdfColors.grey300),
//           ),
//           child: pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text(
//                 'Inventory Details',
//                 style: pw.TextStyle(
//                   fontSize: 12,
//                   fontWeight: pw.FontWeight.bold,
//                   color: _accentColor,
//                 ),
//               ),
//               pw.Text(
//                 formattedDateTime,
//                 style: const pw.TextStyle(
//                   fontSize: 9,
//                   color: PdfColors.grey600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Room and Description
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           children: [
//             _buildInfoRow('Room:', project.room),
//             pw.SizedBox(width: 20),
//             pw.Expanded(
//               child: _buildInfoRow('Description:', project.fileType),
//             ),
//           ],
//         ),
//
//         pw.SizedBox(height: 10),
//
//         // Area Breakdown
//         pw.Container(
//           margin: const pw.EdgeInsets.only(bottom: 10),
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(
//                 'Area Breakdown:',
//                 style: pw.TextStyle(
//                   fontSize: 10,
//                   fontWeight: pw.FontWeight.bold,
//                   color: _darkText,
//                 ),
//               ),
//               pw.SizedBox(height: 5),
//               pw.Row(
//                 children: [
//                   pw.Expanded(
//                     child: _buildAreaBox('Roof Area:', '${roofArea.toStringAsFixed(2)} sq.ft'),
//                   ),
//                   pw.SizedBox(width: 10),
//                   pw.Expanded(
//                     child: _buildAreaBox('Walls Area:', '${wallsArea.toStringAsFixed(2)} sq.ft'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//
//         // Dimensions Table
//         if (project.dimensions.isNotEmpty) ...[
//           pw.Text(
//             'Dimensions:',
//             style: pw.TextStyle(
//               fontSize: 10,
//               fontWeight: pw.FontWeight.bold,
//               color: _darkText,
//               decoration: pw.TextDecoration.underline,
//             ),
//           ),
//           pw.SizedBox(height: 5),
//           _buildDimensionsTable(project.dimensions),
//           pw.SizedBox(height: 15),
//         ],
//
//         // Financial Details
//         pw.Container(
//           padding: const pw.EdgeInsets.all(12),
//           decoration: pw.BoxDecoration(
//             color: _lightBg,
//             borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
//             border: pw.Border.all(color: PdfColors.grey300),
//           ),
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               _buildFinancialDetailRow('Rate Per Sq.Ft:', 'Rs ${project.rate.toStringAsFixed(2)}'),
//               pw.SizedBox(height: 4),
//               _buildFinancialDetailRow('Additional Charges:', 'Rs ${project.additionalCharges.toStringAsFixed(2)}'),
//               pw.SizedBox(height: 4),
//               _buildFinancialDetailRow('Total Amount:', 'Rs ${project.totalAmount.toStringAsFixed(2)}', isTotal: true),
//               pw.SizedBox(height: 4),
//               _buildFinancialDetailRow('Advance:', 'Rs ${project.advance.toStringAsFixed(2)}'),
//               pw.SizedBox(height: 4),
//               _buildFinancialDetailRow(
//                   'Remaining Balance:',
//                   'Rs ${project.remainingBalance.toStringAsFixed(2)}',
//                   isHighlighted: project.remainingBalance > 0
//               ),
//             ],
//           ),
//         ),
//
//         // Divider between inventories
//         pw.Container(
//           margin: const pw.EdgeInsets.symmetric(vertical: 20),
//           height: 1,
//           color: PdfColors.grey300,
//         ),
//       ],
//     );
//   }
//
//   static pw.Widget _buildAreaBox(String label, String value) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(8),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
//       ),
//       child: pw.Column(
//         children: [
//           pw.Text(
//             label,
//             style: const pw.TextStyle(
//               fontSize: 9,
//               color: PdfColors.grey600,
//             ),
//           ),
//           pw.SizedBox(height: 2),
//           pw.Text(
//             value,
//             style: pw.TextStyle(
//               fontSize: 10,
//               fontWeight: pw.FontWeight.bold,
//               color: _accentColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static pw.Row _buildFinancialDetailRow(String label, String value, {bool isTotal = false, bool isHighlighted = false}) {
//     return pw.Row(
//       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//       children: [
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             fontSize: 10,
//             fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
//             color: _darkText,
//           ),
//         ),
//         pw.Text(
//           value,
//           style: pw.TextStyle(
//             fontSize: 10,
//             fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
//             color: isHighlighted ? _primaryColor : (isTotal ? _accentColor : _darkText),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ==================== Business Lines Footer ====================
//   static pw.Widget _buildBusinessLinesFooter() {
//     return pw.Container(
//       margin: const pw.EdgeInsets.only(top: 20),
//       padding: const pw.EdgeInsets.all(15),
//       decoration: pw.BoxDecoration(
//         color: PdfColors.grey50,
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
//         border: pw.Border.all(color: PdfColors.grey300),
//       ),
//       child: pw.Column(
//         children: [
//           pw.Text(
//             'Thank you for choosing $companyName!',
//             style: pw.TextStyle(
//               fontSize: 12,
//               fontWeight: pw.FontWeight.bold,
//               color: _primaryColor,
//             ),
//             textAlign: pw.TextAlign.center,
//           ),
//           pw.SizedBox(height: 8),
//           pw.Text(
//             'We are committed to providing high-quality printing services with excellent customer support.',
//             style: const pw.TextStyle(
//               fontSize: 9,
//               color: PdfColors.grey600,
//             ),
//             textAlign: pw.TextAlign.center,
//           ),
//           pw.SizedBox(height: 5),
//           pw.Text(
//             'For inquiries, contact us at $companyPhone or email $companyEmail',
//             style: const pw.TextStyle(
//               fontSize: 8,
//               color: PdfColors.grey600,
//             ),
//             textAlign: pw.TextAlign.center,
//           ),
//           pw.SizedBox(height: 5),
//           pw.Text(
//             '$companyAddress | Visit us for all your printing needs',
//             style:  pw.TextStyle(
//               fontSize: 8,
//               color: PdfColors.grey600,
//               fontStyle: pw.FontStyle.italic,
//             ),
//             textAlign: pw.TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ==================== Single Project Specifications Section ====================
//   static pw.Widget _buildSpecificationsSection(CustomerModel project) {
//     return _buildSectionContainer(
//       'SPECIFICATIONS',
//       pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           _buildInfoRow('Room:', project.room),
//           pw.SizedBox(height: 4),
//           _buildInfoRow('Description:', project.fileType),
//         ],
//       ),
//     );
//   }
//
//   // ==================== Single Project Financial Summary ====================
//   static pw.Widget _buildSingleProjectFinancialSummary(CustomerModel project) {
//     return _buildSectionContainer(
//       'FINANCIAL SUMMARY',
//       pw.Container(
//         padding: const pw.EdgeInsets.all(12),
//         decoration: pw.BoxDecoration(
//           color: _lightBg,
//           borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
//           border: pw.Border.all(color: PdfColors.grey300),
//         ),
//         child: pw.Column(
//           children: [
//             _buildFinancialDetailRow('Rate per Sq.Ft:', 'Rs ${project.rate.toStringAsFixed(2)}'),
//             pw.SizedBox(height: 6),
//             _buildFinancialDetailRow('Total Area:', '${project.totalSqFt.toStringAsFixed(2)} sq.ft'),
//             pw.SizedBox(height: 6),
//             _buildFinancialDetailRow('Additional Charges:', 'Rs ${project.additionalCharges.toStringAsFixed(2)}'),
//             pw.SizedBox(height: 6),
//             _buildFinancialDetailRow('Total Amount:', 'Rs ${project.totalAmount.toStringAsFixed(2)}', isTotal: true),
//             pw.SizedBox(height: 6),
//             _buildFinancialDetailRow('Advance:', 'Rs ${project.advance.toStringAsFixed(2)}'),
//             pw.SizedBox(height: 6),
//             _buildFinancialDetailRow(
//               'Remaining Balance:',
//               'Rs ${project.remainingBalance.toStringAsFixed(2)}',
//               isHighlighted: project.remainingBalance > 0,
//               isTotal: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ==================== Section Container ====================
//   static pw.Container _buildSectionContainer(String title, pw.Widget child) {
//     return pw.Container(
//       margin: const pw.EdgeInsets.only(bottom: 15),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Container(
//             margin: const pw.EdgeInsets.only(bottom: 8),
//             child: pw.Text(
//               title,
//               style: _sectionTitleStyle,
//             ),
//           ),
//           child,
//         ],
//       ),
//     );
//   }
//
//   // ==================== Information Row ====================
//   static pw.Row _buildInfoRow(String label, String value) {
//     return pw.Row(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           '$label ',
//           style: _labelStyle,
//         ),
//         pw.Expanded(
//           child: pw.Text(
//             value,
//             style: _valueStyle,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ==================== Dimensions Table ====================
//   static pw.Widget _buildDimensionsTable(List<Map<String, dynamic>> dimensions) {
//     return pw.Table(
//       border: pw.TableBorder.all(
//         color: PdfColors.grey300,
//         width: 0.5,
//       ),
//       columnWidths: {
//         0: const pw.FlexColumnWidth(1.8), // Wall
//         1: const pw.FlexColumnWidth(1.2), // Width
//         2: const pw.FlexColumnWidth(1.2), // Height
//         3: const pw.FlexColumnWidth(0.8), // Qty
//         4: const pw.FlexColumnWidth(1.2), // Sq.Ft
//         5: const pw.FlexColumnWidth(1.5), // Area (W×H)
//       },
//       children: [
//         // Table Header
//         pw.TableRow(
//           decoration: pw.BoxDecoration(
//             color: _secondaryColor,
//           ),
//           children: [
//             _buildTableHeaderCell('Wall Name'),
//             _buildTableHeaderCell('Width (ft)'),
//             _buildTableHeaderCell('Height (ft)'),
//             _buildTableHeaderCell('Qty'),
//             _buildTableHeaderCell('Sq. Ft'),
//             _buildTableHeaderCell('Area (W×H)'),
//           ],
//         ),
//
//         // Table Rows
//         ...dimensions.map((dim) {
//           final width = double.tryParse(dim['width']?.toString() ?? '0') ?? 0;
//           final height = double.tryParse(dim['height']?.toString() ?? '0') ?? 0;
//           final quantity = int.tryParse(dim['quantity']?.toString() ?? '1') ?? 1;
//           final area = width * height;
//           final sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0;
//
//           return pw.TableRow(
//             decoration: pw.BoxDecoration(
//               color: dimensions.indexOf(dim) % 2 == 0
//                   ? PdfColors.white
//                   : PdfColors.grey50,
//             ),
//             children: [
//               _buildTableCell(dim['wall']?.toString() ?? 'N/A'),
//               _buildTableCell(width.toStringAsFixed(2)),
//               _buildTableCell(height.toStringAsFixed(2)),
//               _buildTableCell(quantity.toString()),
//               _buildTableCell(sqFt.toStringAsFixed(2)),
//               _buildTableCell('${area.toStringAsFixed(2)} sq.ft'),
//             ],
//           );
//         }).toList(),
//       ],
//     );
//   }
//
//   static pw.Widget _buildTableHeaderCell(String text) {
//     return pw.Container(
//       alignment: pw.Alignment.center,
//       padding: const pw.EdgeInsets.all(6),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: 9,
//           fontWeight: pw.FontWeight.bold,
//           color: PdfColors.white,
//         ),
//         textAlign: pw.TextAlign.center,
//       ),
//     );
//   }
//
//   static pw.Widget _buildTableCell(String text) {
//     return pw.Container(
//       alignment: pw.Alignment.center,
//       padding: const pw.EdgeInsets.all(6),
//       child: pw.Text(
//         text,
//         style: const pw.TextStyle(
//           fontSize: 8,
//           color: PdfColors.black,
//         ),
//         textAlign: pw.TextAlign.center,
//       ),
//     );
//   }
//
//   // ==================== Party Projects PDF ====================
//   static Future<Uint8List> generatePartyProjectsPdf({
//     required PartyModel party,
//     required List<CustomerModel> projects,
//     Uint8List? logoBytes,
//   }) async {
//     final pdf = pw.Document();
//
//     // Calculate summary
//     final totalInventory = projects.length;
//
//     double totalRoofSqFt = 0;
//     double totalWallsSqFt = 0;
//     double totalRoofAmount = 0;
//     double totalWallsAmount = 0;
//     double totalAdvance = 0;
//     double totalRemaining = 0;
//
//     // Calculate roof and walls for each project
//     for (var project in projects) {
//       double roofArea = 0;
//       double wallsArea = 0;
//
//       for (var dim in project.dimensions) {
//         final wallName = (dim['wall']?.toString() ?? '').toLowerCase();
//         final sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0;
//
//         if (wallName.contains('roof')) {
//           roofArea += sqFt;
//         } else {
//           wallsArea += sqFt;
//         }
//       }
//
//       totalRoofSqFt += roofArea;
//       totalWallsSqFt += wallsArea;
//       totalRoofAmount += roofArea * project.rate;
//       totalWallsAmount += wallsArea * project.rate;
//       totalAdvance += project.advance;
//       totalRemaining += project.remainingBalance;
//     }
//
//     // Load logo image
//     pw.ImageProvider? logoImage;
//     if (logoBytes != null && logoBytes.isNotEmpty) {
//       logoImage = pw.MemoryImage(logoBytes);
//     }
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 25),
//         build: (pw.Context context) {
//           return [
//             // Header
//             _buildNewHeader(context, logoImage: logoImage),
//
//             // Party Information
//             _buildPartyInfoSection(party),
//
//             // Summary Section
//             _buildPartySummarySection(
//               totalInventory: totalInventory,
//               roofSqFt: totalRoofSqFt,
//               wallsSqFt: totalWallsSqFt,
//               roofAmount: totalRoofAmount,
//               wallsAmount: totalWallsAmount,
//               totalAdvance: totalAdvance,
//               totalRemaining: totalRemaining,
//             ),
//
//             // Inventory Details for each project
//             ...projects.map((project) {
//               return _buildInventoryDetailsSection(project);
//             }).toList(),
//
//             // Business Lines Footer
//             _buildBusinessLinesFooter(),
//           ];
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
//
//   // ==================== Single Project PDF ====================
//   static Future<Uint8List> generateProjectDetailPdf({
//     required String customerName,
//     required String phone,
//     required String address,
//     required String date,
//     required String room,
//     required String fileType,
//     required String rate,
//     required String additionalCharges,
//     required String advance,
//     required String totalSqFt,
//     required String totalAmount,
//     required String remainingBalance,
//     required List<Map<String, dynamic>> dimensions,
//     required List<Map<String, dynamic>> paymentHistory,
//     Uint8List? logoBytes,
//   }) async {
//     final pdf = pw.Document();
//
//     // Create CustomerModel from parameters
//     final project = CustomerModel(
//       id: '',
//       customerName: customerName,
//       phone: phone,
//       address: address,
//       date: date,
//       room: room,
//       fileType: fileType,
//       rate: double.parse(rate),
//       additionalCharges: double.parse(additionalCharges),
//       advance: double.parse(advance),
//       totalSqFt: double.parse(totalSqFt),
//       totalAmount: double.parse(totalAmount),
//       remainingBalance: double.parse(remainingBalance),
//       dimensions: dimensions,
//       paymentHistory: paymentHistory,
//       // partyId: '',
//       // createdAt: DateTime.now(),
//     );
//
//     // Create PartyModel for single project
//     final party = PartyModel(
//       id: '',
//       name: customerName,
//       type: 'customer',
//       phone: phone,
//       address: address,
//       date: date,
//       totalAmount: double.parse(totalAmount),
//       totalAdvance: double.parse(advance),
//       totalRemaining: double.parse(remainingBalance),
//       // paymentStatus: double.parse(remainingBalance) <= 0 ? 'Paid' : 'Pending',
//       // createdAt: DateTime.now(),
//       // updatedAt: DateTime.now(),
//     );
//
//     // Load logo image
//     pw.ImageProvider? logoImage;
//     if (logoBytes != null && logoBytes.isNotEmpty) {
//       logoImage = pw.MemoryImage(logoBytes);
//     }
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 25),
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // Header
//               _buildNewHeader(context, logoImage: logoImage),
//
//               // Party Information
//               _buildPartyInfoSection(party),
//
//               // Specifications
//               _buildSpecificationsSection(project),
//
//               // Dimensions Section
//               if (project.dimensions.isNotEmpty) ...[
//                 _buildSectionContainer(
//                   'DIMENSIONS',
//                   _buildDimensionsTable(project.dimensions),
//                 ),
//               ],
//
//               // Financial Summary
//               _buildSingleProjectFinancialSummary(project),
//
//               // Business Lines Footer
//               _buildBusinessLinesFooter(),
//             ],
//           );
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
//
//   // ==================== PDF Save and Open Function ====================
//   static Future<void> saveAndOpenPdf({
//     required BuildContext context,
//     required Future<Uint8List> Function() generatePdf,
//     required String fileName,
//     Uint8List? logoBytes,
//   }) async {
//     try {
//       // Show loading indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(
//           child: CircularProgressIndicator(color: Colors.orange),
//         ),
//       );
//
//       // Generate PDF
//       final pdfBytes = await generatePdf();
//
//       // Close loading dialog
//       if (context.mounted) {
//         Navigator.pop(context);
//       }
//
//       // Check platform and handle accordingly
//       if (kIsWeb) {
//         // Web platform - use download
//         _downloadPdfForWeb(pdfBytes, '$fileName.pdf');
//
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('PDF download started!'),
//               backgroundColor: Colors.green,
//               duration: Duration(seconds: 2),
//             ),
//           );
//         }
//       } else {
//         // Mobile platform - save to device
//         await _savePdfForMobile(pdfBytes, fileName, context);
//       }
//     } catch (e) {
//       // Close loading dialog
//       if (context.mounted) {
//         if (Navigator.canPop(context)) {
//           Navigator.pop(context);
//         }
//
//         // Show error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }
//
//   // ==================== WEB PDF Download ====================
//   static void _downloadPdfForWeb(Uint8List bytes, String fileName) {
//     // This will only compile on web
//     if (kIsWeb) {
//       try {
//         // Create a blob and download link
//         final blob = html.Blob([bytes], 'application/pdf');
//         final url = html.Url.createObjectUrlFromBlob(blob);
//         final anchor = html.AnchorElement(href: url)
//           ..setAttribute('download', fileName)
//           ..style.display = 'none';
//
//         html.document.body?.append(anchor);
//         anchor.click();
//         anchor.remove();
//         html.Url.revokeObjectUrl(url);
//       } catch (e) {
//         print('Web download error: $e');
//       }
//     }
//   }
//
//   // ==================== MOBILE PDF Save and Open ====================
//   static Future<void> _savePdfForMobile(Uint8List pdfBytes, String fileName, BuildContext context) async {
//     // This will only compile on mobile
//     if (!kIsWeb) {
//       try {
//         // Show loading again for mobile
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => const Center(
//             child: CircularProgressIndicator(color: Colors.orange),
//           ),
//         );
//
//         // Get directory
//         Directory directory;
//
//         if (Platform.isAndroid) {
//           // For Android, try to get external storage first
//           try {
//             directory = Directory('/storage/emulated/0/Download');
//             if (!await directory.exists()) {
//               directory = await getApplicationDocumentsDirectory();
//             }
//           } catch (e) {
//             directory = await getApplicationDocumentsDirectory();
//           }
//         } else if (Platform.isIOS) {
//           // For iOS, use documents directory
//           directory = await getApplicationDocumentsDirectory();
//         } else {
//           directory = await getApplicationDocumentsDirectory();
//         }
//
//         // Create file path
//         final filePath = '${directory.path}/$fileName.pdf';
//         final file = File(filePath);
//
//         // Save file
//         await file.writeAsBytes(pdfBytes);
//
//         // Close loading dialog
//         if (context.mounted) {
//           Navigator.pop(context);
//         }
//
//         // Show success message
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('PDF saved successfully!'),
//               backgroundColor: Colors.green,
//               duration: Duration(seconds: 3),
//             ),
//           );
//         }
//
//         // Open the file
//         await OpenFile.open(filePath);
//
//       } catch (e) {
//         // Close loading dialog
//         if (context.mounted && Navigator.canPop(context)) {
//           Navigator.pop(context);
//         }
//
//         // Show error
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to save PDF: ${e.toString()}'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }
//
//   // Helper function to get application documents directory
//   static Future<Directory> getApplicationDocumentsDirectory() async {
//     return await getApplicationDocumentsDirectory();
//   }
//
//   // Helper function to open file
//   static Future<void> openFile(String path) async {
//     await OpenFile.open(path);
//   }
// }

// pdf_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

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
  static const String slogan = 'We Deal all kinds of Printing';

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
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: _primaryColor,
  );

  static pw.TextStyle get _reportTitleStyle => pw.TextStyle(
    fontSize: 20,
    fontWeight: pw.FontWeight.bold,
    color: _secondaryColor,
  );

  static pw.TextStyle get _sectionTitleStyle => pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: _accentColor,
  );

  static pw.TextStyle get _subtitleStyle => pw.TextStyle(
    fontSize: 12,
    fontWeight: pw.FontWeight.bold,
    color: _darkText,
  );

  static pw.TextStyle get _labelStyle => pw.TextStyle(
    fontSize: 10,
    fontWeight: pw.FontWeight.bold,
    color: _darkText,
  );

  static pw.TextStyle get _valueStyle => pw.TextStyle(
    fontSize: 10,
    color: _darkText,
  );

  static pw.TextStyle get _totalStyle => pw.TextStyle(
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
    color: _primaryColor,
  );

  static pw.TextStyle get _amountStyle => pw.TextStyle(
    fontSize: 10,
    fontWeight: pw.FontWeight.bold,
    color: _accentColor,
  );

  // ==================== New Header with Logo ====================
  static pw.Widget _buildNewHeader({pw.ImageProvider? logoImage}) {
    final dateTime = DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);
    final generatedBy = 'Generated: $formattedDate at $formattedTime';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Logo Container
            if (logoImage != null)
              pw.Container(
                width: 80,
                height: 80,
                child: pw.Image(logoImage),
              ),

            pw.SizedBox(width: 20),

            // Company Info
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Company Name
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),

                  // Slogan
                  pw.Text(
                    slogan,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: _secondaryColor,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),

                  // Generated Date Time
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 8),
                    child: pw.Text(
                      generatedBy,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Divider
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 15),
          height: 2,
          color: _primaryColor,
        ),
      ],
    );
  }

  // ==================== Party Information Section ====================
  static pw.Widget _buildPartyInfoSection(PartyModel party) {
    return _buildSectionContainer(
      'PARTY INFORMATION',
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Name:', party.name),
          pw.SizedBox(height: 4),
          _buildInfoRow('Type:', party.type),
          pw.SizedBox(height: 4),
          _buildInfoRow('Phone #:', party.phone),
          pw.SizedBox(height: 4),
          _buildInfoRow('Address:', party.address),
        ],
      ),
    );
  }

  // ==================== Party Summary Section ====================
  static pw.Widget _buildPartySummarySection({
    required int totalInventory,
    required double roofSqFt,
    required double wallsSqFt,
    required double roofAmount,
    required double wallsAmount,
    required double totalAdvance,
    required double totalRemaining,
  }) {
    final totalAmount = roofAmount + wallsAmount;

    return _buildSectionContainer(
      'SUMMARY',
      pw.Table(
        border: null,
        columnWidths: {
          0: const pw.FlexColumnWidth(1.0),
          1: const pw.FlexColumnWidth(1.0),
          2: const pw.FlexColumnWidth(1.0),
        },
        children: [
          // First row
          pw.TableRow(
            children: [
              _buildSummaryItem('Total Inventory:', totalInventory.toString()),
              _buildSummaryItem('Roof Square Feet:', '${roofSqFt.toStringAsFixed(2)} sq.ft'),
              _buildSummaryItem('Walls Square Feet:', '${wallsSqFt.toStringAsFixed(2)} sq.ft'),
            ],
          ),

          // Second row
          pw.TableRow(
            children: [
              _buildSummaryItem('Roof Amount:', 'Rs ${roofAmount.toStringAsFixed(2)}'),
              _buildSummaryItem('Walls Amount:', 'Rs ${wallsAmount.toStringAsFixed(2)}'),
              _buildSummaryItem('Total Amount:', 'Rs ${totalAmount.toStringAsFixed(2)}', isTotal: true),
            ],
          ),

          // Third row
          pw.TableRow(
            children: [
              _buildSummaryItem('Total Advance:', 'Rs ${totalAdvance.toStringAsFixed(2)}'),
              _buildSummaryItem('Total Remaining:', 'Rs ${totalRemaining.toStringAsFixed(2)}', isHighlighted: totalRemaining > 0),
              pw.Container(), // Empty cell for alignment
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value, {bool isTotal = false, bool isHighlighted = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isHighlighted ? _primaryColor : (isTotal ? _accentColor : _darkText),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Inventory Details Section ====================
  static pw.Widget _buildInventoryDetailsSection(CustomerModel project) {
    // Calculate roof and walls area
    double roofArea = 0;
    double wallsArea = 0;

    for (var dim in project.dimensions) {
      final wallName = (dim['wall']?.toString() ?? '').toLowerCase();
      final sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0;

      if (wallName.contains('roof')) {
        roofArea += sqFt;
      } else {
        wallsArea += sqFt;
      }
    }

    final dateTime = DateTime.now();
    final formattedDateTime = DateFormat('dd MMM yyyy hh:mm a').format(dateTime);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Inventory Header
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Inventory Details',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: _accentColor,
                ),
              ),
              pw.Text(
                formattedDateTime,
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),

        // Room and Description
        pw.Table(
          columnWidths: {
            0: const pw.FlexColumnWidth(1.0),
            1: const pw.FlexColumnWidth(2.0),
          },
          children: [
            pw.TableRow(
              children: [
                pw.Text('Room:', style: _labelStyle),
                pw.Text(project.room, style: _valueStyle),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Text('Description:', style: _labelStyle),
                pw.Text(project.fileType, style: _valueStyle),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 10),

        // Area Breakdown
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Area Breakdown:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _darkText,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.0),
                  1: const pw.FlexColumnWidth(1.0),
                },
                children: [
                  pw.TableRow(
                    children: [
                      _buildAreaBox('Roof Area:', '${roofArea.toStringAsFixed(2)} sq.ft'),
                      _buildAreaBox('Walls Area:', '${wallsArea.toStringAsFixed(2)} sq.ft'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Dimensions Table
        if (project.dimensions.isNotEmpty) ...[
          pw.Text(
            'Dimensions:',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _darkText,
            ),
          ),
          pw.SizedBox(height: 5),
          _buildDimensionsTable(project.dimensions),
          pw.SizedBox(height: 15),
        ],

        // Financial Details
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: _lightBg,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildFinancialDetailRow('Rate Per Sq.Ft:', 'Rs ${project.rate.toStringAsFixed(2)}'),
              pw.SizedBox(height: 4),
              _buildFinancialDetailRow('Additional Charges:', 'Rs ${project.additionalCharges.toStringAsFixed(2)}'),
              pw.SizedBox(height: 4),
              _buildFinancialDetailRow('Total Amount:', 'Rs ${project.totalAmount.toStringAsFixed(2)}', isTotal: true),
              pw.SizedBox(height: 4),
              _buildFinancialDetailRow('Advance:', 'Rs ${project.advance.toStringAsFixed(2)}'),
              pw.SizedBox(height: 4),
              _buildFinancialDetailRow(
                  'Remaining Balance:',
                  'Rs ${project.remainingBalance.toStringAsFixed(2)}',
                  isHighlighted: project.remainingBalance > 0
              ),
            ],
          ),
        ),

        // Divider between inventories
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 20),
          height: 1,
          color: PdfColors.grey300,
        ),
      ],
    );
  }

  static pw.Widget _buildAreaBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _accentColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Row _buildFinancialDetailRow(String label, String value, {bool isTotal = false, bool isHighlighted = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: _darkText,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHighlighted ? _primaryColor : (isTotal ? _accentColor : _darkText),
          ),
        ),
      ],
    );
  }

  // ==================== Business Lines Footer ====================
  static pw.Widget _buildBusinessLinesFooter() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
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
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'We are committed to providing high-quality printing services with excellent customer support.',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'For inquiries, contact us at $companyPhone or email $companyEmail',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '$companyAddress | Visit us for all your printing needs',
            style:  pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== Single Project Specifications Section ====================
  static pw.Widget _buildSpecificationsSection(CustomerModel project) {
    return _buildSectionContainer(
      'SPECIFICATIONS',
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Room:', project.room),
          pw.SizedBox(height: 4),
          _buildInfoRow('Description:', project.fileType),
        ],
      ),
    );
  }

  // ==================== Single Project Financial Summary ====================
  static pw.Widget _buildSingleProjectFinancialSummary(CustomerModel project) {
    return _buildSectionContainer(
      'FINANCIAL SUMMARY',
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _lightBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          children: [
            _buildFinancialDetailRow('Rate per Sq.Ft:', 'Rs ${project.rate.toStringAsFixed(2)}'),
            pw.SizedBox(height: 6),
            _buildFinancialDetailRow('Total Area:', '${project.totalSqFt.toStringAsFixed(2)} sq.ft'),
            pw.SizedBox(height: 6),
            _buildFinancialDetailRow('Additional Charges:', 'Rs ${project.additionalCharges.toStringAsFixed(2)}'),
            pw.SizedBox(height: 6),
            _buildFinancialDetailRow('Total Amount:', 'Rs ${project.totalAmount.toStringAsFixed(2)}', isTotal: true),
            pw.SizedBox(height: 6),
            _buildFinancialDetailRow('Advance:', 'Rs ${project.advance.toStringAsFixed(2)}'),
            pw.SizedBox(height: 6),
            _buildFinancialDetailRow(
              'Remaining Balance:',
              'Rs ${project.remainingBalance.toStringAsFixed(2)}',
              isHighlighted: project.remainingBalance > 0,
              isTotal: true,
            ),
          ],
        ),
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
          child,
        ],
      ),
    );
  }

  // ==================== Information Row ====================
  static pw.Row _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$label ',
          style: _labelStyle,
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: _valueStyle,
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
              _buildTableCell(dim['wall']?.toString() ?? 'N/A'),
              _buildTableCell(width.toStringAsFixed(2)),
              _buildTableCell(height.toStringAsFixed(2)),
              _buildTableCell(quantity.toString()),
              _buildTableCell(sqFt.toStringAsFixed(2)),
              _buildTableCell('${area.toStringAsFixed(2)} sq.ft'),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 8,
          color: PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // ==================== Party Projects PDF ====================
  static Future<Uint8List> generatePartyProjectsPdf({
    required PartyModel party,
    required List<CustomerModel> projects,
    Uint8List? logoBytes,
  }) async {
    final pdf = pw.Document();

    // Calculate summary
    final totalInventory = projects.length;

    double totalRoofSqFt = 0;
    double totalWallsSqFt = 0;
    double totalRoofAmount = 0;
    double totalWallsAmount = 0;
    double totalAdvance = 0;
    double totalRemaining = 0;

    // Calculate roof and walls for each project
    for (var project in projects) {
      double roofArea = 0;
      double wallsArea = 0;

      for (var dim in project.dimensions) {
        final wallName = (dim['wall']?.toString() ?? '').toLowerCase();
        final sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0;

        if (wallName.contains('roof')) {
          roofArea += sqFt;
        } else {
          wallsArea += sqFt;
        }
      }

      totalRoofSqFt += roofArea;
      totalWallsSqFt += wallsArea;
      totalRoofAmount += roofArea * project.rate;
      totalWallsAmount += wallsArea * project.rate;
      totalAdvance += project.advance;
      totalRemaining += project.remainingBalance;
    }

    // Load logo image
    pw.ImageProvider? logoImage;
    if (logoBytes != null && logoBytes.isNotEmpty) {
      logoImage = pw.MemoryImage(logoBytes);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        build: (pw.Context context) {
          return [
            // Header
            _buildNewHeader(logoImage: logoImage),

            // Party Information
            _buildPartyInfoSection(party),

            // Summary Section
            _buildPartySummarySection(
              totalInventory: totalInventory,
              roofSqFt: totalRoofSqFt,
              wallsSqFt: totalWallsSqFt,
              roofAmount: totalRoofAmount,
              wallsAmount: totalWallsAmount,
              totalAdvance: totalAdvance,
              totalRemaining: totalRemaining,
            ),

            // Inventory Details for each project
            ...projects.map((project) {
              return _buildInventoryDetailsSection(project);
            }).toList(),

            // Business Lines Footer
            _buildBusinessLinesFooter(),
          ];
        },
      ),
    );

    return pdf.save();
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
    Uint8List? logoBytes,
  }) async {
    final pdf = pw.Document();

    // Create CustomerModel from parameters
    final project = CustomerModel(
      id: '',
      customerName: customerName,
      phone: phone,
      address: address,
      date: date,
      room: room,
      fileType: fileType,
      rate: double.parse(rate),
      additionalCharges: double.parse(additionalCharges),
      advance: double.parse(advance),
      totalSqFt: double.parse(totalSqFt),
      totalAmount: double.parse(totalAmount),
      remainingBalance: double.parse(remainingBalance),
      dimensions: dimensions,
      paymentHistory: paymentHistory,
    );

    // Create PartyModel for single project
    final party = PartyModel(
      id: '',
      name: customerName,
      type: 'customer',
      phone: phone,
      address: address,
      date: date,
      totalAmount: double.parse(totalAmount),
      totalAdvance: double.parse(advance),
      totalRemaining: double.parse(remainingBalance),
    );

    // Load logo image
    pw.ImageProvider? logoImage;
    if (logoBytes != null && logoBytes.isNotEmpty) {
      logoImage = pw.MemoryImage(logoBytes);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildNewHeader(logoImage: logoImage),

              // Party Information
              _buildPartyInfoSection(party),

              // Specifications
              _buildSpecificationsSection(project),

              // Dimensions Section
              if (project.dimensions.isNotEmpty) ...[
                _buildSectionContainer(
                  'DIMENSIONS',
                  _buildDimensionsTable(project.dimensions),
                ),
              ],

              // Financial Summary
              _buildSingleProjectFinancialSummary(project),

              // Business Lines Footer
              _buildBusinessLinesFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
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
            const SnackBar(
              content: Text('PDF saved successfully!'),
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

  // Helper function to get application documents directory
  static Future<Directory> getApplicationDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
}