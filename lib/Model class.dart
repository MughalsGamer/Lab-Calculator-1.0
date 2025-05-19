class CustomerModel {
  String id;
  final String customerName;
  final String phone;
  final String address;
  final String date;
  final String room;
  final String fileType;
  final double rate;
  final double additionalCharges;
  final double advance;
  final double totalSqFt;
  final double totalAmount;
  final double remainingBalance;
  final List<Map<String, dynamic>> dimensions;

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
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] ?? '',
      customerName: map['customerName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      date: map['date'] ?? '',
      room: map['room'] ?? '',
      fileType: map['fileType'] ?? '',
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
    };
  }
}
