import 'package:flutter/foundation.dart';

class PartyModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String type;
  final String date;
  double totalAmount;
  double totalAdvance;
  double totalRemaining;

  PartyModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.type,
    required this.date,
    this.totalAmount = 0.0,
    this.totalAdvance = 0.0,
    this.totalRemaining = 0.0,
  });

  factory PartyModel.fromMap(Map<String, dynamic> map) {
    return PartyModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      totalAmount: _toDouble(map['totalAmount']),
      totalAdvance: _toDouble(map['totalAdvance']),
      totalRemaining: _toDouble(map['totalRemaining']),
    );
  }

  // Helper method to safely convert any numeric type to double
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'type': type,
      'date': date,
      'totalAmount': totalAmount,
      'totalAdvance': totalAdvance,
      'totalRemaining': totalRemaining,
    };
  }

  PartyModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? type,
    String? date,
    double? totalAmount,
    double? totalAdvance,
    double? totalRemaining,
  }) {
    return PartyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      type: type ?? this.type,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      totalAdvance: totalAdvance ?? this.totalAdvance,
      totalRemaining: totalRemaining ?? this.totalRemaining,
    );
  }
}