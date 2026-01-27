import 'package:flutter/foundation.dart';

class CustomerModel {
  String id;
  String customerName;
  String phone;
  String address;
  String date;
  String room;
  String fileType;
  double rate;
  double additionalCharges;
  double advance;
  double totalSqFt;
  double totalAmount;
  double remainingBalance;
  List<Map<String, dynamic>> dimensions;
  List<Map<String, dynamic>> paymentHistory; // Added payment history


  CustomerModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.date,
    required this.room,
    required this.fileType,
    required this.rate,
    required this.additionalCharges,
    required this.advance,
    required this.totalSqFt,
    required this.totalAmount,
    required this.remainingBalance,
    required this.dimensions,
    this.paymentHistory = const [],
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    // Parse payment history
    List<Map<String, dynamic>> paymentHistory = [];
    if (map['paymentHistory'] != null) {
      if (map['paymentHistory'] is List) {
        paymentHistory = List<Map<String, dynamic>>.from(
            (map['paymentHistory'] as List).map((e) => Map<String, dynamic>.from(e))
        );
      } else if (map['paymentHistory'] is Map) {
        paymentHistory = (map['paymentHistory'] as Map).values
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    return CustomerModel(
      id: map['id']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      room: map['room']?.toString() ?? '',
      fileType: map['fileType']?.toString() ?? '',
      rate: double.tryParse(map['rate'].toString()) ?? 0.0,
      additionalCharges: double.tryParse(map['additionalCharges'].toString()) ?? 0.0,
      advance: double.tryParse(map['advance'].toString()) ?? 0.0,
      totalSqFt: double.tryParse(map['totalSqFt'].toString()) ?? 0.0,
      totalAmount: double.tryParse(map['totalAmount'].toString()) ?? 0.0,
      remainingBalance: double.tryParse(map['remainingBalance'].toString()) ?? 0.0,
      dimensions: (map['dimensions'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          [],
      paymentHistory: paymentHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'date': date,
      'room': room,
      'fileType': fileType,
      'rate': rate,
      'additionalCharges': additionalCharges,
      'advance': advance,
      'totalSqFt': totalSqFt,
      'totalAmount': totalAmount,
      'remainingBalance': remainingBalance,
      'dimensions': dimensions,
      'paymentHistory': paymentHistory,
    };
  }
}