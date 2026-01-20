// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'First Page.dart';
// import 'Model class.dart';
// import 'Party Model.dart';
// import 'PartyProjectsScreen.dart';
// import 'PartyWithProjects.dart';
// import 'PdfService.dart';
//
// class ListOfPartiesScreen extends StatefulWidget {
//   const ListOfPartiesScreen({super.key});
//
//   @override
//   State<ListOfPartiesScreen> createState() => _ListOfPartiesScreenState();
// }
//
// class _ListOfPartiesScreenState extends State<ListOfPartiesScreen>
//     with SingleTickerProviderStateMixin {
//   final DatabaseReference _ref = FirebaseDatabase.instance.ref().child('parties');
//   List<PartyModel> _customers = [];
//   List<PartyModel> _suppliers = [];
//   List<PartyModel> _fitters = [];
//
//   List<PartyModel> _filteredCustomers = [];
//   List<PartyModel> _filteredSuppliers = [];
//   List<PartyModel> _filteredFitters = [];
//
//   bool _isLoading = true;
//   String? _errorMessage;
//   late TabController _tabController;
//   StreamSubscription? _partiesSubscription;
//   bool _isDisposed = false;
//
//   // Search controllers
//   TextEditingController _customerSearchController = TextEditingController();
//   TextEditingController _supplierSearchController = TextEditingController();
//   TextEditingController _fitterSearchController = TextEditingController();
//
//   // Current search text for each tab
//   String _customerSearchText = '';
//   String _supplierSearchText = '';
//   String _fitterSearchText = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _fetchParties();
//
//     // Setup search listeners
//     _customerSearchController.addListener(() {
//       setState(() {
//         _customerSearchText = _customerSearchController.text;
//         _filterCustomers();
//       });
//     });
//
//     _supplierSearchController.addListener(() {
//       setState(() {
//         _supplierSearchText = _supplierSearchController.text;
//         _filterSuppliers();
//       });
//     });
//
//     _fitterSearchController.addListener(() {
//       setState(() {
//         _fitterSearchText = _fitterSearchController.text;
//         _filterFitters();
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     _partiesSubscription?.cancel();
//     _tabController.dispose();
//     _customerSearchController.dispose();
//     _supplierSearchController.dispose();
//     _fitterSearchController.dispose();
//     super.dispose();
//   }
//
//   void _filterCustomers() {
//     if (_customerSearchText.isEmpty) {
//       // No search text, show all customers sorted by date (newest first)
//       _filteredCustomers = List.from(_customers)
//         ..sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
//     } else {
//       final searchText = _customerSearchText.toLowerCase();
//       _filteredCustomers = _customers
//           .where((party) =>
//       party.name.toLowerCase().contains(searchText) ||
//           party.phone.toLowerCase().contains(searchText) ||
//           party.address.toLowerCase().contains(searchText))
//           .toList()
//         ..sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
//     }
//   }
//
//   void _filterSuppliers() {
//     if (_supplierSearchText.isEmpty) {
//       // No search text, show all suppliers sorted by date (newest first)
//       _filteredSuppliers = List.from(_suppliers)
//         ..sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
//     } else {
//       final searchText = _supplierSearchController.text.toLowerCase();
//       _filteredSuppliers = _suppliers
//           .where((party) =>
//       party.name.toLowerCase().contains(searchText) ||
//           party.phone.toLowerCase().contains(searchText) ||
//           party.address.toLowerCase().contains(searchText))
//           .toList()
//         ..sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
//     }
//   }
//
//   void _filterFitters() {
//     if (_fitterSearchText.isEmpty) {
//       // No search text, show all fitters sorted by date (newest first)
//       _filteredFitters = List.from(_fitters)
//         ..sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
//     } else {
//       final searchText = _fitterSearchController.text.toLowerCase();
//       _filteredFitters = _fitters
//           .where((party) =>
//       party.name.toLowerCase().contains(searchText) ||
//           party.phone.toLowerCase().contains(searchText) ||
//           party.address.toLowerCase().contains(searchText))
//           .toList()
//         ..sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
//     }
//   }
//
//   DateTime _parseDate(String dateStr) {
//     try {
//       // Try to parse in dd/MM/yyyy format
//       final format = DateFormat('dd/MM/yyyy');
//       return format.parse(dateStr);
//     } catch (e) {
//       try {
//         // Try to parse in MM/dd/yyyy format
//         final format = DateFormat('MM/dd/yyyy');
//         return format.parse(dateStr);
//       } catch (e) {
//         // If parsing fails, return current date
//         return DateTime.now();
//       }
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
//   Future<void> _generateCategoryPdf(List<PartyModel> parties, String category) async {
//     if (parties.isEmpty) {
//       Fluttertoast.showToast(msg: "No $category to generate PDF");
//       return;
//     }
//
//     if (!mounted) return;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );
//
//     // try {
//     //   final partiesWithProjects = <PartyWithProjects>[];
//     //
//     //   for (var party in parties) {
//     //     final projects = await _fetchProjectsForParty(party.id);
//     //     partiesWithProjects.add(PartyWithProjects(party, projects));
//     //   }
//     //
//     //   if (mounted && Navigator.canPop(context)) {
//     //     Navigator.pop(context);
//     //   }
//     //
//     //   final pdfBytes = await PdfService.generateCategoryPdf(
//     //     partiesWithProjects: partiesWithProjects,
//     //     category: category,
//     //   );
//     //
//     //   final fileName = '${category}_Full_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
//     //   await PdfService.printPdf(pdfBytes, fileName);
//     // } catch (e) {
//     //   if (mounted && Navigator.canPop(context)) {
//     //     Navigator.pop(context);
//     //   }
//     //   Fluttertoast.showToast(msg: "Failed to generate PDF: $e");
//     // }
//   }
//
//   Future<void> _fetchParties() async {
//     try {
//       _partiesSubscription?.cancel();
//
//       _partiesSubscription = _ref.onValue.listen((event) {
//         final data = event.snapshot.value;
//         List<PartyModel> fetchedParties = [];
//
//         if (data != null && data is Map) {
//           data.forEach((partyKey, partyValue) {
//             if (partyValue is Map) {
//               final partyMap = Map<String, dynamic>.from(partyValue);
//               partyMap['id'] = partyKey.toString();
//               fetchedParties.add(PartyModel.fromMap(partyMap));
//             }
//           });
//         }
//
//         // Sort by date (newest first)
//         fetchedParties.sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
//
//         if (mounted && !_isDisposed) {
//           setState(() {
//             _customers = fetchedParties.where((party) => party.type == 'customer').toList();
//             _suppliers = fetchedParties.where((party) => party.type == 'supplier').toList();
//             _fitters = fetchedParties.where((party) => party.type == 'fitter').toList();
//
//             // Apply filters
//             _filterCustomers();
//             _filterSuppliers();
//             _filterFitters();
//
//             _isLoading = false;
//             _errorMessage = null;
//           });
//         }
//       }, onError: (error) {
//         if (mounted && !_isDisposed) {
//           setState(() {
//             _isLoading = false;
//             _errorMessage = "Failed to load parties: $error";
//           });
//         }
//       });
//     } catch (e) {
//       if (mounted && !_isDisposed) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = "Error: ${e.toString()}";
//         });
//       }
//     }
//   }
//
//   Future<void> _deleteParty(String partyId) async {
//     try {
//       await _ref.child(partyId).remove();
//       Fluttertoast.showToast(
//         msg: 'Party deleted successfully',
//         backgroundColor: Colors.green,
//       );
//     } catch (e) {
//       Fluttertoast.showToast(
//         msg: 'Failed to delete party: $e',
//         backgroundColor: Colors.red,
//       );
//     }
//   }
//
//   void _editParty(PartyModel party) {
//     // Navigate to FirstPage for editing
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FirstPage(
//           partyToEdit: party,
//         ),
//       ),
//     );
//   }
//
//   void _confirmDeleteParty(PartyModel party) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.grey[800],
//         title: const Text('Delete Party', style: TextStyle(color: Colors.white)),
//         content: Text('Are you sure you want to delete ${party.name}?', style: const TextStyle(color: Colors.white70)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteParty(party.id);
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchBar(TextEditingController controller, String hintText) {
//     return Container(
//       margin: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[800],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: const TextStyle(color: Colors.white54),
//           prefixIcon: const Icon(Icons.search, color: Colors.orange),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           suffixIcon: controller.text.isNotEmpty
//               ? IconButton(
//             icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
//             onPressed: () => controller.clear(),
//           )
//               : null,
//         ),
//         style: const TextStyle(color: Colors.white),
//       ),
//     );
//   }
//
//   Widget _buildPartyList(List<PartyModel> parties, String searchText, Function onRefresh) {
//     if (_errorMessage != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Text(
//             _errorMessage!,
//             style: TextStyle(color: Colors.red[400], fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     }
//
//     if (parties.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.people_outline,
//               size: 60,
//               color: Colors.grey[600],
//             ),
//             const SizedBox(height: 20),
//             Text(
//               searchText.isNotEmpty ? "No parties found" : "No parties found",
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey[600],
//               ),
//             ),
//             if (!searchText.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Add New Party'),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }
//
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: parties.length,
//       itemBuilder: (context, index) {
//         final party = parties[index];
//         return _buildPartyCard(party, onRefresh);
//       },
//     );
//   }
//
//   Widget _buildPartyCard(PartyModel party, Function onRefresh) {
//     final status = party.totalRemaining <= 0 ? 'Paid' : 'Pending';
//     final statusColor = party.totalRemaining <= 0 ? Colors.green : Colors.orange;
//
//     return Card(
//       elevation: 4,
//       color: Colors.grey[850],
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(
//           color: party.totalRemaining <= 0 ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.grey[900],
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(color: Colors.orange),
//           ),
//           child: Icon(
//             _getPartyIcon(party.type),
//             color: Colors.orange,
//             size: 30,
//           ),
//         ),
//         title: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 party.name,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange,
//                   fontSize: 18,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: statusColor.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: statusColor),
//               ),
//               child: Text(
//                 status,
//                 style: TextStyle(
//                   color: statusColor,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),
//             Text(
//               '${party.type.toUpperCase()} • ${party.phone}',
//               style: const TextStyle(color: Colors.white70),
//             ),
//             Text(
//               party.address,
//               style: const TextStyle(color: Colors.white54),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Total: Rs${party.totalAmount.toStringAsFixed(2)}',
//                         style: const TextStyle(color: Colors.white70, fontSize: 12),
//                       ),
//                       Text(
//                         'Remaining: Rs${party.totalRemaining.toStringAsFixed(2)}',
//                         style: TextStyle(
//                           color: party.totalRemaining > 0 ? Colors.orange : Colors.green,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   'Date: ${party.date}',
//                   style: const TextStyle(color: Colors.white54, fontSize: 12),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.edit, color: Colors.blue),
//               onPressed: () => _editParty(party),
//               tooltip: 'Edit Party',
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete, color: Colors.redAccent),
//               onPressed: () => _confirmDeleteParty(party),
//               tooltip: 'Delete Party',
//             ),
//           ],
//         ),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PartyProjectsScreen(party: party),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   IconData _getPartyIcon(String type) {
//     switch (type) {
//       case 'customer':
//         return Icons.person;
//       case 'supplier':
//         return Icons.business;
//       case 'fitter':
//         return Icons.build;
//       default:
//         return Icons.help_outline;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('All Parties'),
//         backgroundColor: Colors.grey[900],
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => FirstPage()),
//               );
//             },
//             icon: const Icon(Icons.home),
//           ),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.orange),
//             onSelected: (value) {
//               if (value == 'refresh') {
//                 _fetchParties();
//               } else if (value == 'pdf_all') {
//                 _generateCategoryPdf(_customers, 'Customers');
//               } else if (value == 'pdf_suppliers') {
//                 _generateCategoryPdf(_suppliers, 'Suppliers');
//               } else if (value == 'pdf_fitters') {
//                 _generateCategoryPdf(_fitters, 'Fitters');
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'refresh',
//                 child: Row(
//                   children: [
//                     Icon(Icons.refresh, color: Colors.blue),
//                     SizedBox(width: 8),
//                     Text('Refresh'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'pdf_all',
//                 child: Row(
//                   children: [
//                     Icon(Icons.picture_as_pdf, color: Colors.red),
//                     SizedBox(width: 8),
//                     Text('Export All Customers PDF'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'pdf_suppliers',
//                 child: Row(
//                   children: [
//                     Icon(Icons.picture_as_pdf, color: Colors.red),
//                     SizedBox(width: 8),
//                     Text('Export All Suppliers PDF'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'pdf_fitters',
//                 child: Row(
//                   children: [
//                     Icon(Icons.picture_as_pdf, color: Colors.red),
//                     SizedBox(width: 8),
//                     Text('Export All Fitters PDF'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.orange,
//           labelColor: Colors.orange,
//           unselectedLabelColor: Colors.white70,
//           tabs: const [
//             Tab(icon: Icon(Icons.person), text: 'Customers'),
//             Tab(icon: Icon(Icons.business), text: 'Suppliers'),
//             Tab(icon: Icon(Icons.build), text: 'Fitters'),
//           ],
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.orange))
//           : TabBarView(
//         controller: _tabController,
//         children: [
//           // Customers Tab
//           Column(
//             children: [
//               _buildSearchBar(_customerSearchController, 'Search customers...'),
//               Expanded(
//                 child: _buildPartyList(
//                   _filteredCustomers,
//                   _customerSearchText,
//                   _fetchParties,
//                 ),
//               ),
//             ],
//           ),
//           // Suppliers Tab
//           Column(
//             children: [
//               _buildSearchBar(_supplierSearchController, 'Search suppliers...'),
//               Expanded(
//                 child: _buildPartyList(
//                   _filteredSuppliers,
//                   _supplierSearchText,
//                   _fetchParties,
//                 ),
//               ),
//             ],
//           ),
//           // Fitters Tab
//           Column(
//             children: [
//               _buildSearchBar(_fitterSearchController, 'Search fitters...'),
//               Expanded(
//                 child: _buildPartyList(
//                   _filteredFitters,
//                   _fitterSearchText,
//                   _fetchParties,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'First Page.dart';
import 'Model class.dart';
import 'Party Model.dart';
import 'PartyProjectsScreen.dart';
import 'PartyWithProjects.dart';
import 'PdfService.dart';

class ListOfPartiesScreen extends StatefulWidget {
  const ListOfPartiesScreen({super.key});

  @override
  State<ListOfPartiesScreen> createState() => _ListOfPartiesScreenState();
}

class _ListOfPartiesScreenState extends State<ListOfPartiesScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref().child('parties');

  List<PartyModel> _customers = [];
  List<PartyModel> _suppliers = [];
  List<PartyModel> _fitters = [];

  List<PartyModel> _filteredCustomers = [];
  List<PartyModel> _filteredSuppliers = [];
  List<PartyModel> _filteredFitters = [];

  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;
  StreamSubscription? _partiesSubscription;
  bool _isDisposed = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchParties();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterParties();
      });
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _partiesSubscription?.cancel();
    _partiesSubscription = null;
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterParties() {
    if (_searchQuery.isEmpty) {
      _filteredCustomers = _customers;
      _filteredSuppliers = _suppliers;
      _filteredFitters = _fitters;
    } else {
      _filteredCustomers = _customers.where((party) =>
      party.name.toLowerCase().contains(_searchQuery) ||
          party.phone.toLowerCase().contains(_searchQuery) ||
          party.address.toLowerCase().contains(_searchQuery)
      ).toList();

      _filteredSuppliers = _suppliers.where((party) =>
      party.name.toLowerCase().contains(_searchQuery) ||
          party.phone.toLowerCase().contains(_searchQuery) ||
          party.address.toLowerCase().contains(_searchQuery)
      ).toList();

      _filteredFitters = _fitters.where((party) =>
      party.name.toLowerCase().contains(_searchQuery) ||
          party.phone.toLowerCase().contains(_searchQuery) ||
          party.address.toLowerCase().contains(_searchQuery)
      ).toList();
    }
  }

  List<PartyModel> _sortParties(List<PartyModel> parties) {
    // Sort by updatedAt first, then by createdAt (newest first)
    parties.sort((a, b) {
      final aTime = a.updatedAt ?? a.createdAt ?? 0;
      final bTime = b.updatedAt ?? b.createdAt ?? 0;
      return bTime.compareTo(aTime); // Descending order (newest first)
    });
    return parties;
  }

  Future<void> _fetchParties() async {
    try {
      _partiesSubscription?.cancel();

      _partiesSubscription = _ref.onValue.listen((event) {
        final data = event.snapshot.value;
        List<PartyModel> fetchedParties = [];

        if (data != null && data is Map) {
          data.forEach((partyKey, partyValue) {
            if (partyValue is Map) {
              final partyMap = Map<String, dynamic>.from(partyValue);
              partyMap['id'] = partyKey.toString();
              fetchedParties.add(PartyModel.fromMap(partyMap));
            }
          });
        }

        if (mounted && !_isDisposed) {
          setState(() {
            _customers = _sortParties(fetchedParties.where((party) => party.type == 'customer').toList());
            _suppliers = _sortParties(fetchedParties.where((party) => party.type == 'supplier').toList());
            _fitters = _sortParties(fetchedParties.where((party) => party.type == 'fitter').toList());

            _filterParties();
            _isLoading = false;
            _errorMessage = null;
          });
        }
      }, onError: (error) {
        if (mounted && !_isDisposed) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Failed to load parties: $error";
          });
        }
      });
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _deleteParty(String partyId) async {
    try {
      await _ref.child(partyId).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Party deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete party: $e')),
      );
    }
  }

  void _confirmDeleteParty(PartyModel party) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: const Text('Delete Party', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${party.name}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteParty(party.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editParty(PartyModel party) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FirstPage(
          existingParty: party,
          isEditMode: true,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by name, phone, or address...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.orange),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.orange),
            onPressed: () {
              _searchController.clear();
            },
          )
              : null,
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPartyList(List<PartyModel> parties) {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red[400], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (parties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 60,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isEmpty ? "No parties found" : "No results found",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: parties.length,
      itemBuilder: (context, index) {
        final party = parties[index];
        final bool isPaid = party.paymentStatus == 'Paid';

        return Card(
          elevation: 4,
          color: Colors.grey[850],
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Stack(
              children: [
                Icon(
                  _getPartyIcon(party.type),
                  color: Colors.orange,
                  size: 40,
                ),
                if (party.totalRemaining > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    party.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green[700] : Colors.orange[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    party.paymentStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${party.type.toUpperCase()} • ${party.phone}',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (party.totalRemaining > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Remaining: Rs${party.totalRemaining.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.orange[300],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editParty(party),
                  tooltip: 'Edit Party',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _confirmDeleteParty(party),
                  tooltip: 'Delete Party',
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartyProjectsScreen(party: party),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getPartyIcon(String type) {
    switch (type) {
      case 'customer':
        return Icons.person;
      case 'supplier':
        return Icons.business;
      case 'fitter':
        return Icons.build;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Parties'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FirstPage()),
              );
            },
            icon: const Icon(Icons.home),
            tooltip: 'Home',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.orange),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Add New Party',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.person),
              text: 'Customers (${_filteredCustomers.length})',
            ),
            Tab(
              icon: const Icon(Icons.business),
              text: 'Suppliers (${_filteredSuppliers.length})',
            ),
            Tab(
              icon: const Icon(Icons.build),
              text: 'Fitters (${_filteredFitters.length})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : TabBarView(
              controller: _tabController,
              children: [
                _buildPartyList(_filteredCustomers),
                _buildPartyList(_filteredSuppliers),
                _buildPartyList(_filteredFitters),
              ],
            ),
          ),
        ],
      ),
    );
  }
}