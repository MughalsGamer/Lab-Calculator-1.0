import 'package:flutter/material.dart';

class ShowInventoryScreen extends StatelessWidget {
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
  final List<Map<String, String>> dimensions;

  const ShowInventoryScreen({
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
  });

  @override
  Widget build(BuildContext context) {
    // Debug print
    print("Dimensions in ShowInventoryScreen: ${dimensions.length}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Details'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Customer:', customerName),
            _buildInfoRow('Phone:', phone),
            _buildInfoRow('Address:', address),
            _buildInfoRow('Date:', date),
            const Divider(height: 30),

            _buildInfoRow('Room:', room),
            _buildInfoRow('File Type:', fileType),
            const SizedBox(height: 20),

            const Text('Dimensions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            if (dimensions.isEmpty)
              const Text('No dimensions available', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic))
            else
              for (var dim in dimensions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${dim['wall'] ?? "Wall"}: ${dim['width'] ?? "0"} x ${dim['height'] ?? "0"} ft',
                          style: const TextStyle(fontSize: 16)),
                      Text('${dim['sqFt'] ?? "0"} sq.ft', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),

            const Divider(height: 30),

            _buildInfoRow('Rate per sq.ft:', 'Rs. $rate'),
            _buildInfoRow('Additional Charges:', 'Rs. $additionalCharges'),
            _buildInfoRow('Advance Payment:', 'Rs. -$advance'),
            const SizedBox(height: 20),
            _buildInfoRow('Total Square Feet:', '$totalSqFt sq.ft', isTotal: true),
            _buildInfoRow('Total Amount:', 'Rs. -$totalAmount', isTotal: true),
            _buildInfoRow('Remaining Balance:', 'Rs. $remainingBalance', isTotal: true),
          ],
        ),
      ),
    );
  }
//hjhg
  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          )),
          Text(value, style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.orange : null,
          )),
        ],
      ),
    );
  }
}
//dsfdsfsd