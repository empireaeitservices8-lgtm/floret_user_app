import 'package:flutter/material.dart';

class WasteCategoryItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isSelected;
  final double carbonOffsetKg;
  final int pointsXP;

  const WasteCategoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isSelected = false,
    required this.carbonOffsetKg,
    required this.pointsXP,
  });

  WasteCategoryItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
    bool? isSelected,
    double? carbonOffsetKg,
    int? pointsXP,
  }) {
    return WasteCategoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      isSelected: isSelected ?? this.isSelected,
      carbonOffsetKg: carbonOffsetKg ?? this.carbonOffsetKg,
      pointsXP: pointsXP ?? this.pointsXP,
    );
  }
}

class BookingContactModel {
  final String fullName;
  final String contactNumber;

  const BookingContactModel({
    required this.fullName,
    required this.contactNumber,
  });

  BookingContactModel copyWith({
    String? fullName,
    String? contactNumber,
  }) {
    return BookingContactModel(
      fullName: fullName ?? this.fullName,
      contactNumber: contactNumber ?? this.contactNumber,
    );
  }
}

class BookingLocationModel {
  final String pickupAddress;
  final String city;
  final String state;
  final String district;
  final String localBody;
  final String ward;
  final String zipCode;
  final bool saveToProfile;

  const BookingLocationModel({
    this.pickupAddress = '',
    this.city = '',
    this.state = 'Kerala',
    this.district = 'Ernakulam',
    this.localBody = 'Kochi Municipal Corporation',
    this.ward = '',
    this.zipCode = '',
    this.saveToProfile = true,
  });

  BookingLocationModel copyWith({
    String? pickupAddress,
    String? city,
    String? state,
    String? district,
    String? localBody,
    String? ward,
    String? zipCode,
    bool? saveToProfile,
  }) {
    return BookingLocationModel(
      pickupAddress: pickupAddress ?? this.pickupAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      district: district ?? this.district,
      localBody: localBody ?? this.localBody,
      ward: ward ?? this.ward,
      zipCode: zipCode ?? this.zipCode,
      saveToProfile: saveToProfile ?? this.saveToProfile,
    );
  }
}
