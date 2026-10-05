import 'package:flutter/material.dart';
import '../model/booking_model.dart';

class BookingRepository {
  List<WasteCategoryItem> getDefaultCategories() {
    return [
      const WasteCategoryItem(
        id: 'sanitary',
        title: 'SANITARY WASTE',
        subtitle: 'Diaper, Sanitary Pad, Expired Medicine, Hair Waste',
        icon: Icons.child_friendly_rounded,
        iconColor: Color(0xFFE05368),
        iconBgColor: Color(0xFFFEE8EB),
        isSelected: false,
        carbonOffsetKg: 8.2,
        pointsXP: 50,
      ),
      const WasteCategoryItem(
        id: 'solid',
        title: 'SOLID WASTE',
        subtitle: 'Paper, Plastic, Metals, Wood',
        icon: Icons.delete_outline_rounded,
        iconColor: Color(0xFF0284C7),
        iconBgColor: Color(0xFFE0F2FE),
        isSelected: false,
        carbonOffsetKg: 5.5,
        pointsXP: 40,
      ),
      const WasteCategoryItem(
        id: 'glass',
        title: 'GLASS WASTE',
        subtitle: 'Bottles, Jars, Shards',
        icon: Icons.local_drink_outlined,
        iconColor: Color(0xFF0D9488),
        iconBgColor: Color(0xFFE6FFFA),
        isSelected: false,
        carbonOffsetKg: 3.8,
        pointsXP: 30,
      ),
    ];
  }

  BookingContactModel getDefaultContact() {
    return const BookingContactModel(
      fullName: 'nicy nicy',
      contactNumber: '+919995723146',
    );
  }

  List<String> getAvailableStates() {
    return const [
      'Kerala',
      'Tamil Nadu',
      'Karnataka',
      'Maharashtra',
      'Delhi',
      'Telangana',
    ];
  }

  List<String> getDistrictsForState(String state) {
    if (state == 'Kerala') {
      return const [
        'Ernakulam',
        'Thiruvananthapuram',
        'Kozhikode',
        'Thrissur',
        'Alappuzha',
        'Kollam',
        'Kottayam',
        'Palakkad',
        'Kannur',
        'Malappuram',
      ];
    }
    return const ['City Central', 'North District', 'South District'];
  }

  List<String> getLocalBodies(String district) {
    return const [
      'Kochi Municipal Corporation',
      'Tripunithura Municipality',
      'Kalamassery Municipality',
      'Aluva Municipality',
      'Gram Panchayat',
    ];
  }

  List<String> getWards(String localBody) {
    return const [
      'Ward 1 - Fort Kochi',
      'Ward 2 - Mattancherry',
      'Ward 3 - Marine Drive',
      'Ward 4 - Palarivattom',
      'Ward 5 - Edappally',
      'Ward 6 - Kakkanad',
    ];
  }
}
