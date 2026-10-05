class AddressModel {
  final String id;
  final String type; // Home, Work, Other
  final String addressLine;
  final String area;
  final String city;
  final String pincode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.type,
    required this.addressLine,
    required this.area,
    required this.city,
    required this.pincode,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? id,
    String? type,
    String? addressLine,
    String? area,
    String? city,
    String? pincode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      type: type ?? this.type,
      addressLine: addressLine ?? this.addressLine,
      area: area ?? this.area,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
