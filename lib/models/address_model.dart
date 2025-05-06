class Address {
  final String? id;
  final String userId;
  final String fullName;
  final String address;
  final String city;
  final String state;
  final int pincode;
  final String phone;

  Address({
    this.id,
    required this.userId,
    required this.fullName,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? 0,
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'fullName': fullName,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'phone': phone,
    };
  }
}
