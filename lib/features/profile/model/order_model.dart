import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;

enum OrderStatus { pending, completed, reschedule, cancelled }

class OrderModel {
  final String bookingId;
  final String wasteType;
  DateTime pickupDate;
  DateTime? completedDate;
  final String address;
  final String fullAddress;
  final String contact;
  OrderStatus status;
  final String? userId;

  OrderModel({
    required this.bookingId,
    required this.wasteType,
    required this.pickupDate,
    this.completedDate,
    required this.address,
    required this.fullAddress,
    required this.contact,
    this.status = OrderStatus.pending,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'wasteType': wasteType,
        'pickupDate': pickupDate.toIso8601String(),
        if (completedDate != null)
          'completedDate': completedDate!.toIso8601String(),
        'address': address,
        'fullAddress': fullAddress,
        'contact': contact,
        'status': status.name,
        if (userId != null) 'userId': userId,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final completedDateRaw = json['completedDate'] ??
        json['completed_date'] ??
        json['completed_at'] ??
        json['delivered_at'];
    DateTime? parsedCompletedDate;
    if (completedDateRaw is String && completedDateRaw.isNotEmpty) {
      parsedCompletedDate = DateTime.tryParse(completedDateRaw);
    } else if (completedDateRaw is DateTime) {
      parsedCompletedDate = completedDateRaw;
    }

    return OrderModel(
      bookingId: json['bookingId'] as String? ?? 'WC-161',
      wasteType: json['wasteType'] as String? ?? 'Sanitary waste',
      pickupDate: json['pickupDate'] != null
          ? DateTime.tryParse(json['pickupDate'] as String) ??
              DateTime(2026, 10, 15)
          : DateTime(2026, 10, 15),
      completedDate: parsedCompletedDate,
      address: json['address'] as String? ?? 'Paruthippara, Thiruvananthapuram',
      fullAddress: json['fullAddress'] as String? ??
          'KRAA/11, Paruthippara,\nThiruvananthapuram - 695015',
      contact: json['contact'] as String? ?? 'User',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      userId: json['userId']?.toString() ??
          json['user_id']?.toString() ??
          json['user']?.toString(),
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

  String _currentUserId = '';
  String get currentUserId => _currentUserId;

  static List<OrderModel> _defaultOrders() => [
        OrderModel(
          bookingId: 'WC-168',
          wasteType: 'Sanitary waste',
          pickupDate: DateTime(2026, 10, 15),
          completedDate: DateTime(2026, 10, 13),
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
          completedDate: DateTime(2026, 10, 10),
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

  Future<String> _resolveCurrentUserId() async {
    final uid = await SpHelper.getString(sp_keys.keyUserId);
    if (uid != null && uid.trim().isNotEmpty) return uid.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefUid = prefs.getString(sp_keys.keyUserId) ??
          prefs.getString('user_id') ??
          prefs.getInt('user_id')?.toString();
      if (prefUid != null && prefUid.trim().isNotEmpty) return prefUid.trim();
    } catch (_) {}
    return '';
  }

  Future<String> _getStorageKey([String? explicitUserId]) async {
    final uid = explicitUserId ??
        (_currentUserId.isNotEmpty
            ? _currentUserId
            : await _resolveCurrentUserId());
    if (uid.isNotEmpty) {
      _currentUserId = uid;
      return 'saved_user_orders_$uid';
    }
    return 'saved_user_orders';
  }

  Future<void> _init() async {
    _currentUserId = await _resolveCurrentUserId();
    await _loadFromStorage();
  }

  Future<void> loadForUser([String? userId]) async {
    if (userId != null && userId.isNotEmpty) {
      _currentUserId = userId;
    } else {
      _currentUserId = await _resolveCurrentUserId();
    }
    await _loadFromStorage();
  }

  void resetForLogout() {
    _currentUserId = '';
    orders.value = [];
  }

  Future<void> _loadFromStorage() async {
    try {
      final key = await _getStorageKey();
      final jsonStr = await SpHelper.getString(key);
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
          return;
        }
      }
      if (_currentUserId.isNotEmpty) {
        orders.value = [];
      } else {
        orders.value = _defaultOrders();
      }
    } catch (_) {
      if (_currentUserId.isNotEmpty) {
        orders.value = [];
      } else {
        orders.value = _defaultOrders();
      }
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final key = await _getStorageKey();
      final data = orders.value.map((o) => o.toJson()).toList();
      SpHelper.saveString(key, jsonEncode(data));
    } catch (_) {}
  }

  String generateBookingId() => 'WC-${_nextId++}';

  void addOrder(OrderModel order) {
    final orderWithUser = (order.userId == null && _currentUserId.isNotEmpty)
        ? OrderModel(
            bookingId: order.bookingId,
            wasteType: order.wasteType,
            pickupDate: order.pickupDate,
            completedDate: order.completedDate,
            address: order.address,
            fullAddress: order.fullAddress,
            contact: order.contact,
            status: order.status,
            userId: _currentUserId,
          )
        : order;
    orders.value = [orderWithUser, ...orders.value];
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
