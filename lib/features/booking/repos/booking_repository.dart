import 'dart:io';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/services/api_client.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import 'package:flutter/material.dart';
import '../model/booking_model.dart';

class BookingRepository {
  final Map<String, List<String>> _wardsCache = {};

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
      return const ['Nedumangadu Municipality', 'Varkala Municipality'];
    }
    if (district == 'Alappuzha') {
      return const [
        'Alappuzha Municipality',
      ];
    }
    return [];
  }

  Future<List<String>> fetchWards(String localBody) async {
    final cached = _wardsCache[localBody];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return getWards(localBody);
    }

    int? localBodyId;
    final lb = localBody.toLowerCase().trim();
    if (lb.contains('nedumangad')) {
      localBodyId = 2;
    } else if (lb.contains('varkala')) {
      localBodyId = 3;
    }

    if (localBodyId != null) {
      try {
        final endpoint = '/api/wards/?local_body&local_body_id=$localBodyId';
        final response = await ApiClient()
            .get(endpoint)
            .timeout(const Duration(seconds: 10));

        if (response.data is List) {
          final List<String> list = [];
          for (final item in response.data) {
            if (item is Map) {
              final wardNum = item['ward_number'];
              final wardName = item['ward_name'];
              if (wardNum != null && wardName != null) {
                list.add('$wardNum - $wardName');
              } else if (wardName != null) {
                list.add(wardName.toString());
              }
            }
          }
          if (list.isNotEmpty) {
            _wardsCache[localBody] = list;
            return list;
          }
        }
      } catch (e) {
        debugPrint('[BookingRepository] Error fetching wards: $e');
      }
    }

    final fallback = getWards(localBody);
    return fallback;
  }

  List<String> getWards(String localBody) {
    if (localBody == "Alappuzha Municipality") {
      return const ['Ward 1', 'Ward 2', 'Ward 3', 'Ward 4'];
    }
    if (localBody.toLowerCase().contains("nedumangad")) {
      return const [
        '1 - KALLUVARAMBU',
        '2 - IRINCHIYAM',
        '3 - KUSARKODE',
        '4 - PALAYATHINMUKAL',
        '5 - ULIYOOR',
        '6 - MANAKODE',
        '7 - NETTA',
        '8 - NAGARIKUNNU',
        '9 - KACHERI',
        '10 - TOWN',
        '11 - MUTHAMKONAM',
        '12 - KODIPPURAM',
        '13 - KOLLAMKAVU',
        '14 - PULIPPARA',
        '15 - VANDA',
        '16 - PANANGOTTELA',
        '17 - MUGHAVOOR',
        '18 - KORALIYODU',
        '19 - PATHINARAM KALLU',
        '20 - MANNOORKONAM',
        '21 - VALIYAMALA',
        '22 - THARATTA',
        '23 - IDAMALA',
        '24 - PADAVALLIKONAM',
        '25 - KANNARAMKODU',
        '26 - PARANODE',
        '27 - MANCHA',
        '28 - T H S WARD',
        '29 - PERUMALA',
        '30 - MARKET',
        '31 - PATHINONNAMKALLU',
        '32 - PARAMUTTAM',
        '33 - PATHAMKALLU',
        '34 - KOPPAM',
        '35 - SANNAGAR',
        '36 - ARASUPARAMBU',
        '37 - PERAYATHU KONAM',
        '38 - PARIYARAM',
        '39 - CHIRAKANI',
        '40 - PUNKUMMOODU',
        '41 - TOWER WARD',
        '42 - POOVATHOOR',
      ];
    }
    if (localBody.toLowerCase().contains("varkala")) {
      return const [
        '1 - Vilakkulam',
        '2 - Idapparambu',
        '3 - Janathamukku',
        '4 - Karunilakode',
        '5 - Kallazhi',
        '6 - Pullannikode',
        '7 - Ayanikkuzhivila',
        '8 - Kannamba',
        '9 - Nadayara',
        '10 - Kanwasramam',
        '11 - Chaluvila',
        '12 - Kallamkonam',
        '13 - Cherukunnam',
        '14 - Sivagiri',
        '15 - Teachers Colony',
        '16 - Raghunathapuram',
        '17 - Puthenchantha',
        '18 - Thachankonam',
        '19 - Ramanthali',
        '20 - Panayil',
        '21 - Vallakkadavu',
        '22 - Perumkulam',
        '23 - Kottumoola',
        '24 - Maithanam',
        '25 - Municipal Office',
        '26 - Hospital',
        '27 - Temple',
        '28 - Janardhanapuram',
        '29 - Mundayil',
        '30 - Jawahar Park',
        '31 - Punnamoodu',
        '32 - Parayil',
        '33 - Papanasam',
        '34 - Kurakkanni',
        '35 - Edava Grama Panchayat',
        '36 - Cherunniyoor Grama Panchayat',
        '37 - Chemmaruthy Grama Panchayat',
        '38 - Vettoor Grama Panchayat',
        '39 - Manamboor Grama Panchayat',
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
