import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:floret_app/helpers/sp_helper.dart';

enum OrderStatus { pending, completed, reschedule, cancelled }

class OrderModel {
  final String bookingId;
  final String wasteType;
  DateTime pickupDate;
  final String address;
  final String fullAddress;
  final String contact;
  OrderStatus status;

  OrderModel({
    required this.bookingId,
    required this.wasteType,
    required this.pickupDate,
    required this.address,
    required this.fullAddress,
    required this.contact,
    this.status = OrderStatus.pending,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'wasteType': wasteType,
        'pickupDate': pickupDate.toIso8601String(),
        'address': address,
        'fullAddress': fullAddress,
        'contact': contact,
        'status': status.name,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      bookingId: json['bookingId'] as String? ?? 'WC-161',
      wasteType: json['wasteType'] as String? ?? 'Sanitary waste',
      pickupDate: json['pickupDate'] != null
          ? DateTime.tryParse(json['pickupDate'] as String) ??
              DateTime(2026, 10, 15)
          : DateTime(2026, 10, 15),
      address: json['address'] as String? ?? 'Paruthippara, Thiruvananthapuram',
      fullAddress: json['fullAddress'] as String? ??
          'KRAA/11, Paruthippara,\nThiruvananthapuram - 695015',
      contact: json['contact'] as String? ?? 'User',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
    );
  }
}

/// Persistent store holding the user's booked pickups so they
/// can be displayed on the Order History screen at any time.
class OrderStore {
  OrderStore._() {
    _init();
  }
  static final OrderStore instance = OrderStore._();

  static List<OrderModel> _defaultOrders() => [
        OrderModel(
          bookingId: 'WC-168',
          wasteType: 'Sanitary waste',
          pickupDate: DateTime(2026, 10, 15),
          address: 'Paruthippara, Thiruvananthapuram',
          fullAddress: 'KRAA/11, Paruthippara,\nThiruvananthapuram - 695015',
          contact: 'User',
          status: OrderStatus.completed,
        ),
        OrderModel(
          bookingId: 'WC-165',
          wasteType: 'Sanitary waste',
          pickupDate: DateTime(2026, 10, 14),
          address: 'Pattom, Thiruvananthapuram',
          fullAddress: 'TC 14/1250, Pattom,\nThiruvananthapuram - 695004',
          contact: 'User',
          status: OrderStatus.pending,
        ),
        OrderModel(
          bookingId: 'WC-161',
          wasteType: 'Sanitary waste',
          pickupDate: DateTime(2026, 10, 15),
          address: 'Paruthippara, Thiruvananthapuram',
          fullAddress: 'KRAA/11, Paruthippara,\nThiruvananthapuram - 695015',
          contact: 'User',
          status: OrderStatus.pending,
        ),
        OrderModel(
          bookingId: 'WC-160',
          wasteType: 'Dry & Recyclable waste',
          pickupDate: DateTime(2026, 10, 10),
          address: 'Pattom, Thiruvananthapuram',
          fullAddress: 'TC 14/1250, Pattom,\nThiruvananthapuram - 695004',
          contact: 'User',
          status: OrderStatus.completed,
        ),
        OrderModel(
          bookingId: 'WC-159',
          wasteType: 'E-Waste & Electronics',
          pickupDate: DateTime(2026, 10, 18),
          address: 'Kowdiar, Thiruvananthapuram',
          fullAddress: 'Plot 42, Kowdiar Avenue,\nThiruvananthapuram - 695003',
          contact: 'User',
          status: OrderStatus.reschedule,
        ),
        OrderModel(
          bookingId: 'WC-158',
          wasteType: 'Hazardous waste',
          pickupDate: DateTime(2026, 10, 5),
          address: 'Sasthamangalam, Thiruvananthapuram',
          fullAddress: 'House 8B, Sasthamangalam,\nThiruvananthapuram - 695010',
          contact: 'User',
          status: OrderStatus.cancelled,
        ),
      ];

  final ValueNotifier<List<OrderModel>> orders =
      ValueNotifier<List<OrderModel>>(_defaultOrders());

  int _nextId = 162;

  Future<void> _init() async {
    try {
      final jsonStr = await SpHelper.getString('saved_user_orders');
      if (jsonStr != null && jsonStr.trim().isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List && decoded.isNotEmpty) {
          orders.value = decoded
              .map((e) =>
                  OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
          for (final o in orders.value) {
            final match = RegExp(r'WC-(\d+)').firstMatch(o.bookingId);
            if (match != null) {
              final idNum = int.tryParse(match.group(1)!);
              if (idNum != null && idNum >= _nextId) {
                _nextId = idNum + 1;
              }
            }
          }
        }
      }
    } catch (_) {}
  }

  void _saveToStorage() {
    try {
      final data = orders.value.map((o) => o.toJson()).toList();
      SpHelper.saveString('saved_user_orders', jsonEncode(data));
    } catch (_) {}
  }

  String generateBookingId() => 'WC-${_nextId++}';

  void addOrder(OrderModel order) {
    orders.value = [order, ...orders.value];
    _saveToStorage();
  }

  void removeOrder(String bookingId) {
    orders.value =
        orders.value.where((o) => o.bookingId != bookingId).toList();
    _saveToStorage();
  }

  void updateStatus(String bookingId, OrderStatus status) {
    for (final o in orders.value) {
      if (o.bookingId == bookingId) o.status = status;
    }
    orders.value = List<OrderModel>.from(orders.value);
    _saveToStorage();
  }
}
