// // pdf_service.dart
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:intl/intl.dart';
//
// import 'Model class.dart';
// import 'Party Model.dart';
// import 'PartyWithProjects.dart';
//
//
// class PdfService {
//   static final PdfColor _primaryColor = PdfColor.fromInt(0xFFFFA500);
//   static final PdfColor _secondaryColor = PdfColor.fromInt(0xFF4A6572);
//   static final PdfColor _accentColor = PdfColor.fromInt(0xFF0D47A1);
//   static final PdfColor _lightBg = PdfColor.fromInt(0xFFF5F5F5);
//   static final PdfColor _darkText = PdfColor.fromInt(0xFF263238);
//
//   static pw.TextStyle get _headerStyle => pw.TextStyle(
//     fontSize: 24,
//     fontWeight: pw.FontWeight.bold,
//     color: _primaryColor,
//   );
//
//   static pw.TextStyle get _titleStyle => pw.TextStyle(
//     fontSize: 18,
//     fontWeight: pw.FontWeight.bold,
//     color: _secondaryColor,
//   );
//
//   static pw.TextStyle get _sectionTitleStyle => pw.TextStyle(
//     fontSize: 16,
//     fontWeight: pw.FontWeight.bold,
//     color: _accentColor,
//   );
//
//   static pw.TextStyle get _detailLabelStyle => pw.TextStyle(
//     fontWeight: pw.FontWeight.bold,
//     color: _darkText,
//   );
//
//   static pw.TextStyle get _totalStyle => pw.TextStyle(
//     fontWeight: pw.FontWeight.bold,
//     color: _primaryColor,
//     fontSize: 16,
//   );
//
//   // Load image as pw.Image widget
//   static Future<pw.Image> _loadImage(String assetPath) async {
//     final ByteData data = await rootBundle.load(assetPath);
//     final Uint8List bytes = data.buffer.asUint8List();
//     return pw.Image(pw.MemoryImage(bytes));
//   }
//
//   static List<pw.Widget> _buildProjectContent(
//       String customerName,
//       String phone,
//       String address,
//       String date,
//       String room,
//       String fileType,
//       String rate,
//       String additionalCharges,
//       String advance,
//       String totalSqFt,
//       String totalAmount,
//       String remainingBalance,
//       List<Map<String, dynamic>> dimensions,
//       ) {
//     return [
//       pw.Container(
//           child: pw.Text('Details', style: _titleStyle),
//       padding: const pw.EdgeInsets.all(10),
//       decoration: pw.BoxDecoration(
//         color: _lightBg,
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
//       ),
//       ),
//       pw.SizedBox(height: 15),
//       _buildPdfSection('Party Information', [
//         _buildPdfDetailRow('Name:', customerName),
//         _buildPdfDetailRow('Phone:', phone),
//         _buildPdfDetailRow('Address:', address),
//         _buildPdfDetailRow('Date:', date),
//       ]),
//       pw.SizedBox(height: 20),
//       _buildPdfSection('Specifications', [
//         _buildPdfDetailRow('Room:', room),
//         _buildPdfDetailRow('Material Type:', fileType),
//       ]),
//       pw.SizedBox(height: 20),
//       _buildPdfSection('Dimensions', [
//         pw.Table(
//           border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
//           children: [
//             pw.TableRow(
//               decoration: pw.BoxDecoration(color: _secondaryColor),
//               children: [
//                 _buildTableHeaderCell('Wall'),
//                 _buildTableHeaderCell('Width'),
//                 _buildTableHeaderCell('Height'),
//                 _buildTableHeaderCell('Qty'),
//                 _buildTableHeaderCell('Sq.Ft'),
//               ],
//             ),
//             for (var dim in dimensions)
//               pw.TableRow(
//                 children: [
//                   _buildTableCell(dim['wall']?.toString() ?? 'N/A'),
//                   _buildTableCell(dim['width']?.toString() ?? '0'),
//                   _buildTableCell(dim['height']?.toString() ?? '0'),
//                   _buildTableCell(dim['quantity']?.toString() ?? '1'),
//                   _buildTableCell(dim['sqFt']?.toString() ?? '0'),
//                 ],
//               ),
//           ],
//         ),
//       ]),
//       pw.SizedBox(height: 20),
//       _buildPdfSection('Financial Summary', [
//         _buildPdfAmountRow('Rate per Sq.ft:', 'Rs$rate'),
//         _buildPdfAmountRow('Total Area:', '$totalSqFt sq.ft'),
//         _buildPdfAmountRow('Additional Charges:', 'Rs$additionalCharges'),
//         _buildPdfAmountRow('Total Amount:', 'Rs$totalAmount'),
//         _buildPdfAmountRow('Advance:', 'Rs$advance'),
//         _buildPdfAmountRow('Remaining Balance:', 'Rs$remainingBalance',
//             isTotal: true),
//       ]),
//       pw.SizedBox(height: 30),
//       pw.Center(
//         child: pw.Text('Thank you for choosing Graphics Lab!',
//             style: pw.TextStyle(
//                   color: _primaryColor)),
//       )
//     ];
//   }
//
//   static pw.Widget _buildTableHeaderCell(String text) {
//     return pw.Container(
//         alignment: pw.Alignment.center,
//         padding: const pw.EdgeInsets.all(6),
//         child: pw.Text(text,
//           style: _detailLabelStyle.copyWith(color: PdfColors.white),
//         ));
//   }
//
//   static pw.Widget _buildTableCell(String text) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(6),
//       child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
//     );
//   }
//
//   static Future<Uint8List> generateInventoryPdf({
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
//   }) async {
//     final pdf = pw.Document();
//     final logo = await _loadImage('assets/images/logos.png');
//
//     pdf.addPage(
//       pw.MultiPage(
//                 pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(30),
//         header: (context) => pw.Container(
//           alignment: pw.Alignment.center,
//           margin: const pw.EdgeInsets.only(bottom: 20),
//           child: pw.Column(
//             children: [
//               pw.Row(
//                 children: [
//                   pw.Container(
//                     child: logo,
//                     width: 60,
//                     height: 60,
//
//                     decoration: pw.BoxDecoration(
//                       shape: pw.BoxShape.circle,
//                       border: pw.Border.all(color: _primaryColor, width: 2),
//                       boxShadow: [
//                         pw.BoxShadow(
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                         )
//                       ]
//                    )
//                   ),
//                   pw.SizedBox(width: 15),
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('Graphics Lab', style: _headerStyle),
//                       pw.Text('From Designing To Printing, Exactly According To Your Idea',
//                           style: pw.TextStyle(color: _secondaryColor)),
//                     ],
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//         footer: (context) => pw.Container(
//           alignment: pw.Alignment.center,
//           margin: const pw.EdgeInsets.only(top: 20),
//           child: pw.Text(
//             'Page ${context.pageNumber} of ${context.pagesCount}',
//             style: const pw.TextStyle(color: PdfColors.grey),
//           ),
//         ),
//
//         build: (context) => _buildProjectContent(
//           customerName,
//           phone,
//           address,
//           date,
//           room,
//           fileType,
//           rate,
//           additionalCharges,
//           advance,
//           totalSqFt,
//           totalAmount,
//           remainingBalance,
//           dimensions,
//         ),
//       ),
//     );
//
//     return pdf.save();
//   }
//
//
//
//   static Future<Uint8List> generateCategoryPdf({
//     required List<PartyWithProjects> partiesWithProjects,
//     required String category,
//     required List<PartyModel> parties,
//   }) async {
//     final pdf = pw.Document();
//     final logo = await _loadImage('assets/images/logos.png');
//     final currencyFormat = NumberFormat.currency(symbol: 'Rs', decimalDigits: 2);
//     final now = DateTime.now();
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(30),
//         build: (context) {
//           // Calculate totals
//           final totalParties = partiesWithProjects.length;
//           final totalProjects = partiesWithProjects.fold(0, (sum, party) => sum + party.projectCount);
//           final totalAmount = partiesWithProjects.fold(0.0, (sum, party) => sum + party.totalAmount);
//           final totalAdvance = partiesWithProjects.fold(0.0, (sum, party) => sum + party.totalAdvance);
//           final totalRemaining = partiesWithProjects.fold(0.0, (sum, party) => sum + party.totalRemaining);
//           final totalSqFt = partiesWithProjects.fold(0.0, (sum, party) => sum + party.totalSqFt);
//
//           return [
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 // Header with logo and company info
//                 pw.Row(
//                   children: [
//                     pw.Container(
//                       child: logo,
//                       width: 60,
//                       height: 60,
//                       decoration: pw.BoxDecoration(
//                         shape: pw.BoxShape.circle,
//                         border: pw.Border.all(color: _primaryColor, width: 2),
//                       ),
//                     ),
//                     pw.SizedBox(width: 15),
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text('Graphics Lab', style: _headerStyle),
//                         pw.Text('$category Report',
//                             style: pw.TextStyle(color: _secondaryColor)),
//                         pw.Text('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(now)}',
//                             style: const pw.TextStyle(fontSize: 10)),
//                       ],
//                     )
//                   ],
//                 ),
//                 pw.SizedBox(height: 30),
//
//                 // Overall Summary Section
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(15),
//                   decoration: pw.BoxDecoration(
//                     color: _lightBg,
//                     borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
//                   ),
//                   child: pw.Column(
//                     children: [
//                       _buildPdfSummaryRow('Total Parties:', totalParties.toString()),
//                       _buildPdfSummaryRow('Total Projects:', totalProjects.toString()),
//                       _buildPdfSummaryRow('Total Square Feet:', totalSqFt.toStringAsFixed(2)),
//                       _buildPdfSummaryRow('Total Amount:', currencyFormat.format(totalAmount)),
//                       _buildPdfSummaryRow('Total Advance:', currencyFormat.format(totalAdvance)),
//                       _buildPdfSummaryRow('Total Remaining:', currencyFormat.format(totalRemaining), isHighlighted: true),
//                     ],
//                   ),
//                 ),
//                 pw.SizedBox(height: 30),
//
//                 // Detailed Party List
//                 for (var partyData in partiesWithProjects) ...[
//                   pw.Text('${partyData.party.name}', style: _sectionTitleStyle),
//                   pw.SizedBox(height: 10),
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(12),
//                     decoration: pw.BoxDecoration(
//                       border: pw.Border.all(color: PdfColors.grey300),
//                       borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
//                     ),
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         _buildPdfDetailRow('Type:', partyData.party.type.toUpperCase()),
//                         _buildPdfDetailRow('Phone:', partyData.party.phone),
//                         _buildPdfDetailRow('Address:', partyData.party.address),
//                         _buildPdfDetailRow('Created:', partyData.party.date),
//                         _buildPdfDetailRow('ID:', partyData.party.id),
//                         pw.SizedBox(height: 10),
//                         pw.Divider(color: _primaryColor, height: 1),
//                         pw.SizedBox(height: 10),
//
//                         // Projects Summary for this party
//                         pw.Text('Projects (${partyData.projectCount}):',
//                             style: _detailLabelStyle.copyWith(color: _accentColor)),
//                         pw.SizedBox(height: 8),
//
//                         // Project details table
//                         pw.Table(
//                           border: pw.TableBorder.all(color: PdfColors.grey300),
//                           columnWidths: {
//                             0: const pw.FlexColumnWidth(2),
//                             1: const pw.FlexColumnWidth(1.5),
//                             2: const pw.FlexColumnWidth(1),
//                             3: const pw.FlexColumnWidth(1),
//                           },
//                           children: [
//                             pw.TableRow(
//                               decoration: pw.BoxDecoration(color: _secondaryColor),
//                               children: [
//                                 _buildTableHeaderCell('Date & Room'),
//                                 _buildTableHeaderCell('Material'),
//                                 _buildTableHeaderCell('Amount'),
//                                 _buildTableHeaderCell('Balance'),
//                               ],
//                             ),
//                             for (var project in partyData.projects)
//                               pw.TableRow(
//                                 children: [
//                                   _buildTableCell('${project.date}\n${project.room}'),
//                                   _buildTableCell(project.fileType),
//                                   _buildTableCell(currencyFormat.format(project.totalAmount)),
//                                   _buildTableCell(currencyFormat.format(project.remainingBalance)),
//                                 ],
//                               ),
//                           ],
//                         ),
//
//                         // Party financial summary
//                         pw.SizedBox(height: 15),
//                         pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text('Party Totals:', style: _detailLabelStyle),
//                             pw.Text('Inventory: ${partyData.projectCount}', style: _detailLabelStyle),
//                             pw.Text('SqFt: ${partyData.totalSqFt.toStringAsFixed(2)}', style: _detailLabelStyle),
//                             pw.Text('Amount: ${currencyFormat.format(partyData.totalAmount)}',
//                                 style: _totalStyle),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   pw.SizedBox(height: 20),
//                 ],
//                 pw.SizedBox(height: 20),
//                 pw.Center(
//                   child: pw.Text('End of Report',
//                       style: pw.TextStyle(
//                         color: _primaryColor,
//                         fontSize: 16,
//                       )),
//                 )
//               ],
//             )
//           ];
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
//
// // Helper widget for summary rows
//   static pw.Widget _buildPdfSummaryRow(String label, String value, {bool isHighlighted = false}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 6),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(label, style: isHighlighted ? _totalStyle : _detailLabelStyle),
//           pw.Text(value, style: isHighlighted ? _totalStyle : null),
//         ],
//       ),
//     );
//   }
//
//   static Future<Uint8List> generatePartyPdf({
//     required PartyModel party,
//     required List<CustomerModel> projects,
//   }) async {
//     final pdf = pw.Document();
//     final currencyFormat = NumberFormat.currency(symbol: 'Rs', decimalDigits: 2);
//     final totalProjects = projects.length;
//     final logo = await _loadImage('assets/images/logos.png');
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(30),
//         build: (context) {
//           return [
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Row(
//                   children: [
//                     pw.Container(
//                         child: logo,
//                         width: 60,
//                         height: 60,
//
//                         decoration: pw.BoxDecoration(
//                             shape: pw.BoxShape.circle,
//                             border: pw.Border.all(color: _primaryColor, width: 2),
//                             boxShadow: [
//                               pw.BoxShadow(
//                                 blurRadius: 10,
//                                 spreadRadius: 2,
//                               )
//                             ]
//                         )
//                     ),
//                     pw.SizedBox(width: 15),
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text('Graphics Lab', style: _headerStyle),
//                         pw.Text('From Designing To Printing, Exactly According To Your Idea',
//                             style: pw.TextStyle(color: _secondaryColor)),
//                       ],
//                     )
//                   ],
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(15),
//                   decoration: pw.BoxDecoration(
//                     color: _lightBg,
//                     borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
//                   ),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('${party.type.toUpperCase()} DETAILS',
//                           style: _titleStyle.copyWith(color: _accentColor)),
//                       pw.Divider(color: _primaryColor, height: 1.5),
//                       pw.SizedBox(height: 10),
//                       _buildPdfDetailRow('Name:', party.name),
//                       _buildPdfDetailRow('Phone:', party.phone),
//                       _buildPdfDetailRow('Address:', party.address),
//                       _buildPdfDetailRow('Date:', DateFormat('dd MMM yyyy').format(DateTime.now())),
//                     ],
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(15),
//                   decoration: pw.BoxDecoration(
//                     color: _lightBg,
//                     borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
//                   ),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('SUMMARY',
//                           style: _titleStyle.copyWith(color: _accentColor)),
//                       pw.Divider(color: _primaryColor, height: 1.5),
//                       pw.SizedBox(height: 10),
//                       _buildPdfAmountRow('Total Inventory:', totalProjects.toString()),
//                       _buildPdfAmountRow('Total Amount:', currencyFormat.format(projects.fold(0.0, (sum, item) => sum + (item.totalAmount)))),
//                       _buildPdfAmountRow('Total Advance:', currencyFormat.format(projects.fold(0.0, (sum, item) => sum + (item.advance)))),
//                       _buildPdfAmountRow('Total Remaining Balance:', currencyFormat.format(projects.fold(0.0, (sum, item) => sum + (item.remainingBalance))), isTotal: true),
//                     ],
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 ...projects.map((project) => pw.Container(
//                   margin: const pw.EdgeInsets.only(bottom: 10),
//                   padding: const pw.EdgeInsets.all(15),
//                   decoration: pw.BoxDecoration(
//                     border: pw.Border.all(color: PdfColors.grey300),
//                     borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
//                   ),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pw.Text(project.date, style: _detailLabelStyle),
//                           pw.Text('Room: ${project.room}'),
//                         ],
//                       ),
//                       pw.SizedBox(height: 8),
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pw.Text('Material:', style: _detailLabelStyle),
//                           pw.Text(project.fileType),
//                         ],
//                       ),
//                       pw.SizedBox(height: 8),
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pw.Text('Amount:', style: _detailLabelStyle),
//                           pw.Text('Rs${project.totalAmount.toStringAsFixed(2)}'),
//                         ],
//                       ),
//                       pw.SizedBox(height: 8),
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pw.Text('Balance:', style: _detailLabelStyle),
//                           pw.Text('Rs${project.remainingBalance.toStringAsFixed(2)}',
//                               style: pw.TextStyle(color: _primaryColor)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )).toList(),
//                 pw.SizedBox(height: 30),
//                 pw.Center(
//                   child: pw.Text('Thank you for choosing Graphics Lab!',
//                       style: pw.TextStyle(
//
//                           color: _primaryColor,
//                           fontSize: 16)),
//                 )
//               ],
//             )];
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
//
//   static pw.Widget _buildPdfSection(String title, List<pw.Widget> children) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(title, style: _sectionTitleStyle),
//         pw.SizedBox(height: 8),
//         ...children,
//       ],
//     );
//   }
//
//   static pw.Widget _buildPdfDetailRow(String label, String value) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 4),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Text(label, style: _detailLabelStyle),
//           pw.SizedBox(width: 10),
//           pw.Expanded(
//             child: pw.Text(value),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static pw.Widget _buildPdfAmountRow(String label, String value, {bool isTotal = false}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 6),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(label, style: isTotal ? _totalStyle : _detailLabelStyle),
//           pw.Text(value, style: isTotal ? _totalStyle : null),
//         ],
//       ),
//     );
//   }
//
//   static Future<void> sharePdf(Uint8List pdfBytes, String filename) async {
//     await Printing.sharePdf(bytes: pdfBytes, filename: filename);
//   }
//
// // Add this method to PdfService.dart
//   static Future<Uint8List> generatePartyProjectsPdf({
//     required PartyModel party,
//     required List<CustomerModel> projects,
//   }) async {
//     final pdf = pw.Document();
//     final logo = await _loadImage('assets/images/logos.png');
//     final currencyFormat = NumberFormat.currency(symbol: 'Rs', decimalDigits: 2);
//
//     // Calculate totals
//     double totalRoofSqFt = 0.0;
//     double totalWallSqFt = 0.0;
//     double totalRoofAmount = 0.0;
//     double totalWallAmount = 0.0;
//     double totalAdvance = 0.0;
//     double totalRemaining = 0.0;
//
//     for (var project in projects) {
//       // Calculate roof and wall areas for each project
//       double projectRoofSqFt = 0.0;
//       double projectWallSqFt = 0.0;
//
//       for (var dim in project.dimensions) {
//         String wallName = dim['wall']?.toString().toLowerCase() ?? '';
//         double sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0.0;
//
//         if (wallName.contains('roof')) {
//           projectRoofSqFt += sqFt;
//         } else {
//           projectWallSqFt += sqFt;
//         }
//       }
//
//       // Calculate roof and wall amounts
//       double roofAmount = projectRoofSqFt * project.rate;
//       double wallAmount = projectWallSqFt * project.rate;
//
//       // Accumulate totals
//       totalRoofSqFt += projectRoofSqFt;
//       totalWallSqFt += projectWallSqFt;
//       totalRoofAmount += roofAmount;
//       totalWallAmount += wallAmount;
//       totalAdvance += project.advance;
//       totalRemaining += project.remainingBalance;
//     }
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(30),
//         build: (context) {
//           // Create project widgets
//           List<pw.Widget> projectWidgets = [];
//
//           for (var project in projects) {
//             // Calculate for this specific project
//             double projectRoofSqFt = 0.0;
//             double projectWallSqFt = 0.0;
//
//             for (var dim in project.dimensions) {
//               String wallName = dim['wall']?.toString().toLowerCase() ?? '';
//               double sqFt = double.tryParse(dim['sqFt']?.toString() ?? '0') ?? 0.0;
//
//               if (wallName.contains('roof')) {
//                 projectRoofSqFt += sqFt;
//               } else {
//                 projectWallSqFt += sqFt;
//               }
//             }
//
//             projectWidgets.add(
//               pw.Container(
//                 margin: const pw.EdgeInsets.only(bottom: 15),
//                 padding: const pw.EdgeInsets.all(12),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey300),
//                   borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
//                 ),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Row(
//                       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                       children: [
//                         pw.Text(project.date, style: _detailLabelStyle),
//                         pw.Text('Room: ${project.room}', style: _detailLabelStyle),
//                       ],
//                     ),
//                     pw.SizedBox(height: 8),
//                     pw.Row(
//                       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                       children: [
//                         pw.Text('Material:', style: _detailLabelStyle),
//                         pw.Text(project.fileType),
//                       ],
//                     ),
//                     pw.SizedBox(height: 8),
//
//                     // Project-specific roof/wall summary
//                     pw.SizedBox(height: 10),
//                     pw.Text('Area Breakdown:', style: _detailLabelStyle.copyWith(color: _accentColor)),
//                     pw.SizedBox(height: 8),
//                     _buildPdfSummaryRow('Roof Area:', '${projectRoofSqFt.toStringAsFixed(2)} sq.ft'),
//                     _buildPdfSummaryRow('Wall Area:', '${projectWallSqFt.toStringAsFixed(2)} sq.ft'),
//                     pw.SizedBox(height: 8),
//
//                     // Dimensions table
//                     pw.Text('Dimensions:', style: _detailLabelStyle.copyWith(color: _accentColor)),
//                     pw.SizedBox(height: 8),
//                     pw.Table(
//                       border: pw.TableBorder.all(color: PdfColors.grey300),
//                       columnWidths: {
//                         0: const pw.FlexColumnWidth(1.5),
//                         1: const pw.FlexColumnWidth(1),
//                         2: const pw.FlexColumnWidth(1),
//                         3: const pw.FlexColumnWidth(1),
//                         4: const pw.FlexColumnWidth(1),
//                       },
//                       children: [
//                         pw.TableRow(
//                           decoration: pw.BoxDecoration(color: _secondaryColor),
//                           children: [
//                             _buildTableHeaderCell('Wall'),
//                             _buildTableHeaderCell('Width'),
//                             _buildTableHeaderCell('Height'),
//                             _buildTableHeaderCell('Qty'),
//                             _buildTableHeaderCell('Sq.Ft'),
//                           ],
//                         ),
//                         ...project.dimensions.map((dim) =>
//                             pw.TableRow(
//                               children: [
//                                 _buildTableCell(dim['wall']?.toString() ?? ''),
//                                 _buildTableCell(dim['width']?.toString() ?? ''),
//                                 _buildTableCell(dim['height']?.toString() ?? ''),
//                                 _buildTableCell(dim['quantity']?.toString() ?? ''),
//                                 _buildTableCell(dim['sqFt']?.toString() ?? ''),
//                               ],
//                             )
//                         ).toList(),
//                       ],
//                     ),
//                     pw.SizedBox(height: 15),
//
//                     // Financial summary
//                     _buildPdfSummaryRow('Rate per sq.ft:', currencyFormat.format(project.rate)),
//                     _buildPdfSummaryRow('Additional Charges:', currencyFormat.format(project.additionalCharges)),
//                     _buildPdfSummaryRow('Advance:', currencyFormat.format(project.advance)),
//                     _buildPdfSummaryRow('Total Amount:', currencyFormat.format(project.totalAmount)),
//                     _buildPdfSummaryRow('Remaining Balance:', currencyFormat.format(project.remainingBalance), isHighlighted: true),
//                   ],
//                 ),
//               ),
//             );
//           }
//
//           return [
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 // Header with logo and company info
//                 pw.Row(
//                   children: [
//                     pw.Container(
//                       child: logo,
//                       width: 60,
//                       height: 60,
//                       decoration: pw.BoxDecoration(
//                         shape: pw.BoxShape.circle,
//                         border: pw.Border.all(color: _primaryColor, width: 2),
//                       ),
//                     ),
//                     pw.SizedBox(width: 15),
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text('Graphics Lab', style: _headerStyle),
//                         pw.Text('${party.name} - Report',
//                             style: pw.TextStyle(color: _secondaryColor)),
//                         pw.Text('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
//                             style: const pw.TextStyle(fontSize: 10)),
//                       ],
//                     )
//                   ],
//                 ),
//                 pw.SizedBox(height: 30),
//
//                 // Party Information
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(15),
//                   decoration: pw.BoxDecoration(
//                     color: _lightBg,
//                     borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
//                   ),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('PARTY INFORMATION', style: _sectionTitleStyle),
//                       pw.Divider(color: _primaryColor, height: 1),
//                       pw.SizedBox(height: 10),
//                       _buildPdfDetailRow('Name:', party.name),
//                       _buildPdfDetailRow('Type:', party.type.toUpperCase()),
//                       _buildPdfDetailRow('Phone:', party.phone),
//                       _buildPdfDetailRow('Address:', party.address),
//                       _buildPdfDetailRow('Created:', party.date),
//                     ],
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//
//                 // Summary Section
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(15),
//                   decoration: pw.BoxDecoration(
//                     color: _lightBg,
//                     borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
//                   ),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('SUMMARY', style: _sectionTitleStyle),
//                       pw.Divider(color: _primaryColor, height: 1),
//                       pw.SizedBox(height: 10),
//                       _buildPdfSummaryRow('Total Inventory:', projects.length.toString()),
//                       _buildPdfSummaryRow('Roofs Square Feet:', totalRoofSqFt.toStringAsFixed(2)),
//                       _buildPdfSummaryRow('Walls Square Feet:', totalWallSqFt.toStringAsFixed(2)),
//                       _buildPdfSummaryRow('Roof Amount:', currencyFormat.format(totalRoofAmount)),
//                       _buildPdfSummaryRow('Walls Amount:', currencyFormat.format(totalWallAmount)),
//                       _buildPdfSummaryRow('Total Advance:', currencyFormat.format(totalAdvance)),
//                       _buildPdfSummaryRow('Total Remaining:', currencyFormat.format(totalRemaining), isHighlighted: true),
//                     ],
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//
//                 // Projects List
//                 pw.Text('INVENTORY DETAILS', style: _sectionTitleStyle),
//                 pw.SizedBox(height: 10),
//                 ...projectWidgets, // Add all project widgets here
//
//                 pw.SizedBox(height: 30),
//                 pw.Center(
//                   child: pw.Text('End of Report',
//                       style: pw.TextStyle(
//                         color: _primaryColor,
//                         fontSize: 16,
//                       )),
//                 )
//               ],
//             )
//           ];
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
// //   static Future<Uint8List> generatePartyProjectsPdf({
// //     required PartyModel party,
// //     required List<CustomerModel> projects,
// //   }) async {
// //     final pdf = pw.Document();
// //     final logo = await _loadImage('assets/images/logos.png');
// //     final currencyFormat = NumberFormat.currency(symbol: 'Rs', decimalDigits: 2);
// //
// //     // Calculate totals
// //     double totalAmount = 0;
// //     double totalAdvance = 0;
// //     double totalRemaining = 0;
// //     double totalSqFt = 0;
// //
// //     for (var project in projects) {
// //       totalAmount += project.totalAmount;
// //       totalAdvance += project.advance;
// //       totalRemaining += project.remainingBalance;
// //       totalSqFt += project.totalSqFt;
// //     }
// //
// //     pdf.addPage(
// //       pw.MultiPage(
// //         pageFormat: PdfPageFormat.a4,
// //         margin: const pw.EdgeInsets.all(30),
// //         build: (context) {
// //           return [
// //             pw.Column(
// //               crossAxisAlignment: pw.CrossAxisAlignment.start,
// //               children: [
// //                 // Header with logo and company info
// //                 pw.Row(
// //                   children: [
// //                     pw.Container(
// //                       child: logo,
// //                       width: 60,
// //                       height: 60,
// //                       decoration: pw.BoxDecoration(
// //                         shape: pw.BoxShape.circle,
// //                         border: pw.Border.all(color: _primaryColor, width: 2),
// //                       ),
// //                     ),
// //                     pw.SizedBox(width: 15),
// //                     pw.Column(
// //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                       children: [
// //                         pw.Text('Graphics Lab', style: _headerStyle),
// //                         pw.Text('${party.name} - Projects Report',
// //                             style: pw.TextStyle(color: _secondaryColor)),
// //                         pw.Text('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
// //                             style: const pw.TextStyle(fontSize: 10)),
// //                       ],
// //                     )
// //                   ],
// //                 ),
// //                 pw.SizedBox(height: 30),
// //
// //                 // Party Information
// //                 pw.Container(
// //                   padding: const pw.EdgeInsets.all(15),
// //                   decoration: pw.BoxDecoration(
// //                     color: _lightBg,
// //                     borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
// //                   ),
// //                   child: pw.Column(
// //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                     children: [
// //                       pw.Text('PARTY INFORMATION', style: _sectionTitleStyle),
// //                       pw.Divider(color: _primaryColor, height: 1),
// //                       pw.SizedBox(height: 10),
// //                       _buildPdfDetailRow('Name:', party.name),
// //                       _buildPdfDetailRow('Type:', party.type.toUpperCase()),
// //                       _buildPdfDetailRow('Phone:', party.phone),
// //                       _buildPdfDetailRow('Address:', party.address),
// //                       _buildPdfDetailRow('Created:', party.date),
// //                     ],
// //                   ),
// //                 ),
// //                 pw.SizedBox(height: 20),
// //
// //                 // Summary Section
// //                 pw.Container(
// //                   padding: const pw.EdgeInsets.all(15),
// //                   decoration: pw.BoxDecoration(
// //                     color: _lightBg,
// //                     borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
// //                   ),
// //                   child: pw.Column(
// //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                     children: [
// //                       pw.Text('PROJECTS SUMMARY', style: _sectionTitleStyle),
// //                       pw.Divider(color: _primaryColor, height: 1),
// //                       pw.SizedBox(height: 10),
// //                       _buildPdfSummaryRow('Total Projects:', projects.length.toString()),
// //                       _buildPdfSummaryRow('Total Square Feet:', totalSqFt.toStringAsFixed(2)),
// //                       _buildPdfSummaryRow('Total Amount:', currencyFormat.format(totalAmount)),
// //                       _buildPdfSummaryRow('Total Advance:', currencyFormat.format(totalAdvance)),
// //                       _buildPdfSummaryRow('Total Remaining:', currencyFormat.format(totalRemaining), isHighlighted: true),
// //                     ],
// //                   ),
// //                 ),
// //                 pw.SizedBox(height: 20),
// //
// //                 // Projects List
// //                 pw.Text('PROJECT DETAILS', style: _sectionTitleStyle),
// //                 pw.SizedBox(height: 10),
// //
// //                 for (var project in projects) ...[
// //                   pw.Container(
// //                     margin: const pw.EdgeInsets.only(bottom: 15),
// //                     padding: const pw.EdgeInsets.all(12),
// //                     decoration: pw.BoxDecoration(
// //                       border: pw.Border.all(color: PdfColors.grey300),
// //                       borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
// //                     ),
// //                     child: pw.Column(
// //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
// //                       children: [
// //                         pw.Row(
// //                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             pw.Text(project.date, style: _detailLabelStyle),
// //                             pw.Text('Room: ${project.room}', style: _detailLabelStyle),
// //                           ],
// //                         ),
// //                         pw.SizedBox(height: 8),
// //                         pw.Row(
// //                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             pw.Text('Material:', style: _detailLabelStyle),
// //                             pw.Text(project.fileType),
// //                           ],
// //                         ),
// //                         pw.SizedBox(height: 8),
// //
// //                         // Dimensions table
// //                         pw.Text('Dimensions:', style: _detailLabelStyle.copyWith(color: _accentColor)),
// //                         pw.SizedBox(height: 8),
// //                         pw.Table(
// //                           border: pw.TableBorder.all(color: PdfColors.grey300),
// //                           columnWidths: {
// //                             0: const pw.FlexColumnWidth(1.5),
// //                             1: const pw.FlexColumnWidth(1),
// //                             2: const pw.FlexColumnWidth(1),
// //                             3: const pw.FlexColumnWidth(1),
// //                             4: const pw.FlexColumnWidth(1),
// //                           },
// //                           children: [
// //                             pw.TableRow(
// //                               decoration: pw.BoxDecoration(color: _secondaryColor),
// //                               children: [
// //                                 _buildTableHeaderCell('Wall'),
// //                                 _buildTableHeaderCell('Width'),
// //                                 _buildTableHeaderCell('Height'),
// //                                 _buildTableHeaderCell('Qty'),
// //                                 _buildTableHeaderCell('Sq.Ft'),
// //                               ],
// //                             ),
// //                             for (var dim in project.dimensions)
// //                               pw.TableRow(
// //                                 children: [
// //                                   _buildTableCell(dim['wall']?.toString() ?? ''),
// //                                   _buildTableCell(dim['width']?.toString() ?? ''),
// //                                   _buildTableCell(dim['height']?.toString() ?? ''),
// //                                   _buildTableCell(dim['quantity']?.toString() ?? ''),
// //                                   _buildTableCell(dim['sqFt']?.toString() ?? ''),
// //                                 ],
// //                               ),
// //                           ],
// //                         ),
// //                         pw.SizedBox(height: 15),
// //
// //                         // Financial summary
// //                         _buildPdfSummaryRow('Rate per sq.ft:', currencyFormat.format(project.rate)),
// //                         _buildPdfSummaryRow('Total Area:', '${project.totalSqFt.toStringAsFixed(2)} sq.ft'),
// //                         _buildPdfSummaryRow('Additional Charges:', currencyFormat.format(project.additionalCharges)),
// //                         _buildPdfSummaryRow('Advance:', currencyFormat.format(project.advance)),
// //                         _buildPdfSummaryRow('Total Amount:', currencyFormat.format(project.totalAmount)),
// //                         _buildPdfSummaryRow('Remaining Balance:', currencyFormat.format(project.remainingBalance), isHighlighted: true),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //                 pw.SizedBox(height: 30),
// //                 pw.Center(
// //                   child: pw.Text('End of Report',
// //                       style: pw.TextStyle(
// //                         color: _primaryColor,
// //                         fontSize: 16,
// //                       )),
// //                 )
// //               ],
// //             )
// //           ];
// //         },
// //       ),
// //     );
// //
// //     return pdf.save();
// //   }
// //
// // // Helper for summary rows
// //   static pw.Widget _buildPdfAllSummaryRow(String label, String value, {bool isHighlighted = false}) {
// //     return pw.Padding(
// //       padding: const pw.EdgeInsets.symmetric(vertical: 6),
// //       child: pw.Row(
// //         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
// //         children: [
// //           pw.Text(label, style: isHighlighted ? _totalStyle : _detailLabelStyle),
// //           pw.Text(value, style: isHighlighted ? _totalStyle : null),
// //         ],
// //       ),
// //     );
// //   }
// //
// }

// pdf_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html; // Web کے لیے

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'Model class.dart';
import 'Party Model.dart';
import 'PartyWithProjects.dart';

class PdfService {
  // رنگوں کی ترتیب
  static final PdfColor _primaryColor = PdfColor.fromInt(0xFFFFA500);
  static final PdfColor _secondaryColor = PdfColor.fromInt(0xFF4A6572);
  static final PdfColor _accentColor = PdfColor.fromInt(0xFF0D47A1);
  static final PdfColor _lightBg = PdfColor.fromInt(0xFFF5F5F5);
  static final PdfColor _darkText = PdfColor.fromInt(0xFF263238);

  // سٹائلز
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

  // ==================== PDF جنریشن میتھڈز ====================

  // لوگو ایمیج لوڈ کرنے کا طریقہ
  static Future<pw.Image> _loadImage(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      return pw.Image(pw.MemoryImage(bytes));
    } catch (e) {
      // اگر ایمیج نہ ملے تو خالی جگہ چھوڑ دیں
      return pw.Image(pw.MemoryImage(Uint8List(0)));
    }
  }

  // پراجیکٹ مواد بنانے کا طریقہ
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
        child: pw.Text('تفصیلات', style: _titleStyle),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: _lightBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        ),
      ),
      pw.SizedBox(height: 15),
      _buildPdfSection('پارٹی کی معلومات', [
        _buildPdfDetailRow('نام:', customerName),
        _buildPdfDetailRow('فون:', phone),
        _buildPdfDetailRow('پتہ:', address),
        _buildPdfDetailRow('تاریخ:', date),
      ]),
      pw.SizedBox(height: 20),
      _buildPdfSection('تفصیلات', [
        _buildPdfDetailRow('کمرہ:', room),
        _buildPdfDetailRow('مواد کی قسم:', fileType),
      ]),
      pw.SizedBox(height: 20),
      _buildPdfSection('پیمائشیں', [
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: _secondaryColor),
              children: [
                _buildTableHeaderCell('دیوار'),
                _buildTableHeaderCell('چوڑائی'),
                _buildTableHeaderCell('اونچائی'),
                _buildTableHeaderCell('مقدار'),
                _buildTableHeaderCell('مربع فٹ'),
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
      _buildPdfSection('مالی خلاصہ', [
        _buildPdfAmountRow('فی مربع فٹ ریٹ:', 'Rs$rate'),
        _buildPdfAmountRow('کل رقبہ:', '$totalSqFt sq.ft'),
        _buildPdfAmountRow('اضافی چارجز:', 'Rs$additionalCharges'),
        _buildPdfAmountRow('کل رقم:', 'Rs$totalAmount'),
        _buildPdfAmountRow('ایڈوانس:', 'Rs$advance'),
        _buildPdfAmountRow('باقی رقم:', 'Rs$remainingBalance',
            isTotal: true),
      ]),
      pw.SizedBox(height: 30),
      pw.Center(
        child: pw.Text('گرافکس لیب کا انتخاب کرنے کا شکریہ!',
            style: pw.TextStyle(color: _primaryColor)),
      )
    ];
  }

  // ٹیبل ہیڈر سیل
  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
        style: _detailLabelStyle.copyWith(color: PdfColors.white),
      ),
    );
  }

  // ٹیبل ڈیٹا سیل
  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
    );
  }

  // سیکشن بنانے کا طریقہ
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

  // ڈیٹیل راؤ بنانے کا طریقہ
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

  // رقم کی راؤ بنانے کا طریقہ
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

  // خلاصہ راؤ بنانے کا طریقہ
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

  // ==================== بنیادی PDF جنریشن میتھڈز ====================

  // انوینٹری PDF بنانے کا طریقہ
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
                  pw.Container(
                      child: logo,
                      width: 60,
                      height: 60,
                      decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: _primaryColor, width: 2),
                          boxShadow: [
                            pw.BoxShadow(
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                      )
                  ),
                  pw.SizedBox(width: 15),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('گرافکس لیب', style: _headerStyle),
                      pw.Text('آپ کے خیال کے مطابق ڈیزائننگ سے پرنٹنگ تک',
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
            'صفحہ ${context.pageNumber} از ${context.pagesCount}',
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

  // پارٹی PDF بنانے کا طریقہ
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
                    pw.Container(
                        child: logo,
                        width: 60,
                        height: 60,
                        decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            border: pw.Border.all(color: _primaryColor, width: 2),
                            boxShadow: [
                              pw.BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                        )
                    ),
                    pw.SizedBox(width: 15),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('گرافکس لیب', style: _headerStyle),
                        pw.Text('آپ کے خیال کے مطابق ڈیزائننگ سے پرنٹنگ تک',
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
                      pw.Text('${party.type.toUpperCase()} کی تفصیلات',
                          style: _titleStyle.copyWith(color: _accentColor)),
                      pw.Divider(color: _primaryColor, height: 1.5),
                      pw.SizedBox(height: 10),
                      _buildPdfDetailRow('نام:', party.name),
                      _buildPdfDetailRow('فون:', party.phone),
                      _buildPdfDetailRow('پتہ:', party.address),
                      _buildPdfDetailRow('تاریخ:', DateFormat('dd MMM yyyy').format(DateTime.now())),
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
                      pw.Text('خلاصہ',
                          style: _titleStyle.copyWith(color: _accentColor)),
                      pw.Divider(color: _primaryColor, height: 1.5),
                      pw.SizedBox(height: 10),
                      _buildPdfAmountRow('کل انوینٹری:', totalProjects.toString()),
                      _buildPdfAmountRow('کل رقم:', currencyFormat.format(projects.fold(0.0, (sum, item) => sum + (item.totalAmount)))),
                      _buildPdfAmountRow('کل ایڈوانس:', currencyFormat.format(projects.fold(0.0, (sum, item) => sum + (item.advance)))),
                      _buildPdfAmountRow('کل باقی رقم:', currencyFormat.format(projects.fold(0.0, (sum, item) => sum + (item.remainingBalance))), isTotal: true),
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
                          pw.Text('کمرہ: ${project.room}'),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('مواد:', style: _detailLabelStyle),
                          pw.Text(project.fileType),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('رقم:', style: _detailLabelStyle),
                          pw.Text('Rs${project.totalAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('باقی:', style: _detailLabelStyle),
                          pw.Text('Rs${project.remainingBalance.toStringAsFixed(2)}',
                              style: pw.TextStyle(color: _primaryColor)),
                        ],
                      ),
                    ],
                  ),
                )).toList(),
                pw.SizedBox(height: 30),
                pw.Center(
                  child: pw.Text('گرافکس لیب کا انتخاب کرنے کا شکریہ!',
                      style: pw.TextStyle(color: _primaryColor, fontSize: 16)),
                )
              ],
            )
          ];
        },
      ),
    );

    return pdf.save();
  }

  // پارٹی پراجیکٹس PDF بنانے کا طریقہ
  static Future<Uint8List> generatePartyProjectsPdf({
    required PartyModel party,
    required List<CustomerModel> projects,
  }) async {
    final pdf = pw.Document();
    final logo = await _loadImage('assets/images/logos.png');
    final currencyFormat = NumberFormat.currency(symbol: 'Rs', decimalDigits: 2);

    // کل اعداد و شمار
    double totalRoofSqFt = 0.0;
    double totalWallSqFt = 0.0;
    double totalRoofAmount = 0.0;
    double totalWallAmount = 0.0;
    double totalAdvance = 0.0;
    double totalRemaining = 0.0;

    for (var project in projects) {
      // ہر پراجیکٹ کے لیے چھت اور دیوار کا رقبہ
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

      // چھت اور دیوار کی رقم
      double roofAmount = projectRoofSqFt * project.rate;
      double wallAmount = projectWallSqFt * project.rate;

      // کل اعداد میں جمع کریں
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
          // پراجیکٹ ویجٹس بنائیں
          List<pw.Widget> projectWidgets = [];

          for (var project in projects) {
            // اس پراجیکٹ کے لیے حساب
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
                        pw.Text('کمرہ: ${project.room}', style: _detailLabelStyle),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('مواد:', style: _detailLabelStyle),
                        pw.Text(project.fileType),
                      ],
                    ),
                    pw.SizedBox(height: 8),

                    // پراجیکٹ کی چھت/دیوار کی تفصیل
                    pw.SizedBox(height: 10),
                    pw.Text('رقبے کی تقسیم:', style: _detailLabelStyle.copyWith(color: _accentColor)),
                    pw.SizedBox(height: 8),
                    _buildPdfSummaryRow('چھت کا رقبہ:', '${projectRoofSqFt.toStringAsFixed(2)} مربع فٹ'),
                    _buildPdfSummaryRow('دیوار کا رقبہ:', '${projectWallSqFt.toStringAsFixed(2)} مربع فٹ'),
                    pw.SizedBox(height: 8),

                    // پیمائشوں کی ٹیبل
                    pw.Text('پیمائشیں:', style: _detailLabelStyle.copyWith(color: _accentColor)),
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
                            _buildTableHeaderCell('دیوار'),
                            _buildTableHeaderCell('چوڑائی'),
                            _buildTableHeaderCell('اونچائی'),
                            _buildTableHeaderCell('مقدار'),
                            _buildTableHeaderCell('مربع فٹ'),
                          ],
                        ),
                        ...project.dimensions.map((dim) =>
                            pw.TableRow(
                              children: [
                                _buildTableCell(dim['wall']?.toString() ?? ''),
                                _buildTableCell(dim['width']?.toString() ?? ''),
                                _buildTableCell(dim['height']?.toString() ?? ''),
                                _buildTableCell(dim['quantity']?.toString() ?? ''),
                                _buildTableCell(dim['sqFt']?.toString() ?? ''),
                              ],
                            )
                        ).toList(),
                      ],
                    ),
                    pw.SizedBox(height: 15),

                    // مالی خلاصہ
                    _buildPdfSummaryRow('فی مربع فٹ ریٹ:', currencyFormat.format(project.rate)),
                    _buildPdfSummaryRow('اضافی چارجز:', currencyFormat.format(project.additionalCharges)),
                    _buildPdfSummaryRow('ایڈوانس:', currencyFormat.format(project.advance)),
                    _buildPdfSummaryRow('کل رقم:', currencyFormat.format(project.totalAmount)),
                    _buildPdfSummaryRow('باقی رقم:', currencyFormat.format(project.remainingBalance), isHighlighted: true),
                  ],
                ),
              ),
            );
          }

          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ہیڈر
                pw.Row(
                  children: [
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
                        pw.Text('گرافکس لیب', style: _headerStyle),
                        pw.Text('${party.name} - رپورٹ',
                            style: pw.TextStyle(color: _secondaryColor)),
                        pw.Text('تاریخ پیدائش: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    )
                  ],
                ),
                pw.SizedBox(height: 30),

                // پارٹی کی معلومات
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: _lightBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('پارٹی کی معلومات', style: _sectionTitleStyle),
                      pw.Divider(color: _primaryColor, height: 1),
                      pw.SizedBox(height: 10),
                      _buildPdfDetailRow('نام:', party.name),
                      _buildPdfDetailRow('قسم:', party.type.toUpperCase()),
                      _buildPdfDetailRow('فون:', party.phone),
                      _buildPdfDetailRow('پتہ:', party.address),
                      _buildPdfDetailRow('تخلیق کی تاریخ:', party.date),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // خلاصہ سیکشن
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: _lightBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('خلاصہ', style: _sectionTitleStyle),
                      pw.Divider(color: _primaryColor, height: 1),
                      pw.SizedBox(height: 10),
                      _buildPdfSummaryRow('کل انوینٹری:', projects.length.toString()),
                      _buildPdfSummaryRow('چھت کے مربع فٹ:', totalRoofSqFt.toStringAsFixed(2)),
                      _buildPdfSummaryRow('دیوار کے مربع فٹ:', totalWallSqFt.toStringAsFixed(2)),
                      _buildPdfSummaryRow('چھت کی رقم:', currencyFormat.format(totalRoofAmount)),
                      _buildPdfSummaryRow('دیوار کی رقم:', currencyFormat.format(totalWallAmount)),
                      _buildPdfSummaryRow('کل ایڈوانس:', currencyFormat.format(totalAdvance)),
                      _buildPdfSummaryRow('کل باقی رقم:', currencyFormat.format(totalRemaining), isHighlighted: true),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // پراجیکٹس کی فہرست
                pw.Text('انوینٹری کی تفصیلات', style: _sectionTitleStyle),
                pw.SizedBox(height: 10),
                ...projectWidgets,

                pw.SizedBox(height: 30),
                pw.Center(
                  child: pw.Text('رپورٹ کا اختتام',
                      style: pw.TextStyle(
                        color: _primaryColor,
                        fontSize: 16,
                      )),
                )
              ],
            )
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==================== PDF سیو، شیئر اور پرنٹ میتھڈز ====================

  // PDF ڈیوائس پر سیو کرنے کا طریقہ
  static Future<String> savePdfToDevice({
    required Uint8List pdfBytes,
    required String fileName,
    BuildContext? context,
  }) async {
    try {
      // Android کے لیے permission چیک کریں
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission not granted');
          }
        }
      }

      // ڈائریکٹری حاصل کریں
      final Directory directory;
      if (kIsWeb) {
        throw Exception('Cannot save to device on web. Use download instead.');
      } else if (Platform.isAndroid) {
        directory = (await getExternalStorageDirectory())!;
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // PDF فائل بنائیں
      final String filePath = '${directory.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  // PDF شیئر کرنے کا طریقہ
  static Future<void> sharePdfFile({
    required Uint8List pdfBytes,
    required String fileName,
    BuildContext? context,
  }) async {
    try {
      if (kIsWeb) {
        // ویب کے لیے
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement()
          ..href = url
          ..download = fileName
          ..style.display = 'none';
        html.document.body!.children.add(anchor);
        anchor.click();
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        // موبائل کے لیے
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(pdfBytes);

        await Share.shareXFiles(
          [XFile(tempFile.path, mimeType: 'application/pdf')],
          subject: fileName,
          text: 'گرافکس لیب - پراجیکٹ رپورٹ',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // PDF پرنٹ کرنے کا طریقہ
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

  // مکمل PDF ایکشن ہینڈلر
  static Future<void> handlePdfActions({
    required BuildContext context,
    required Future<Uint8List> Function() generatePdf,
    required String fileName,
  }) async {
    // لوڈنگ ڈائیلاگ دکھائیں
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );

    try {
      // PDF جنریٹ کریں
      final pdfBytes = await generatePdf();
      Navigator.pop(context); // لوڈنگ ڈائیلاگ بند کریں

      // ایکشن آپشنز دکھائیں
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey[900],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PDF آپشنز',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // PDF سیو کرنے کا آپشن
              ListTile(
                leading: const Icon(Icons.save, color: Colors.green),
                title: const Text('ڈیوائس پر سیو کریں', style: TextStyle(color: Colors.white)),
                subtitle: const Text('PDF فائل اپنے ڈیوائس پر محفوظ کریں',
                    style: TextStyle(color: Colors.white70)),
                onTap: () async {
                  Navigator.pop(context);
                  await _savePdfWithConfirmation(context, pdfBytes, fileName);
                },
              ),

              // PDF شیئر کرنے کا آپشن
              ListTile(
                leading: const Icon(Icons.share, color: Colors.blue),
                title: const Text('PDF شیئر کریں', style: TextStyle(color: Colors.white)),
                subtitle: const Text('واٹس ایپ، ای میل وغیرہ کے ذریعے شیئر کریں',
                    style: TextStyle(color: Colors.white70)),
                onTap: () async {
                  Navigator.pop(context);
                  await _sharePdfWithConfirmation(context, pdfBytes, fileName);
                },
              ),

              // PDF پرنٹ کرنے کا آپشن
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.print, color: Colors.orange),
                  title: const Text('PDF پرنٹ کریں', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('دستیاب پرنٹرز کا استعمال کرتے ہوئے پرنٹ کریں',
                      style: TextStyle(color: Colors.white70)),
                  onTap: () async {
                    Navigator.pop(context);
                    await _printPdfWithConfirmation(context, pdfBytes);
                  },
                ),

              // منسوخ کریں بٹن
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('منسوخ کریں'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      rethrow;
    }
  }

  // ==================== ہیلپر میتھڈز ====================

  // تصدیق کے ساتھ PDF سیو کریں
  static Future<void> _savePdfWithConfirmation(
      BuildContext context,
      Uint8List pdfBytes,
      String fileName,
      ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('PDF سیو کریں', style: TextStyle(color: Colors.white)),
        content: const Text('کیا آپ PDF کو ڈیوائس پر محفوظ کرنا چاہتے ہیں؟',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('منسوخ کریں', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _savePdf(context, pdfBytes, fileName);
            },
            child: const Text('سیو کریں', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // PDF سیو کریں
  static Future<void> _savePdf(
      BuildContext context,
      Uint8List pdfBytes,
      String fileName,
      ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );

      final filePath = await savePdfToDevice(
        pdfBytes: pdfBytes,
        fileName: fileName,
        context: context,
      );

      Navigator.pop(context);

      // کامیابی کا پیغام
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF کامیابی سے سیو ہو گئی!\nمقام: ${filePath.split('/').last}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF سیو کرنے میں ناکامی: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // تصدیق کے ساتھ PDF شیئر کریں
  static Future<void> _sharePdfWithConfirmation(
      BuildContext context,
      Uint8List pdfBytes,
      String fileName,
      ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('PDF شیئر کریں', style: TextStyle(color: Colors.white)),
        content: const Text('کیا آپ اس PDF کو شیئر کرنا چاہتے ہیں؟',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('منسوخ کریں', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sharePdf(context, pdfBytes, fileName);
            },
            child: const Text('شیئر کریں', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  // PDF شیئر کریں
  static Future<void> _sharePdf(
      BuildContext context,
      Uint8List pdfBytes,
      String fileName,
      ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );

      await sharePdfFile(
        pdfBytes: pdfBytes,
        fileName: fileName,
        context: context,
      );

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF شیئر کرنے میں ناکامی: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // تصدیق کے ساتھ PDF پرنٹ کریں
  static Future<void> _printPdfWithConfirmation(
      BuildContext context,
      Uint8List pdfBytes,
      ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('PDF پرنٹ کریں', style: TextStyle(color: Colors.white)),
        content: const Text('کیا آپ اس PDF کو پرنٹ کرنا چاہتے ہیں؟',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('منسوخ کریں', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _printPdf(context, pdfBytes);
            },
            child: const Text('پرنٹ کریں', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  // PDF پرنٹ کریں
  static Future<void> _printPdf(
      BuildContext context,
      Uint8List pdfBytes,
      ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );

      await printPdf(pdfBytes: pdfBytes, context: context);

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('پرنٹ کرنے میں ناکامی: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // پرانا شیئر میتھڈ (بیک ورڈ compactibility کے لیے)
  // static Future<void> sharePdf(Uint8List pdfBytes, String filename) async {
  //   await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  // }
}