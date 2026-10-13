import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
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

  Future<BookingContactModel> getUserContact() async {
    final firstName = await SpHelper.getString('first_name');
    final lastName = await SpHelper.getString('last_name');
    final storedName = await SpHelper.getString(sp_keys.keyUserName);
    final rawUname = await SpHelper.getString('username');
    final homeUname = await SpHelper.getString('home_username');

    String fullName = '';
    if (firstName != null &&
        firstName.trim().isNotEmpty &&
        firstName.trim().toLowerCase() != 'user') {
      fullName = (lastName != null && lastName.trim().isNotEmpty)
          ? '${firstName.trim()} ${lastName.trim()}'
          : firstName.trim();
    } else if (storedName != null &&
        storedName.trim().isNotEmpty &&
        storedName.trim().toLowerCase() != 'user') {
      fullName = storedName.trim();
    } else if (rawUname != null &&
        rawUname.trim().isNotEmpty &&
        rawUname.trim().toLowerCase() != 'user') {
      fullName = rawUname.trim();
    } else if (homeUname != null &&
        homeUname.trim().isNotEmpty &&
        homeUname.trim().toLowerCase() != 'user') {
      fullName = homeUname.trim();
    }

    final mobile = await SpHelper.getString(sp_keys.keyUseMobile) ??
        await SpHelper.getString('phone_number') ??
        '';

    return BookingContactModel(
      fullName: fullName,
      contactNumber: mobile,
    );
  }

  BookingContactModel getDefaultContact() {
    return const BookingContactModel(
      fullName: '',
      contactNumber: '',
    );
  }

  List<String> getAvailableStates() {
    return const ['Kerala'];
  }

  List<String> getDistrictsForState(String state) {
    if (state == 'Kerala') {
      return const ['Thiruvananthapuram', 'Alappuzha'];
    }
    return const ['City Central', 'North District', 'South District'];
  }

  List<String> getLocalBodies(String district) {
    if (district == 'Thiruvananthapuram') {
      return const ['Nedumangad Municipality', 'Varkala Municipality'];
    }
    if (district == 'Alappuzha') {
      return const [
        'Alappuzha Municipality',
      ];
    }
    return [];
  }

  List<String> getWards(String localBody) {
    if (localBody == "Alappuzha Municipality") {
      return const ['Ward 1', 'Ward 2', 'Ward 3', 'Ward 4'];
    }
    if (localBody == "Nedumangad Municipality" ||
        localBody == "Nedumangadu Municipality") {
      return const [
        'Ward 1 - Kalluvarambu',
        'Ward 2 - Irinchiyam',
        'Ward 3 - Kusarkode',
        'Ward 4 - Palayathinmukal',
        'Ward 5 - Uliyoor',
        'Ward 6 - Manakode',
        'Ward 7 - Netta',
        'Ward 8 - Nagarikunnu',
        'Ward 9 - Kacheri',
        'Ward 10 - Town',
        'Ward 11 - Muthamkonam',
        'Ward 12 - Kodippuram',
        'Ward 13 - Kollamkavu',
        'Ward 14 - Pulippara',
        'Ward 15 - Vanda',
        'Ward 16 - Panangottela',
        'Ward 17 - Mughavoor',
        'Ward 18 - Koraliyodu',
        'Ward 19 - Pathinaram Kallu',
        'Ward 20 - Mannoorkonam',
      ];
    }
    if (localBody == "Varkala Municipality") {
      return const [
        'Ward 1 - Maithanam',
        'Ward 2 - Temple Ward',
        'Ward 3 - Helipad',
        'Ward 4 - Cliff Ward',
        'Ward 5 - Janardhanapuram',
        'Ward 6 - Punnamoodu',
        'Ward 7 - Chilakkoor',
        'Ward 8 - Odayam',
        'Ward 9 - Kurakkani',
        'Ward 10 - Nadayara',
        'Ward 11 - Palachira',
        'Ward 12 - Kallambalam Road',
        'Ward 13 - Ayiroor Road',
        'Ward 14 - Sivagiri',
      ];
    }
    if (localBody.toLowerCase().contains("thiruvananthapuram")) {
      return const [
        'Ward 1 - Kazhakoottam',
        'Ward 2 - Medical College',
        'Ward 3 - Pattom',
        'Ward 4 - Kowdiar',
        'Ward 5 - Vazhuthacaud',
        'Ward 6 - Palayam',
        'Ward 7 - Statue',
        'Ward 8 - Thampanoor',
        'Ward 9 - Fort',
        'Ward 10 - Nemom',
      ];
    }
    return [];
  }
}
