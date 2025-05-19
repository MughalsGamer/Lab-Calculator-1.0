import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'First Page.dart';
import 'Model class.dart';
import 'Show details.dart';

class Showinventorylistscreen extends StatefulWidget {
  final List<Map<String, dynamic>> inventoryList;

  const Showinventorylistscreen({super.key, required this.inventoryList});

  @override
  State<Showinventorylistscreen> createState() => _ShowinventorylistscreenState();
}

class _ShowinventorylistscreenState extends State<Showinventorylistscreen> {


  final _ref = FirebaseDatabase.instance.ref().child('customers');
  List<CustomerModel> alldata = [];

  void fetchData() {
    _ref.onValue.listen((event) {
      final data = event.snapshot.value;
      List<CustomerModel> fetchdata = [];

      if (data != null && data is Map) {
        data.forEach((customerKey, customerValue) {
          if (customerValue is Map && customerValue.containsKey('inventory')) {
            final customerInfo = Map<String, dynamic>.from(customerValue);

            final inventories = Map<String, dynamic>.from(customerInfo['inventory']);

            inventories.forEach((inventoryKey, inventoryValue) {
              if (inventoryValue is Map) {
                final inventoryMap = Map<String, dynamic>.from(inventoryValue);
                fetchdata.add(CustomerModel.fromMap(inventoryMap));
              }
            });
          }
        });
      }

      setState(() {
        alldata = fetchdata;
      });
    });
  }



  @override
  void initState() {
    super.initState();
    fetchData(); // Start listening to Firebases
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<CustomerModel>> customerInventories = {};

    for (var model in alldata) {
      final customerName = model.customerName ?? 'Unknown';
      if (!customerInventories.containsKey(customerName)) {
        customerInventories[customerName] = [];
      }
      customerInventories[customerName]!.add(model);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Inventories'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: customerInventories.length,
        itemBuilder: (context, index) {
          final customerName = customerInventories.keys.elementAt(index);
          final inventories = customerInventories[customerName]!;

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              title: Text(customerName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              children: inventories.map((inventory) => _buildInventoryItem(context, inventory)).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FirstPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildInventoryItem(BuildContext context, CustomerModel model) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date: ${model.date}'),
          Text('Room: ${model.room}'),
          Text('File Type: ${model.fileType}'),
          const SizedBox(height: 10),
          const Text('Dimensions:', style: TextStyle(fontWeight: FontWeight.bold)),
          for (var dim in model.dimensions ?? [])
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${dim['wall']}: ${dim['width']} x ${dim['height']} ft'),
                  Text('${dim['sqFt']} sq.ft'),
                ],
              ),
            ),
          const Divider(),
          _buildInfoRow('Total Amount:', 'Rs${model.totalAmount}', isTotal: true),
          ElevatedButton(
            onPressed: () => _navigateToDetailScreen(context, model),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetailScreen(BuildContext context, CustomerModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowInventoryScreen(
          customerName: model.customerName,
          phone: model.phone,
          address: model.address,
          date: model.date,
          room: model.room,
          fileType: model.fileType,
          rate: model.rate.toString(),
          additionalCharges: model.additionalCharges.toString(),
          advance: model.advance.toString(),
          totalSqFt: model.totalSqFt.toString(),
          totalAmount: model.totalAmount.toString(),
          remainingBalance: model.remainingBalance.toString(),
          dimensions: model.dimensions.map((e) => Map<String, String>.from(e)).toList(),
        ),
      ),
    );
  }


  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
