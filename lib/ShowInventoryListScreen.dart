import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'First Page.dart';
import 'Model class.dart';
import 'Party Model.dart';
import 'PdfService.dart';
import 'Show details.dart';
import 'inventory app.dart';

class PartyProjectsScreen extends StatefulWidget {
  final PartyModel party;

  const PartyProjectsScreen({super.key, required this.party});

  @override
  State<PartyProjectsScreen> createState() => _PartyProjectsScreenState();
}

class _PartyProjectsScreenState extends State<PartyProjectsScreen> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref().child('parties');
  List<CustomerModel> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      _ref.child(widget.party.id).child('inventory').onValue.listen((event) {
        final data = event.snapshot.value;
        List<CustomerModel> fetchedProjects = [];

        if (data != null && data is Map) {
          data.forEach((projectKey, projectValue) {
            if (projectValue is Map) {
              final projectMap = Map<String, dynamic>.from(projectValue);
              projectMap['id'] = projectKey;
              projectMap['partyId'] = widget.party.id;
              fetchedProjects.add(CustomerModel.fromMap(projectMap));
            }
          });
        }

        setState(() {
          _projects = fetchedProjects;
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProject(CustomerModel model) async {
    try {
      await _ref
          .child(widget.party.id)
          .child('inventory')
          .child(model.id)
          .remove();

      setState(() {
        _projects.removeWhere((item) => item.id == model.id);
      });

      Fluttertoast.showToast(
        msg: "Project deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to delete project: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _generateAndSharePdf(CustomerModel model) async {
    try {
      await PdfService.generateInventoryPdf(
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
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to generate PDF: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _navigateToEditScreen(BuildContext context, CustomerModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryApp(
          partyId: widget.party.id,
          partyName: widget.party.name,
          phone: widget.party.phone,
          address: widget.party.address,
          date: widget.party.date,
          partyType: widget.party.type,
          isEditMode: true,
          inventoryId: model.id,
          initialData: model,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.party.name}'s Projects"),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(onPressed: (){
            _generateAndSharePdf(_projects[0]);
          }, icon: Icon(Icons.picture_as_pdf)),
          IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FirstPage()),
            );
          }, icon: Icon(Icons.home)),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InventoryApp(
                    partyId: widget.party.id,
                    partyName: widget.party.name,
                    phone: widget.party.phone,
                    address: widget.party.address,
                    date: widget.party.date,
                    partyType: widget.party.type,
                    isEditMode: false,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _projects.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory, size: 60, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "No projects found",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InventoryApp(
                      partyId: widget.party.id,
                      partyName: widget.party.name,
                      phone: widget.party.phone,
                      address: widget.party.address,
                      date: widget.party.date,
                      partyType: widget.party.type,
                      isEditMode: false,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text("Add First Project", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final model = _projects[index];
          return Card(
            elevation: 4,
            color: Colors.grey[850],
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(model.date, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _navigateToEditScreen(context, model),
                          ),
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                      rows: model.dimensions.map((dim) {
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
                  const Divider(color: Colors.grey),
                  _buildInfoRow('Total Amount:', 'Rs${model.totalAmount}', isTotal: true),
                  const SizedBox(height: 10),
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
            ),
          );
        },
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
              _deleteProject(model);
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
          dimensions: model.dimensions.map((d) => {
            'wall': d['wall']?.toString() ?? 'N/A',
            'width': d['width']?.toString() ?? '0',
            'height': d['height']?.toString() ?? '0',
            'quantity': d['quantity']?.toString() ?? '1',
            'sqFt': d['sqFt']?.toString() ?? '0',
          }).toList(),
        ),
      ),
    );
  }
}