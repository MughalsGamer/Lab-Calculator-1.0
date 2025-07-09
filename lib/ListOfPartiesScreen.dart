import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'Model class.dart';
import 'Party Model.dart';
import 'ShowInventoryListScreen.dart';

class ListOfPartiesScreen extends StatefulWidget {
  const ListOfPartiesScreen({super.key});

  @override
  State<ListOfPartiesScreen> createState() => _ListOfPartiesScreenState();
}

class _ListOfPartiesScreenState extends State<ListOfPartiesScreen> with SingleTickerProviderStateMixin {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref().child('parties');
  List<PartyModel> _allParties = [];
  List<PartyModel> _customers = [];
  List<PartyModel> _suppliers = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          _allParties = fetchedParties;
          _customers = fetchedParties.where((party) => party.type == 'customer').toList();
          _suppliers = fetchedParties.where((party) => party.type == 'supplier').toList();
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPartyList(List<PartyModel> parties) {
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
              party.type == 'customer' ? Icons.person : Icons.business,
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
            Tab(
              icon: Icon(Icons.person),
              text: 'Customers',
            ),
            Tab(
              icon: Icon(Icons.business),
              text: 'Suppliers',
            ),
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
        ],
      ),
    );
  }
}