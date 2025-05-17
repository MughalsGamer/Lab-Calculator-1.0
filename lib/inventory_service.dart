import 'package:firebase_database/firebase_database.dart';

Future<List<Map<String, dynamic>>> fetchAllInventories() async {
  final ref = FirebaseDatabase.instance.ref().child('inventories');
  final snapshot = await ref.get();

  List<Map<String, dynamic>> allInventories = [];

  if (snapshot.exists) {
    final data = snapshot.value as Map;

    data.forEach((userId, userInventories) {
      if (userInventories is Map) {
        userInventories.forEach((invId, invData) {
          allInventories.add(Map<String, dynamic>.from(invData));
        });
      }
    });
  }

  return allInventories;
}
