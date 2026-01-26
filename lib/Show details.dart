import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'PdfService.dart';

class ShowDetailsScreen extends StatelessWidget {
  final String customerName;
  final String phone;
  final String address;
  final String date;
  final String room;
  final String fileType;
  final String rate;
  final String additionalCharges;
  final String advance;
  final String totalSqFt;
  final String totalAmount;
  final String remainingBalance;
  final List<Map<String, dynamic>> dimensions;
  final List<Map<String, dynamic>> paymentHistory;

  const ShowDetailsScreen({
    super.key,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.date,
    required this.room,
    required this.fileType,
    required this.rate,
    required this.additionalCharges,
    required this.advance,
    required this.totalSqFt,
    required this.totalAmount,
    required this.remainingBalance,
    required this.dimensions,
    required this.paymentHistory,
  });

  // FIXED: Simplified PDF generation
  // FIXED: New PDF generation function
  Future<void> _generatePdf(BuildContext context) async {
    try {
      final fileName = '${customerName}_${room}_${DateFormat('yyyyMMdd').format(DateTime.now())}';

      await PdfService.saveAndOpenPdf(
        context: context,
        generatePdf: () async {
          return await PdfService.generateProjectDetailPdf(
            customerName: customerName,
            phone: phone,
            address: address,
            date: date,
            room: room,
            fileType: fileType,
            rate: rate,
            additionalCharges: additionalCharges,
            advance: advance,
            totalSqFt: totalSqFt,
            totalAmount: totalAmount,
            remainingBalance: remainingBalance,
            dimensions: dimensions,
            paymentHistory: paymentHistory,
          );
        },
        fileName: fileName,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to generate PDF: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Future<void> _generatePdf(BuildContext context) async {
  //   try {
  //     final fileName = '${customerName}_${room}_${DateFormat('yyyyMMdd').format(DateTime.now())}';
  //
  //     await PdfService.saveAndOpenPdf(
  //       context: context,
  //       generatePdf: () async {
  //         return await PdfService.generateInventoryPdf(
  //           customerName: customerName,
  //           phone: phone,
  //           address: address,
  //           date: date,
  //           room: room,
  //           fileType: fileType,
  //           rate: rate,
  //           additionalCharges: additionalCharges,
  //           advance: advance,
  //           totalSqFt: totalSqFt,
  //           totalAmount: totalAmount,
  //           remainingBalance: remainingBalance,
  //           dimensions: dimensions,
  //         );
  //       },
  //       fileName: fileName,
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Failed to generate PDF: ${e.toString()}"),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Project Details'),
  //       backgroundColor: Colors.grey[900],
  //       actions: [
  //         // FIXED: Updated PDF button
  //         IconButton(
  //           icon: const Icon(Icons.picture_as_pdf),
  //           onPressed: () => _generatePdf(context),
  //           tooltip: 'Save PDF',
  //         ),
  //       ],
  //     ),
  //     body: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topCenter,
  //           end: Alignment.bottomCenter,
  //           colors: [Colors.grey[800]!, Colors.black],
  //         ),
  //       ),
  //       child: SingleChildScrollView(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             _buildSectionCard(
  //               title: "Party Information",
  //               children: [
  //                 _buildInfoRow('Name:', customerName),
  //                 _buildInfoRow('Phone:', phone),
  //                 _buildInfoRow('Address:', address),
  //                 _buildInfoRow('Date:', date),
  //               ],
  //             ),
  //             const SizedBox(height: 20),
  //             _buildSectionCard(
  //               title: "Project Details",
  //               children: [
  //                 _buildInfoRow('Room:', room),
  //                 _buildInfoRow('Material Type:', fileType),
  //               ],
  //             ),
  //             const SizedBox(height: 20),
  //             _buildSectionCard(
  //               title: "Dimensions",
  //               children: [
  //                 if (dimensions.isEmpty)
  //                   const Padding(
  //                     padding: EdgeInsets.symmetric(vertical: 8),
  //                     child: Text('No dimensions available',
  //                         style: TextStyle(color: Colors.white70)),
  //                   )
  //                 else
  //                   SingleChildScrollView(
  //                     child: DataTable(
  //                       columnSpacing: 20,
  //                       headingRowHeight: 40,
  //                       dataRowHeight: 40,
  //                       headingTextStyle: const TextStyle(
  //                           color: Colors.orange,
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 14
  //                       ),
  //                       dataTextStyle: const TextStyle(color: Colors.white70, fontSize: 14),
  //                       columns: const [
  //                         DataColumn(label: Text('Wall')),
  //                         DataColumn(label: Text('Width')),
  //                         DataColumn(label: Text('Height')),
  //                         DataColumn(label: Text('Qty')),
  //                         DataColumn(label: Text('Sq.ft')),
  //                       ],
  //                       rows: dimensions.map((dim) {
  //                         return DataRow(cells: [
  //                           DataCell(Text(dim['wall']?.toString() ?? '')),
  //                           DataCell(Text(dim['width']?.toString() ?? '')),
  //                           DataCell(Text(dim['height']?.toString() ?? '')),
  //                           DataCell(Text(dim['quantity']?.toString() ?? '')),
  //                           DataCell(Text(dim['sqFt']?.toString() ?? '')),
  //                         ]);
  //                       }).toList(),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //             const SizedBox(height: 20),
  //             _buildSectionCard(
  //               title: "Financial Summary",
  //               children: [
  //                 _buildInfoRow('Rate per sq.ft:', 'Rs $rate'),
  //                 _buildInfoRow('Total Area:', '$totalSqFt sq.ft'),
  //                 _buildInfoRow('Additional Charges:', 'Rs $additionalCharges'),
  //                 _buildInfoRow('Advance Payment:', 'Rs $advance'),
  //                 const Divider(color: Colors.grey, height: 30),
  //                 _buildInfoRow('Total Amount:', 'Rs $totalAmount', isTotal: true),
  //                 _buildInfoRow('Remaining Balance:', 'Rs $remainingBalance',
  //                     isTotal: true, isHighlight: true),
  //               ],
  //             ),
  //             const SizedBox(height: 30),
  //             if (paymentHistory.isNotEmpty) ...[
  //               _buildSectionCard(
  //                 title: "Payment History",
  //                 children: [
  //                   ...paymentHistory.map((payment) {
  //                     return Container(
  //                       margin: const EdgeInsets.only(bottom: 12),
  //                       padding: const EdgeInsets.all(12),
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey[800],
  //                         borderRadius: BorderRadius.circular(8),
  //                         border: Border.all(color: Colors.green, width: 1),
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Text(
  //                                 payment['date']?.toString() ?? '',
  //                                 style: const TextStyle(
  //                                   color: Colors.white,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontSize: 14,
  //                                 ),
  //                               ),
  //                               Text(
  //                                 payment['time']?.toString() ?? '',
  //                                 style: const TextStyle(
  //                                   color: Colors.white70,
  //                                   fontSize: 12,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           const SizedBox(height: 8),
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               const Text(
  //                                 'Received Amount:',
  //                                 style: TextStyle(color: Colors.white70),
  //                               ),
  //                               Text(
  //                                 'Rs${(payment['amount'] as double).toStringAsFixed(2)}',
  //                                 style: const TextStyle(
  //                                   color: Colors.green,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontSize: 16,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           const SizedBox(height: 4),
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               const Text(
  //                                 'Balance After:',
  //                                 style: TextStyle(color: Colors.white70),
  //                               ),
  //                               Text(
  //                                 'Rs${(payment['remainingAfter'] as double).toStringAsFixed(2)}',
  //                                 style: const TextStyle(
  //                                   color: Colors.white,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontSize: 14,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   }).toList(),
  //                 ],
  //               ),
  //               const SizedBox(height: 20),
  //             ],
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(context),
            tooltip: 'Save PDF',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[800]!, Colors.black],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isSmallScreen = constraints.maxWidth < 600;
            final bool isVerySmallScreen = constraints.maxWidth < 400;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    title: "Party Information",
                    children: [
                      _buildInfoRow('Name:', customerName),
                      _buildInfoRow('Phone:', phone),
                      _buildInfoRow('Address:', address),
                      _buildInfoRow('Date:', date),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: "Project Details",
                    children: [
                      _buildInfoRow('Room:', room),
                      _buildInfoRow('Material Type:', fileType),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: "Dimensions",
                    children: [
                      if (dimensions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No dimensions available',
                              style: TextStyle(color: Colors.white70)),
                        )
                      else
                        _buildResponsiveDimensionsTable(
                          dimensions: dimensions,
                          isSmallScreen: isSmallScreen,
                          isVerySmallScreen: isVerySmallScreen,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: "Financial Summary",
                    children: [
                      _buildInfoRow('Rate per sq.ft:', 'Rs $rate'),
                      _buildInfoRow('Total Area:', '$totalSqFt sq.ft'),
                      _buildInfoRow('Additional Charges:', 'Rs $additionalCharges'),
                      _buildInfoRow('Advance Payment:', 'Rs $advance'),
                      const Divider(color: Colors.grey, height: 30),
                      _buildInfoRow('Total Amount:', 'Rs $totalAmount', isTotal: true),
                      _buildInfoRow('Remaining Balance:', 'Rs $remainingBalance',
                          isTotal: true, isHighlight: true),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (paymentHistory.isNotEmpty) ...[
                    _buildSectionCard(
                      title: "Payment History",
                      children: [
                        ...paymentHistory.map((payment) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        payment['date']?.toString() ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      payment['time']?.toString() ?? '',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Received Amount:',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    Text(
                                      'Rs${(payment['amount'] as double).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Balance After:',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    Text(
                                      'Rs${(payment['remainingAfter'] as double).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

// NEW: Responsive dimensions table widget
  Widget _buildResponsiveDimensionsTable({
    required List<Map<String, dynamic>> dimensions,
    required bool isSmallScreen,
    required bool isVerySmallScreen,
  }) {
    if (isVerySmallScreen) {
      // Very small screens - show compact vertical list
      return Column(
        children: dimensions.map((dim) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
             padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wall: ${dim['wall']?.toString() ?? ''}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      'Qty: ${dim['quantity']?.toString() ?? ''}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Size: ${dim['width']?.toString() ?? ''} × ${dim['height']?.toString() ?? ''}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      'Sq.ft: ${dim['sqFt']?.toString() ?? ''}',
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else if (isSmallScreen) {
      // Small screens - show compact table
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12,
          headingRowHeight: 35,
          dataRowHeight: 35,
          headingTextStyle: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          dataTextStyle: const TextStyle(color: Colors.white70, fontSize: 12),
          columns: const [
            DataColumn(label: Text('Wall')),
            DataColumn(label: Text('W')),
            DataColumn(label: Text('H')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Sq.ft')),
          ],
          rows: dimensions.map((dim) {
            return DataRow(cells: [
              DataCell(Text(
                dim['wall']?.toString() ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              )),
              DataCell(Text(dim['width']?.toString() ?? '')),
              DataCell(Text(dim['height']?.toString() ?? '')),
              DataCell(Text(dim['quantity']?.toString() ?? '')),
              DataCell(Text(dim['sqFt']?.toString() ?? '')),
            ]);
          }).toList(),
        ),
      );
    } else {
      // Large screens - show full table
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowHeight: 40,
          dataRowHeight: 40,
          headingTextStyle: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          dataTextStyle: const TextStyle(color: Colors.white70, fontSize: 14),
          columns: const [
            DataColumn(label: Text('Wall')),
            DataColumn(label: Text('Width')),
            DataColumn(label: Text('Height')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Sq.ft')),
          ],
          rows: dimensions.map((dim) {
            return DataRow(cells: [
              DataCell(Text(dim['wall']?.toString() ?? '')),
              DataCell(Text(dim['width']?.toString() ?? '')),
              DataCell(Text(dim['height']?.toString() ?? '')),
              DataCell(Text(dim['quantity']?.toString() ?? '')),
              DataCell(Text(dim['sqFt']?.toString() ?? '')),
            ]);
          }).toList(),
        ),
      );
    }
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isTotal = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.orange : Colors.white70
          )),
          Text(value, style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.orange : Colors.white
          )),
        ],
      ),
    );
  }


}