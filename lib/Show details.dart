import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'Party Model.dart';
import 'PartyWithProjects.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generateAndSharePdf(context),
            tooltip: 'Generate PDF',
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
        child: SingleChildScrollView(
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
                    SingleChildScrollView(
                      // scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowHeight: 40,
                        dataRowHeight: 40,

                        headingTextStyle: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14
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
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Payment History Section

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
                                Text(
                                  payment['date']?.toString() ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
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
                                Text(
                                  'Received Amount:',
                                  style: const TextStyle(color: Colors.white70),
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
                                Text(
                                  'Balance After:',
                                  style: const TextStyle(color: Colors.white70),
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
        ),
      ),
    );
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

  Future<void> _generateAndSharePdf(BuildContext context) async {
    try {
      final fileName = '${customerName}_Project_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      await PdfService.handlePdfActions(
        context: context,
        generatePdf: () async {
          return await PdfService.generateInventoryPdf(
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
}