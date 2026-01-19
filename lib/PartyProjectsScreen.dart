// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'First Page.dart';
// import 'Model class.dart';
// import 'Party Model.dart';
// import 'PartyWithProjects.dart';
// import 'PdfService.dart';
// import 'Show details.dart';
// import 'inventory app.dart';
//
// class PartyProjectsScreen extends StatefulWidget {
//   final PartyModel party;
//   final Function(PartyModel)? onPartyUpdated;
//
//
//   const PartyProjectsScreen({
//     super.key,
//     required this.party,
//     this.onPartyUpdated,
//   });
//
//   @override
//   State<PartyProjectsScreen> createState() => _PartyProjectsScreenState();
// }
//
// class _PartyProjectsScreenState extends State<PartyProjectsScreen> {
//   final DatabaseReference _ref = FirebaseDatabase.instance.ref().child('parties');
//   List<CustomerModel> _projects = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProjects();
//   }
//
//   Future<void> _updatePartyTotals() async {
//     try {
//       double totalAmount = 0;
//       double totalAdvance = 0;
//       double totalRemaining = 0;
//
//       for (var project in _projects) {
//         totalAmount += project.totalAmount;
//         totalAdvance += project.advance;
//         totalRemaining += project.remainingBalance;
//       }
//
//       // Update party totals in Firebase
//       await _ref.child(widget.party.id).update({
//         'totalAmount': totalAmount,
//         'totalAdvance': totalAdvance,
//         'totalRemaining': totalRemaining,
//       });
//
//       // Create updated party object
//       final updatedParty = widget.party.copyWith(
//         totalAmount: totalAmount,
//         totalAdvance: totalAdvance,
//         totalRemaining: totalRemaining,
//       );
//
//       // Call callback if provided
//       if (widget.onPartyUpdated != null) {
//         widget.onPartyUpdated!(updatedParty);
//       }
//
//       setState(() {});
//     } catch (e) {
//       print('Error updating party totals: $e');
//     }
//   }
//
//   // Future<void> _updatePartyTotals() async {
//   //   try {
//   //     double totalAmount = 0;
//   //     double totalAdvance = 0;
//   //     double totalRemaining = 0;
//   //
//   //     for (var project in _projects) {
//   //       totalAmount += project.totalAmount;
//   //       totalAdvance += project.advance;
//   //       totalRemaining += project.remainingBalance;
//   //     }
//   //
//   //     // Update party totals in Firebase
//   //     await _ref.child(widget.party.id).update({
//   //       'totalAmount': totalAmount,
//   //       'totalAdvance': totalAdvance,
//   //       'totalRemaining': totalRemaining,
//   //     });
//   //
//   //     // Update local party object
//   //     widget.party.totalAmount = totalAmount;
//   //     widget.party.totalAdvance = totalAdvance;
//   //     widget.party.totalRemaining = totalRemaining;
//   //
//   //     setState(() {});
//   //   } catch (e) {
//   //     print('Error updating party totals: $e');
//   //   }
//   // }
//
//   void _handlePdfActions() {
//     if (_projects.isEmpty) {
//       Fluttertoast.showToast(msg: "No projects to generate PDF");
//       return;
//     }
//
//     PdfService.handlePdfActions(
//       context: context,
//       generatePdf: () async {
//         return await PdfService.generatePartyProjectsPdf(
//           party: widget.party,
//           projects: _projects,
//         );
//       },
//       fileName: '${widget.party.name}_Projects_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
//     );
//   }
//
// // Call this method in _fetchProjects after setting _projects
//
//   Future<void> _fetchProjects() async {
//     try {
//       _ref.child(widget.party.id).child('inventory').onValue.listen((event) async {
//         final data = event.snapshot.value;
//         List<CustomerModel> fetchedProjects = [];
//
//         if (data != null && data is Map) {
//           data.forEach((projectKey, projectValue) {
//             if (projectValue is Map) {
//               final projectMap = Map<String, dynamic>.from(projectValue);
//               projectMap['id'] = projectKey;
//               projectMap['partyId'] = widget.party.id;
//               fetchedProjects.add(CustomerModel.fromMap(projectMap));
//             }
//           });
//         }
//
//         setState(() {
//           _projects = fetchedProjects;
//           _isLoading = false;
//         });
//
//         // Update party totals after fetching projects
//         await _updatePartyTotals();
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }
//
// // Also call _updatePartyTotals after adding/editing/deleting projects
// // In _deleteProject method, after successful deletion:
//   Future<void> _deleteProject(CustomerModel model) async {
//     try {
//       await _ref
//           .child(widget.party.id)
//           .child('inventory')
//           .child(model.id)
//           .remove();
//
//       setState(() {
//         _projects.removeWhere((item) => item.id == model.id);
//       });
//
//       // Update party totals after deletion
//       await _updatePartyTotals();
//
//       Fluttertoast.showToast(
//         msg: "Project deleted successfully",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.green,
//         textColor: Colors.white,
//       );
//     } catch (e) {
//       Fluttertoast.showToast(
//         msg: "Failed to delete project: ${e.toString()}",
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//     }
//   }
//
//   Future<List<CustomerModel>> _fetchProjectsForParty(String partyId) async {
//     try {
//       final snapshot = await _ref.child(partyId).child('inventory').get();
//       final projects = <CustomerModel>[];
//
//       if (snapshot.exists) {
//         final data = snapshot.value as Map<dynamic, dynamic>;
//         data.forEach((key, value) {
//           final projectMap = Map<String, dynamic>.from(value);
//           projectMap['id'] = key.toString();
//           projects.add(CustomerModel.fromMap(projectMap));
//         });
//       }
//
//       return projects;
//     } catch (e) {
//       return [];
//     }
//   }
//
//   Future<void> _generatePartyPdf() async {
//     if (_projects.isEmpty) {
//       Fluttertoast.showToast(msg: "No projects to generate PDF");
//       return;
//     }
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );
//
//     try {
//       final pdfBytes = await PdfService.generatePartyProjectsPdf(
//         party: widget.party,
//         projects: _projects,
//       );
//
//       Navigator.pop(context); // Close loading dialog
//
//       final fileName = '${widget.party.name}_Projects_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
//       await PdfService.printPdf(pdfBytes: pdfBytes,);
//     } catch (e) {
//       Navigator.pop(context); // Close loading dialog
//       Fluttertoast.showToast(msg: "Failed to generate PDF: $e");
//     }
//   }
//
//   // Future<void> _fetchProjects() async {
//   //   try {
//   //     _ref.child(widget.party.id).child('inventory').onValue.listen((event) {
//   //       final data = event.snapshot.value;
//   //       List<CustomerModel> fetchedProjects = [];
//   //
//   //       if (data != null && data is Map) {
//   //         data.forEach((projectKey, projectValue) {
//   //           if (projectValue is Map) {
//   //             final projectMap = Map<String, dynamic>.from(projectValue);
//   //             projectMap['id'] = projectKey;
//   //             projectMap['partyId'] = widget.party.id;
//   //             fetchedProjects.add(CustomerModel.fromMap(projectMap));
//   //           }
//   //         });
//   //       }
//   //
//   //       setState(() {
//   //         _projects = fetchedProjects;
//   //         _isLoading = false;
//   //       });
//   //     });
//   //   } catch (e) {
//   //     setState(() => _isLoading = false);
//   //   }
//   // }
//
//   // Future<void> _deleteProject(CustomerModel model) async {
//   //   try {
//   //     await _ref
//   //         .child(widget.party.id)
//   //         .child('inventory')
//   //         .child(model.id)
//   //         .remove();
//   //
//   //     setState(() {
//   //       _projects.removeWhere((item) => item.id == model.id);
//   //     });
//   //
//   //     Fluttertoast.showToast(
//   //       msg: "Project deleted successfully",
//   //       toastLength: Toast.LENGTH_SHORT,
//   //       gravity: ToastGravity.BOTTOM,
//   //       backgroundColor: Colors.green,
//   //       textColor: Colors.white,
//   //     );
//   //   } catch (e) {
//   //     Fluttertoast.showToast(
//   //       msg: "Failed to delete project: ${e.toString()}",
//   //       backgroundColor: Colors.red,
//   //       textColor: Colors.white,
//   //     );
//   //   }
//   // }
//
//
//   void _navigateToEditScreen(BuildContext context, CustomerModel model) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => InventoryApp(
//           partyId: widget.party.id,
//           partyName: widget.party.name,
//           phone: widget.party.phone,
//           address: widget.party.address,
//           date: widget.party.date,
//           partyType: widget.party.type,
//           isEditMode: true,
//           inventoryId: model.id,
//           initialData: model,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:
//       AppBar(
//         title: Text("${widget.party.name}'s Projects"),
//         backgroundColor: Colors.grey[900],
//         actions: [
//           // PDF Actions Button
//           IconButton(
//             onPressed: _handlePdfActions,
//             icon: const Icon(Icons.picture_as_pdf),
//           ),
//           IconButton(onPressed: (){
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => FirstPage()),
//             );
//           }, icon: Icon(Icons.home)),
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.orange),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => InventoryApp(
//                     partyId: widget.party.id,
//                     partyName: widget.party.name,
//                     phone: widget.party.phone,
//                     address: widget.party.address,
//                     date: widget.party.date,
//                     partyType: widget.party.type,
//                     isEditMode: false,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.orange))
//           : _projects.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.inventory, size: 60, color: Colors.orange),
//             const SizedBox(height: 20),
//             const Text(
//               "No projects found",
//               style: TextStyle(fontSize: 18, color: Colors.white70),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => InventoryApp(
//                       partyId: widget.party.id,
//                       partyName: widget.party.name,
//                       phone: widget.party.phone,
//                       address: widget.party.address,
//                       date: widget.party.date,
//                       partyType: widget.party.type,
//                       isEditMode: false,
//                     ),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//               ),
//               child: const Text("Add First Project", style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.all(12),
//         itemCount: _projects.length,
//         itemBuilder: (context, index) {
//           final model = _projects[index];
//           return Card(
//             elevation: 4,
//             color: Colors.grey[850],
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(model.date, style: const TextStyle(fontSize: 14, color: Colors.white70)),
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit, color: Colors.blue),
//                             onPressed: () => _navigateToEditScreen(context, model),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () => _confirmDelete(model),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Text('Room: ${model.room}', style: const TextStyle(color: Colors.white)),
//                   Text('Material: ${model.fileType}', style: const TextStyle(color: Colors.white70)),
//                   const SizedBox(height: 10),
//                   const Text('Dimensions:', style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orange
//                   )),
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
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
//                       rows: model.dimensions.map((dim) {
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
//                   const Divider(color: Colors.grey),
//                   _buildInfoRow('Total Amount:', 'Rs${model.totalAmount}', isTotal: true),
//                   _buildInfoRow('Advance:', 'Rs${model.advance}', isTotal: true),
//                   _buildInfoRow('Remaining Balance:', 'Rs${model.remainingBalance}', isTotal: true),
//
//
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () => _navigateToDetailScreen(context, model),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[800],
//                       minimumSize: const Size(double.infinity, 40),
//                     ),
//                     child: const Text('View Details', style: TextStyle(color: Colors.orange)),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(
//               fontSize: 16,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: Colors.white70
//           )),
//           Text(value, style: TextStyle(
//               fontSize: 16,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: isTotal ? Colors.orange : Colors.white
//           )),
//         ],
//       ),
//     );
//   }
//
//   void _confirmDelete(CustomerModel model) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.grey[850],
//         title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
//         content: const Text('Are you sure you want to delete this project?',
//             style: TextStyle(color: Colors.white70)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
//           ),
//           TextButton(
//             onPressed: () {
//               _deleteProject(model);
//               Navigator.pop(context);
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _navigateToDetailScreen(BuildContext context, CustomerModel model) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ShowDetailsScreen(
//           customerName: model.customerName,
//           phone: model.phone,
//           address: model.address,
//           date: model.date,
//           room: model.room,
//           fileType: model.fileType,
//           rate: model.rate.toString(),
//           additionalCharges: model.additionalCharges.toString(),
//           advance: model.advance.toString(),
//           totalSqFt: model.totalSqFt.toString(),
//           totalAmount: model.totalAmount.toString(),
//           remainingBalance: model.remainingBalance.toString(),
//           dimensions: model.dimensions.map((d) => {
//             'wall': d['wall']?.toString() ?? 'N/A',
//             'width': d['width']?.toString() ?? '0',
//             'height': d['height']?.toString() ?? '0',
//             'quantity': d['quantity']?.toString() ?? '1',
//             'sqFt': d['sqFt']?.toString() ?? '0',
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'First Page.dart';
import 'Model class.dart';
import 'Party Model.dart';
import 'PartyWithProjects.dart';
import 'PdfService.dart';
import 'Show details.dart';
import 'inventory app.dart';

class PartyProjectsScreen extends StatefulWidget {
  final PartyModel party;
  final Function(PartyModel)? onPartyUpdated;

  const PartyProjectsScreen({
    super.key,
    required this.party,
    this.onPartyUpdated,
  });

  @override
  State<PartyProjectsScreen> createState() => _PartyProjectsScreenState();
}

class _PartyProjectsScreenState extends State<PartyProjectsScreen> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref().child('parties');
  List<CustomerModel> _projects = [];
  bool _isLoading = true;

  // Totals ko track karne ke liye variables
  double _totalAllAmount = 0.0;
  double _totalAllAdvance = 0.0;
  double _totalAllRemaining = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _updatePartyTotals() async {
    try {
      double totalAmount = 0;
      double totalAdvance = 0;
      double totalRemaining = 0;

      for (var project in _projects) {
        totalAmount += project.totalAmount;
        totalAdvance += project.advance;
        totalRemaining += project.remainingBalance;
      }

      // Global totals update karo
      setState(() {
        _totalAllAmount = totalAmount;
        _totalAllAdvance = totalAdvance;
        _totalAllRemaining = totalRemaining;
      });

      // Update party totals in Firebase
      await _ref.child(widget.party.id).update({
        'totalAmount': totalAmount,
        'totalAdvance': totalAdvance,
        'totalRemaining': totalRemaining,
      });

      // Create updated party object
      final updatedParty = widget.party.copyWith(
        totalAmount: totalAmount,
        totalAdvance: totalAdvance,
        totalRemaining: totalRemaining,
      );

      // Call callback if provided
      if (widget.onPartyUpdated != null) {
        widget.onPartyUpdated!(updatedParty);
      }
    } catch (e) {
      print('Error updating party totals: $e');
    }
  }

  void _handlePdfActions() {
    if (_projects.isEmpty) {
      Fluttertoast.showToast(msg: "No projects to generate PDF");
      return;
    }

    PdfService.handlePdfActions(
      context: context,
      generatePdf: () async {
        return await PdfService.generatePartyProjectsPdf(
          party: widget.party,
          projects: _projects,
        );
      },
      fileName: '${widget.party.name}_Projects_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
    );
  }

  Future<void> _fetchProjects() async {
    try {
      _ref.child(widget.party.id).child('inventory').onValue.listen((event) async {
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

        // Update party totals after fetching projects
        await _updatePartyTotals();
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

      // Update party totals after deletion
      await _updatePartyTotals();

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
          IconButton(
            onPressed: _handlePdfActions,
            icon: const Icon(Icons.picture_as_pdf),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FirstPage()),
              );
            },
            icon: Icon(Icons.home),
          ),
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
          : Column(
        children: [
          // Totals containers - sirf tab show karo jab projects available hain
          if (_projects.isNotEmpty)
            _buildTotalsContainer(),

          // Projects list
          Expanded(
            child: _projects.isEmpty
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
                        // Ab yeh empty container hata kar yeh totals containers add karein
                        _buildProjectTotalsRow(model),

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
                        _buildInfoRow('Advance:', 'Rs${model.advance}', isTotal: true),
                        _buildInfoRow('Remaining Balance:', 'Rs${model.remainingBalance}', isTotal: true),

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
          ),
        ],
      ),
    );
  }

  // All inventory ki totals container
  Widget _buildTotalsContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Party Summary',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total Amount
              Expanded(
                child: _buildTotalCard(
                  title: 'Total Amount',
                  value: _totalAllAmount,
                  icon: Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),

              // Total Advance
              Expanded(
                child: _buildTotalCard(
                  title: 'Total Advance',
                  value: _totalAllAdvance,
                  icon: Icons.payment,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),

              // Total Remaining
              Expanded(
                child: _buildTotalCard(
                  title: 'Remaining',
                  value: _totalAllRemaining,
                  icon: Icons.balance,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Har project ke liye individual totals row
  Widget _buildProjectTotalsRow(CustomerModel model) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total Amount
          _buildMiniTotalCard(
            title: 'Amount',
            value: model.totalAmount,
            color: Colors.blue[700]!,
          ),

          // Advance
          _buildMiniTotalCard(
            title: 'Advance',
            value: model.advance,
            color: Colors.green[700]!,
          ),

          // Remaining
          _buildMiniTotalCard(
            title: 'Balance',
            value: model.remainingBalance,
            color: Colors.orange[700]!,
          ),
        ],
      ),
    );
  }

  // Mini card for individual project totals
  Widget _buildMiniTotalCard({
    required String title,
    required double value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Rs${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Large card for overall totals
  Widget _buildTotalCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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