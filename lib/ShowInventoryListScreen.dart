import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
          msg: "Inventory deleted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: Missing customer or inventory key",
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
        msg: "Failed to delete inventory: ${e.toString()}",
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
      final pdf = pw.Document();

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Inventory Details',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                _buildPdfDetailRow('Customer Name:', model.customerName),
                _buildPdfDetailRow('Phone:', model.phone),
                _buildPdfDetailRow('Address:', model.address),
                _buildPdfDetailRow('Date:', model.date),
                _buildPdfDetailRow('Room:', model.room),
                _buildPdfDetailRow('File Type:', model.fileType),
                pw.SizedBox(height: 20),
                pw.Text('Dimensions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          child: pw.Text('Wall', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          padding: pw.EdgeInsets.all(4),
                        ),
                        pw.Padding(
                          child: pw.Text('Width (ft)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          padding: pw.EdgeInsets.all(4),
                        ),
                        pw.Padding(
                          child: pw.Text('Height (ft)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          padding: pw.EdgeInsets.all(4),
                        ),
                        pw.Padding(
                          child: pw.Text('Sq.ft', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          padding: pw.EdgeInsets.all(4),
                        ),
                      ],
                    ),
                    ...model.dimensions.map((dim) => pw.TableRow(
                      children: [
                        pw.Padding(
                          child: pw.Text(dim['wall'] ?? 'Wall'),
                          padding: pw.EdgeInsets.all(4),
                        ),
                        pw.Padding(
                          child: pw.Text(dim['width'].toString()),
                          padding: pw.EdgeInsets.all(4),
                        ),
                        pw.Padding(
                          child: pw.Text(dim['height'].toString()),
                          padding: pw.EdgeInsets.all(4),
                        ),
                        pw.Padding(
                          child: pw.Text(dim['sqFt'].toString()),
                          padding: pw.EdgeInsets.all(4),
                        ),
                      ],
                    )),
                  ],
                ),
                pw.SizedBox(height: 20),
                _buildPdfAmountRow('Rate per Sq.ft:', 'Rs${model.rate}'),
                _buildPdfAmountRow('Total Sq.ft:', '${model.totalSqFt} sq.ft'),
                _buildPdfAmountRow('Additional Charges:', 'Rs${model.additionalCharges}'),
                _buildPdfAmountRow('Total Amount:', 'Rs${model.totalAmount}'),
                _buildPdfAmountRow('Advance:', 'Rs${model.advance}'),
                _buildPdfAmountRow('Remaining Balance:', 'Rs${model.remainingBalance}',
                    isTotal: true),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text('Thank you for your business!',
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                ),
              ],
            );
          },
        ),
      );

      // Save the PDF to a temporary file
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/inventory_${model.customerName}_${model.date}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Share the PDF
      await Printing.sharePdf(
        bytes: await file.readAsBytes(),
        filename: 'inventory_${model.customerName}_${model.date}.pdf',
      );

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

  pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 10),
        pw.Text(value),
      ],
    );
  }

  pw.Widget _buildPdfAmountRow(String label, String value, {bool isTotal = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
          )),
          pw.Text(value, style: pw.TextStyle(
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
          )),
        ],
      ),
    );
  }

  void _showEditDialog(CustomerModel model) {
    final nameController = TextEditingController(text: model.customerName);
    final phoneController = TextEditingController(text: model.phone);
    final addressController = TextEditingController(text: model.address);
    final dateController = TextEditingController(text: model.date);
    final roomController = TextEditingController(text: model.room);
    final fileTypeController = TextEditingController(text: model.fileType);
    final rateController = TextEditingController(text: model.rate.toString());
    final additionalChargesController = TextEditingController(text: model.additionalCharges.toString());
    final advanceController = TextEditingController(text: model.advance.toString());

    List<Map<String, dynamic>> editedDimensions = List.from(model.dimensions);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Inventory'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Customer Name')),
                  TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                  TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
                  TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Date')),
                  TextField(controller: roomController, decoration: const InputDecoration(labelText: 'Room')),
                  TextField(controller: fileTypeController, decoration: const InputDecoration(labelText: 'File Type')),
                  TextField(
                    controller: rateController,
                    decoration: const InputDecoration(labelText: 'Rate'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateCalculations(),
                  ),
                  TextField(
                    controller: additionalChargesController,
                    decoration: const InputDecoration(labelText: 'Additional Charges'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateCalculations(),
                  ),
                  TextField(
                    controller: advanceController,
                    decoration: const InputDecoration(labelText: 'Advance'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateCalculations(),
                  ),

                  const SizedBox(height: 16),
                  const Text('Dimensions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...editedDimensions.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> dim = entry.value;
                    return Column(
                      children: [
                        Text('Wall ${index + 1}'),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(text: dim['width'].toString()),
                                decoration: const InputDecoration(labelText: 'Width'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  editedDimensions[index]['width'] = double.tryParse(value) ?? 0;
                                  _calculateDimensionSqFt(index, editedDimensions, setState);
                                  _updateCalculations();
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(text: dim['height'].toString()),
                                decoration: const InputDecoration(labelText: 'Height'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  editedDimensions[index]['height'] = double.tryParse(value) ?? 0;
                                  _calculateDimensionSqFt(index, editedDimensions, setState);
                                  _updateCalculations();
                                },
                              ),
                            ),
                          ],
                        ),
                        Text('Sq.ft: ${editedDimensions[index]['sqFt']}'),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  _buildCalculationRow('Total Sq.ft:', _calculateTotalSqFt(editedDimensions).toStringAsFixed(2)),
                  _buildCalculationRow('Total Amount:',
                      ((double.tryParse(rateController.text) ?? 0) * _calculateTotalSqFt(editedDimensions) +
                          (double.tryParse(additionalChargesController.text) ?? 0)).toStringAsFixed(2)),
                  _buildCalculationRow('Remaining Balance:',
                      (((double.tryParse(rateController.text) ?? 0) * _calculateTotalSqFt(editedDimensions) +
                          (double.tryParse(additionalChargesController.text) ?? 0)) -
                          (double.tryParse(advanceController.text) ?? 0)).toStringAsFixed(2)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final updatedData = {
                      'customerName': nameController.text,
                      'phone': phoneController.text,
                      'address': addressController.text,
                      'date': dateController.text,
                      'room': roomController.text,
                      'fileType': fileTypeController.text,
                      'rate': double.tryParse(rateController.text) ?? 0,
                      'additionalCharges': double.tryParse(additionalChargesController.text) ?? 0,
                      'advance': double.tryParse(advanceController.text) ?? 0,
                      'dimensions': editedDimensions,
                      'totalSqFt': _calculateTotalSqFt(editedDimensions),
                      'totalAmount': (double.tryParse(rateController.text) ?? 0) * _calculateTotalSqFt(editedDimensions) +
                          (double.tryParse(additionalChargesController.text) ?? 0),
                      'remainingBalance': ((double.tryParse(rateController.text) ?? 0) * _calculateTotalSqFt(editedDimensions) +
                          (double.tryParse(additionalChargesController.text) ?? 0)) -
                          (double.tryParse(advanceController.text) ?? 0),
                    };

                    if (model.customerKey != null && model.inventoryKey != null) {
                      await _ref
                          .child(model.customerKey!)
                          .child('inventory')
                          .child(model.inventoryKey!)
                          .update(updatedData);

                      Fluttertoast.showToast(
                        msg: "Inventory updated successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: "Failed to update inventory: $e",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _updateCalculations() {
    setState(() {});
  }

  void _calculateDimensionSqFt(int index, List<Map<String, dynamic>> dimensions, StateSetter setState) {
    double width = dimensions[index]['width'] ?? 0;
    double height = dimensions[index]['height'] ?? 0;
    dimensions[index]['sqFt'] = (width * height).toStringAsFixed(2);
    setState(() {});
  }

  double _calculateTotalSqFt(List<Map<String, dynamic>> dimensions) {
    return dimensions.fold(0, (sum, dim) => sum + (double.tryParse(dim['sqFt'].toString()) ?? 0));
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
          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date: ${model.date}',style: TextStyle(fontSize: 12),),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.green,),
                    onPressed: () => _generateAndSharePdf(model),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDialog(model),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(model),
                  ),
                ],
              ),
            ],
          ),
          Text('Room: ${model.room}'),
          Text('File Type: ${model.fileType}'),
          const SizedBox(height: 10),
          const Text('Dimensions:', style: TextStyle(fontWeight: FontWeight.bold)),
          for (var dim in model.dimensions)
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

  void _confirmDelete(CustomerModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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