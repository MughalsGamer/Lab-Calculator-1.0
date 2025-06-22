import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'First Page.dart';
import 'Model class.dart';
import 'PdfService.dart';
import 'Show details.dart';
import 'inventory app.dart';

class ShowInventoryListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> inventoryList;

  const ShowInventoryListScreen({super.key, required this.inventoryList});

  @override
  State<ShowInventoryListScreen> createState() => _ShowInventoryListScreenState();
}

class _ShowInventoryListScreenState extends State<ShowInventoryListScreen> {
  final _ref = FirebaseDatabase.instance.ref().child('customers');
  List<CustomerModel> alldata = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

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
                final model = CustomerModel.fromMap(inventoryMap);
                model.customerKey = customerKey;
                model.inventoryKey = inventoryKey;
                fetchdata.add(model);
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

  Future<void> _deleteInventory(CustomerModel model) async {
    try {
      if (model.customerKey != null && model.inventoryKey != null) {
        await _ref
            .child(model.customerKey!)
            .child('inventory')
            .child(model.inventoryKey!)
            .remove();

        setState(() {
          alldata.removeWhere((item) =>
          item.customerKey == model.customerKey &&
              item.inventoryKey == model.inventoryKey);
        });

        Fluttertoast.showToast(
          msg: "Project deleted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: Missing customer or project key",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to delete project: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _generateAndSharePdf(CustomerModel model) async {
    try {
      final pdfFile = await PdfService.generateInventoryPdf(
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
        dimensions: model.dimensions,
      );

      await PdfService.sharePdf(pdfFile);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to generate PDF: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // Navigate to edit screen
  void _navigateToEditScreen(BuildContext context, CustomerModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryApp(
          customerId: model.customerKey!,
          customerName: model.customerName,
          phone: model.phone,
          address: model.address,
          date: model.date,
          isEditMode: true,
          inventoryId: model.inventoryKey,
          initialData: model,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<CustomerModel>> customerInventories = {};

    for (var model in alldata) {
      final customerName = model.customerName;
      if (!customerInventories.containsKey(customerName)) {
        customerInventories[customerName] = [];
      }
      customerInventories[customerName]!.add(model);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Projects'),
        backgroundColor: Colors.grey[900],
        actions: [
          // Add New Project button in AppBar
          IconButton(
            icon: const Icon(Icons.add, color: Colors.orange),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FirstPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: customerInventories.length,
        itemBuilder: (context, index) {
          final customerName = customerInventories.keys.elementAt(index);
          final inventories = customerInventories[customerName]!;

          return Card(
            elevation: 4,
            color: Colors.grey[850],
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              title: Text(customerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.orange
                  )),
              children: inventories.map((inventory) =>
                  _buildInventoryItem(context, inventory)).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryItem(BuildContext context, CustomerModel model) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date: ${model.date}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
              Row(
                children: [
                  // EDIT BUTTON
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _navigateToEditScreen(context, model),
                  ),
                  // PDF BUTTON
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.green),
                    onPressed: () => _generateAndSharePdf(model),
                  ),
                  // DELETE BUTTON
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(model),
                  ),
                ],
              ),
            ],
          ),
          Text('Room: ${model.room}', style: const TextStyle(color: Colors.white)),
          Text('Material: ${model.fileType}', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          const Text('Dimensions:', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange
          )),
          for (var dim in model.dimensions)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${dim['wall']}: ${dim['width']} x ${dim['height']} ft',
                      style: const TextStyle(color: Colors.white70)),
                  Text('${dim['sqFt']} sq.ft', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          const Divider(color: Colors.grey),
          _buildInfoRow('Total Amount:', 'Rs${model.totalAmount}', isTotal: true),
          const SizedBox(height: 10),
          // ADD NEW ITEM BUTTON
          ElevatedButton(
            onPressed: () => _navigateToAddItemScreen(context, model),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text('Add New Item', style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // VIEW DETAILS BUTTON
          ElevatedButton(
            onPressed: () => _navigateToDetailScreen(context, model),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('View Details', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  // Navigate to add new item screen
  void _navigateToAddItemScreen(BuildContext context, CustomerModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryApp(
          customerId: model.customerKey!,
          customerName: model.customerName,
          phone: model.phone,
          address: model.address,
          date: model.date,
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
              color: Colors.white70
          )),
          Text(value, style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.orange : Colors.white
          )),
        ],
      ),
    );
  }

  void _confirmDelete(CustomerModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this project?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () {
              _deleteInventory(model);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToDetailScreen(BuildContext context, CustomerModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowDetailsScreen(
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
          dimensions: model.dimensions.map((e) =>
          Map<String, String>.from(e)).toList(),
        ),
      ),
    );
  }
}