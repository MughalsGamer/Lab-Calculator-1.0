import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Party Model.dart';
import 'ShowInventoryListScreen.dart';

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
  List<PartyModel> _fitters = []; // Changed to plural for consistency
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchParties();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchParties() async {
    try {
      _ref.onValue.listen((event) {
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

        setState(() {
          _customers = fetchedParties.where((party) => party.type == 'customer').toList();
          _suppliers = fetchedParties.where((party) => party.type == 'supplier').toList();
          _fitters = fetchedParties.where((party) => party.type == 'fitter').toList();
          _isLoading = false;
          _errorMessage = null;
        });
      }, onError: (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load parties: $error";
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
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
              "No parties found",
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
        return Card(
          elevation: 4,
          color: Colors.grey[850],
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(
              _getPartyIcon(party.type), // Use helper function for icons
              color: Colors.orange,
            ),
            title: Text(
              party.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              '${party.type.toUpperCase()} • ${party.phone}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.orange),
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

  // Helper function to get appropriate icon for party type
  IconData _getPartyIcon(String type) {
    switch (type) {
      case 'customer':
        return Icons.person;
      case 'supplier':
        return Icons.business;
      case 'fitter':
        return Icons.build; // Specific icon for fitters
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
            icon: const Icon(Icons.add, color: Colors.orange),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Customers'),
            Tab(icon: Icon(Icons.business), text: 'Suppliers'),
            Tab(icon: Icon(Icons.build), text: 'Fitters'), // Consistent naming
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildPartyList(_customers),
          _buildPartyList(_suppliers),
          _buildPartyList(_fitters), // Consistent naming
        ],
      ),
    );
  }
}