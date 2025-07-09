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