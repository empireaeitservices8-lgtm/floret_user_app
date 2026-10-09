class ProfileModel {
  final int? id;
  final UserProfileModel? user;
  final String? phoneNumber;
  final String? address;
  final String? profilePicture;
  final String? fcmToken;
  final String? accountType;
  final String? mouDocument;
  final String? mouStatus;
  final String? firstName;
  final String? lastName;
  final String? street;
  final String? city;
  final String? state;
  final String? district;
  final String? localBody;
  final String? ward;
  final String? zipCode;
  final bool? registrationFeePaid;

  const ProfileModel({
    this.id,
    this.user,
    this.phoneNumber,
    this.address,
    this.profilePicture,
    this.fcmToken,
    this.accountType,
    this.mouDocument,
    this.mouStatus,
    this.firstName,
    this.lastName,
    this.street,
    this.city,
    this.state,
    this.district,
    this.localBody,
    this.ward,
    this.zipCode,
    this.registrationFeePaid,
  });

  /// Returns full name combining first_name and last_name, or falls back to username / phoneNumber
  String get fullName {
    final first = (firstName ?? user?.firstName ?? '').trim();
    final last = (lastName ?? user?.lastName ?? '').trim();
    final combined = '$first $last'.trim();
    if (combined.isNotEmpty) return combined;
    if (user?.username != null && user!.username!.trim().isNotEmpty) {
      return user!.username!.trim();
    }
    return phoneNumber ?? 'User';
  }

  /// Returns formatted email or user-friendly fallback
  String get displayEmail {
    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return 'Not provided';
  }

  /// Returns combined address string
  String get formattedAddress {
    final parts = [
      street,
      ward,
      localBody,
      city,
      district,
      state,
      zipCode,
    ].where((part) => part != null && part.trim().isNotEmpty).toList();

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }
    return address ?? 'Not provided';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int?,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserProfileModel.fromJson(json['user'] as Map<String, dynamic>)
          : (json['user'] != null && json['user'] is Map
              ? UserProfileModel.fromJson(
                  Map<String, dynamic>.from(json['user'] as Map),
                )
              : null),
      phoneNumber: json['phone_number']?.toString(),
      address: json['address']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      fcmToken: json['fcm_token']?.toString(),
      accountType: json['account_type']?.toString(),
      mouDocument: json['mou_document']?.toString(),
      mouStatus: json['mou_status']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      street: json['street']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      district: json['district']?.toString(),
      localBody: json['local_body']?.toString(),
      ward: json['ward']?.toString(),
      zipCode: json['zip_code']?.toString(),
      registrationFeePaid: json['registration_fee_paid'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user?.toJson(),
        'phone_number': phoneNumber,
        'address': address,
        'profile_picture': profilePicture,
        'fcm_token': fcmToken,
        'account_type': accountType,
        'mou_document': mouDocument,
        'mou_status': mouStatus,
        'first_name': firstName,
        'last_name': lastName,
        'street': street,
        'city': city,
        'state': state,
        'district': district,
        'local_body': localBody,
        'ward': ward,
        'zip_code': zipCode,
        'registration_fee_paid': registrationFeePaid,
      };
}

class UserProfileModel {
  final int? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? mouDocument;

  const UserProfileModel({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.mouDocument,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int?,
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      mouDocument: json['mou_document']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'mou_document': mouDocument,
      };
}
