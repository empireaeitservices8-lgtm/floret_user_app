class UserProfileModel {
  final String name;
  final String mobileNumber;
  final String email;
  final String location;
  final int totalCollections;
  final double totalWeightKg;
  final int ecoRewardPoints;

  const UserProfileModel({
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.location,
    this.totalCollections = 14,
    this.totalWeightKg = 42.5,
    this.ecoRewardPoints = 250,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] as String? ?? 'user',
      mobileNumber: json['mobileNumber'] as String? ?? '9995723146',
      email: json['email'] as String? ?? 'user@gmail.com',
      location: json['location'] as String? ?? 'Kerala, India',
      totalCollections: json['totalCollections'] as int? ?? 14,
      totalWeightKg: (json['totalWeightKg'] as num?)?.toDouble() ?? 42.5,
      ecoRewardPoints: json['ecoRewardPoints'] as int? ?? 250,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'mobileNumber': mobileNumber,
        'email': email,
        'location': location,
        'totalCollections': totalCollections,
        'totalWeightKg': totalWeightKg,
        'ecoRewardPoints': ecoRewardPoints,
      };
}

class OrderHistoryItemModel {
  final String orderId;
  final String date;
  final String category;
  final String weight;
  final String status; // 'Completed', 'Pending', 'Reschedule'

  const OrderHistoryItemModel({
    required this.orderId,
    required this.date,
    required this.category,
    required this.weight,
    required this.status,
  });

  factory OrderHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryItemModel(
      orderId: json['orderId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      category: json['category'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      status: json['status'] as String? ?? 'Completed',
    );
  }
}
