// Party Model.dart
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
  final double? latitude;
  final double? longitude;
  final int? createdAt;
  final int? updatedAt;
  final List<Map<String, dynamic>>? paymentHistory;

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
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.paymentHistory,
  });

  // Payment status getter
  String get paymentStatus {
    if (totalRemaining <= 0) {
      return 'Paid';
    } else {
      return 'Pending';
    }
  }

  factory PartyModel.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>>? history;
    if (map['paymentHistory'] != null) {
      if (map['paymentHistory'] is List) {
        history = List<Map<String, dynamic>>.from(
            (map['paymentHistory'] as List).map((e) => Map<String, dynamic>.from(e))
        );
      } else if (map['paymentHistory'] is Map) {
        history = (map['paymentHistory'] as Map).values
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

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
      latitude: _toDoubleNullable(map['latitude']),
      longitude: _toDoubleNullable(map['longitude']),
      createdAt: map['createdAt'] as int?,
      updatedAt: map['updatedAt'] as int?,
      paymentHistory: history,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed == 0.0 ? null : parsed;
    }
    return null;
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
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt ?? DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'paymentHistory': paymentHistory,
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
    double? latitude,
    double? longitude,
    int? createdAt,
    int? updatedAt,
    List<Map<String, dynamic>>? paymentHistory,
    String? paymentStatus, // Ye dummy parameter hai, use nahi hoga but error avoid karne ke liye
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }
}