import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'Model class.dart';
import 'ShowInventoryListScreen.dart';

class ListOfPartiesScreen extends StatefulWidget {
  const ListOfPartiesScreen({super.key});

  @override
  State<ListOfPartiesScreen> createState() => _ListOfPartiesScreenState();
}

class _ListOfPartiesScreenState extends State<ListOfPartiesScreen> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref().child('parties');
  List<PartyModel> _parties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchParties();
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
              partyMap['id'] = partyKey;
              fetchedParties.add(PartyModel.fromMap(partyMap));
            }
          });
        }

        setState(() {
          _parties = fetchedParties;
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _parties.length,
        itemBuilder: (context, index) {
          final party = _parties[index];
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
      ),
    );
  }
}

class PartyModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String date;
  final String type;

  PartyModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.date,
    required this.type,
  });

  factory PartyModel.fromMap(Map<String, dynamic> map) {
    return PartyModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      type: map['type']?.toString() ?? 'customer',
    );
  }
}