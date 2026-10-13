class AddressModel {
  final String id;
  final String type; // Home, Work, Other
  final String addressLine;
  final String area;
  final String city;
  final String pincode;
  final String? state;
  final String? district;
  final String? localBody;
  final String? ward;
  final bool isDefault;

  AddressModel({
    required this.id,
    this.type = 'Home',
    required this.addressLine,
    this.area = '',
    required this.city,
    required this.pincode,
    this.state,
    this.district,
    this.localBody,
    this.ward,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? id,
    String? type,
    String? addressLine,
    String? area,
    String? city,
    String? pincode,
    String? state,
    String? district,
    String? localBody,
    String? ward,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      type: type ?? this.type,
      addressLine: addressLine ?? this.addressLine,
      area: area ?? this.area,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      state: state ?? this.state,
      district: district ?? this.district,
      localBody: localBody ?? this.localBody,
      ward: ward ?? this.ward,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
