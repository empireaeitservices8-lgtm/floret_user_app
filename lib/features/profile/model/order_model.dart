import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;

enum OrderStatus { pending, completed, reschedule, cancelled }

class OrderModel {
  final int? id;
  final String bookingId;
  final String wasteType;
  DateTime pickupDate;
  DateTime? completedDate;
  final String address;
  final String fullAddress;
  final String contact;
  OrderStatus status;
  final String? userId;
  final double? weight;
  final int? bagsUsed;
  String? rawStatus;
  final String? paymentStatus;

  OrderModel({
    this.id,
    required this.bookingId,
    required this.wasteType,
    required this.pickupDate,
    this.completedDate,
    required this.address,
    required this.fullAddress,
    required this.contact,
    this.status = OrderStatus.pending,
    this.userId,
    this.weight,
    this.bagsUsed,
    this.rawStatus,
    this.paymentStatus,
  });

  int? get pickupId =>
      id ?? int.tryParse(bookingId.replaceAll(RegExp(r'[^0-9]'), ''));

  bool get isPaid {
    final ps = (paymentStatus ?? '').toLowerCase().trim();
    if (ps == 'paid' || ps == 'completed' || ps == 'success') return true;
    if (ps == 'unpaid' || ps == 'pending') return false;
    return status == OrderStatus.completed &&
        !(rawStatus != null && rawStatus!.toLowerCase().contains('unpaid'));
  }

  /// Returns the effective pickup weight in kg (5.0 kg per pickup)
  double get effectiveWeight {
    if (weight != null && weight! > 0) return weight!;
    if (bagsUsed != null && bagsUsed! > 0) return bagsUsed! * 5.0;
    return 5.0;
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
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
        if (weight != null) 'weight': weight,
        if (bagsUsed != null) 'bagsUsed': bagsUsed,
        if (rawStatus != null) 'rawStatus': rawStatus,
        if (paymentStatus != null) 'paymentStatus': paymentStatus,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('pickup_date') ||
        json.containsKey('waste_type') ||
        json.containsKey('street') ||
        json.containsKey('bags_used')) {
      return OrderModel.fromBackendJson(json);
    }

    final parsedId = (json['id'] as num?)?.toInt();
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
      id: parsedId,
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
      weight: (json['weight'] as num?)?.toDouble() ??
          (json['pickup_weight'] as num?)?.toDouble(),
      bagsUsed: (json['bagsUsed'] as num?)?.toInt() ??
          (json['bags_used'] as num?)?.toInt(),
      rawStatus: json['rawStatus'] as String? ?? json['raw_status'] as String?,
      paymentStatus: json['paymentStatus'] as String? ??
          json['payment_status'] as String? ??
          json['payment'] as String?,
    );
  }

  factory OrderModel.fromBackendJson(
    Map<String, dynamic> json, {
    String? defaultUserId,
  }) {
    // 1. Booking ID (support numeric ID, booking_id, or formatted WC-xxx)
    final rawId = json['booking_id'] ?? json['bookingId'] ?? json['id'];
    String bookingId = 'WC-161';
    int? numericId = (json['id'] as num?)?.toInt();
    if (rawId != null) {
      final s = rawId.toString().trim();
      bookingId = s.toUpperCase().startsWith('WC-') ? s : 'WC-$s';
      numericId ??= int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''));
    }

    // 2. Waste Type / Category
    final wasteType = json['waste_type'] as String? ??
        json['wasteType'] as String? ??
        json['items_description'] as String? ??
        'Sanitary waste';

    // 3. Pickup Date
    final rawDate =
        json['pickup_date'] ?? json['pickupDate'] ?? json['created_at'];
    DateTime pickupDate = DateTime(2026, 10, 15);
    if (rawDate is String && rawDate.isNotEmpty) {
      pickupDate = DateTime.tryParse(rawDate) ?? pickupDate;
    } else if (rawDate is DateTime) {
      pickupDate = rawDate;
    }

    // 4. Completed Date
    final completedDateRaw = json['completed_date'] ??
        json['completedDate'] ??
        json['completed_at'] ??
        json['delivered_at'];
    DateTime? parsedCompletedDate;
    if (completedDateRaw is String && completedDateRaw.isNotEmpty) {
      parsedCompletedDate = DateTime.tryParse(completedDateRaw);
    } else if (completedDateRaw is DateTime) {
      parsedCompletedDate = completedDateRaw;
    }

    // 5. Status & Payment Status
    final originalStatus = (json['status'] ??
            json['pickup_status'] ??
            json['order_status'] ??
            json['state'] ??
            '')
        .toString()
        .trim();
    final rawStatus = originalStatus.toLowerCase();

    final rawPayment = (json['payment_status'] ??
            json['paymentStatus'] ??
            json['payment'] ??
            json['bill_status'] ??
            '')
        .toString()
        .trim();
    String? paymentStatus;
    if (rawPayment.isNotEmpty) {
      paymentStatus = rawPayment;
    } else if (json['is_paid'] == true || json['paid'] == true) {
      paymentStatus = 'paid';
    } else if (json['is_paid'] == false || json['paid'] == false) {
      paymentStatus = 'unpaid';
    }

    final bool isCompletedFlag = json['is_completed'] == true ||
        json['completed'] == true ||
        json['is_collected'] == true ||
        json['collected'] == true ||
        json['is_delivered'] == true ||
        json['is_done'] == true;

    OrderStatus status = OrderStatus.pending;
    if (rawStatus.contains('cancel') || json['is_cancelled'] == true) {
      status = OrderStatus.cancelled;
    } else if (rawStatus.contains('reschedul')) {
      status = OrderStatus.reschedule;
    } else if (isCompletedFlag ||
        rawStatus.contains('complete') ||
        rawStatus.contains('deliver') ||
        rawStatus.contains('collect') ||
        rawStatus.contains('picked_up') ||
        rawStatus.contains('pickedup') ||
        rawStatus.contains('picked up') ||
        rawStatus == 'picked' ||
        rawStatus.contains('done') ||
        rawStatus.contains('finish') ||
        rawStatus.contains('success') ||
        rawStatus.contains('closed')) {
      status = OrderStatus.completed;
      parsedCompletedDate ??= pickupDate;
    } else {
      status = OrderStatus.pending;
    }

    // 6. Address
    String address = json['address'] as String? ?? '';
    if (address.isEmpty) {
      final parts = [
        json['street']?.toString().trim(),
        json['city']?.toString().trim(),
        json['district']?.toString().trim(),
      ].where((s) => s != null && s.isNotEmpty).toList();
      address = parts.isNotEmpty ? parts.join(', ') : 'Kerala, India';
    }

    // 7. Full Address
    String fullAddress = json['fullAddress'] as String? ??
        json['full_address'] as String? ??
        '';
    if (fullAddress.isEmpty) {
      final line1 = [
        json['street']?.toString().trim(),
        json['landmark']?.toString().trim(),
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      final line2Parts = [
        json['city']?.toString().trim(),
        json['district']?.toString().trim(),
        json['state']?.toString().trim(),
      ].where((s) => s != null && s.isNotEmpty).toList();

      final zip = json['zip_code']?.toString().trim() ?? '';
      String line2 = line2Parts.join(', ');
      if (zip.isNotEmpty) {
        line2 = line2.isNotEmpty ? '$line2 - $zip' : zip;
      }

      if (line1.isNotEmpty && line2.isNotEmpty) {
        fullAddress = '$line1,\n$line2';
      } else if (line1.isNotEmpty) {
        fullAddress = line1;
      } else if (line2.isNotEmpty) {
        fullAddress = line2;
      } else {
        fullAddress = address;
      }
    }

    // 8. Contact
    final contact = json['contact'] as String? ??
        json['full_name'] as String? ??
        json['contact_number'] as String? ??
        'User';

    // 9. User ID
    final dynamic rawUser = json['userId'] ?? json['user_id'] ?? json['user'];
    String? userId;
    if (rawUser is Map) {
      userId = (rawUser['id'] ?? rawUser['user_id'])?.toString();
    } else if (rawUser != null) {
      userId = rawUser.toString().trim();
    }
    userId ??= defaultUserId;

    // 10. Weight & Bags Used
    final rawWeight = json['weight'] ??
        json['pickup_weight'] ??
        json['waste_weight'] ??
        json['actual_weight'] ??
        json['collected_weight'] ??
        json['total_weight'] ??
        json['net_weight'];
    double? parsedWeight;
    if (rawWeight is num) {
      parsedWeight = rawWeight.toDouble();
    } else if (rawWeight is String && rawWeight.trim().isNotEmpty) {
      final clean = rawWeight.replaceAll(RegExp(r'[^0-9.]'), '');
      parsedWeight = double.tryParse(clean);
    }

    final rawBags = json['bags_used'] ?? json['bagsUsed'] ?? json['bags'];
    int? parsedBags;
    if (rawBags is num) {
      parsedBags = rawBags.toInt();
    } else if (rawBags is String) {
      parsedBags = int.tryParse(rawBags);
    }

    if (parsedWeight == null && parsedBags != null && parsedBags > 0) {
      parsedWeight = parsedBags * 5.0;
    }
    if (parsedWeight == null) {
      final desc =
          (json['items_description'] ?? json['waste_type'] ?? '').toString();
      final match = RegExp(r'(\d+(?:\.\d+)?)\s*kg', caseSensitive: false)
          .firstMatch(desc);
      if (match != null) {
        parsedWeight = double.tryParse(match.group(1) ?? '');
      }
    }

    return OrderModel(
      id: numericId,
      bookingId: bookingId,
      wasteType: wasteType,
      pickupDate: pickupDate,
      completedDate: parsedCompletedDate,
      address: address,
      fullAddress: fullAddress,
      contact: contact,
      status: status,
      userId: userId,
      weight: parsedWeight,
      bagsUsed: parsedBags,
      rawStatus: originalStatus.isNotEmpty ? originalStatus : null,
      paymentStatus: paymentStatus,
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
          weight: 5.0,
        ),
        OrderModel(
          bookingId: 'WC-165',
          wasteType: 'Sanitary waste',
          pickupDate: DateTime(2026, 10, 14),
          address: 'Pattom, Thiruvananthapuram',
          fullAddress: 'TC 14/1250, Pattom,\nThiruvananthapuram - 695004',
          contact: 'User',
          status: OrderStatus.pending,
          weight: 5.0,
        ),
        OrderModel(
          bookingId: 'WC-161',
          wasteType: 'Sanitary waste',
          pickupDate: DateTime(2026, 10, 15),
          address: 'Paruthippara, Thiruvananthapuram',
          fullAddress: 'KRAA/11, Paruthippara,\nThiruvananthapuram - 695015',
          contact: 'User',
          status: OrderStatus.pending,
          weight: 5.0,
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
          weight: 5.0,
        ),
        OrderModel(
          bookingId: 'WC-159',
          wasteType: 'E-Waste & Electronics',
          pickupDate: DateTime(2026, 10, 18),
          address: 'Kowdiar, Thiruvananthapuram',
          fullAddress: 'Plot 42, Kowdiar Avenue,\nThiruvananthapuram - 695003',
          contact: 'User',
          status: OrderStatus.reschedule,
          weight: 5.0,
        ),
        OrderModel(
          bookingId: 'WC-158',
          wasteType: 'Hazardous waste',
          pickupDate: DateTime(2026, 10, 5),
          address: 'Sasthamangalam, Thiruvananthapuram',
          fullAddress: 'House 8B, Sasthamangalam,\nThiruvananthapuram - 695010',
          contact: 'User',
          status: OrderStatus.cancelled,
          weight: 5.0,
        ),
      ];

  static const Set<String> _kSampleBookingIds = {
    'WC-158',
    'WC-159',
    'WC-160',
    'WC-161',
    'WC-165',
    'WC-168',
  };

  static bool isSampleOrder(OrderModel order) =>
      order.userId == null && _kSampleBookingIds.contains(order.bookingId);

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
    final token = await SpHelper.getString(sp_keys.keyToken) ??
        await SpHelper.getString('token');
    if (_currentUserId.isNotEmpty ||
        (token != null && token.trim().isNotEmpty)) {
      orders.value = [];
    }
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
              .where((o) =>
                  _currentUserId.isEmpty ||
                  !isSampleOrder(o) &&
                      (o.userId == null || o.userId == _currentUserId))
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
      final token = await SpHelper.getString(sp_keys.keyToken) ??
          await SpHelper.getString('token');
      if (_currentUserId.isNotEmpty ||
          (token != null && token.trim().isNotEmpty)) {
        orders.value = [];
      } else {
        orders.value = _defaultOrders();
      }
    } catch (_) {
      final token = await SpHelper.getString(sp_keys.keyToken) ??
          await SpHelper.getString('token');
      if (_currentUserId.isNotEmpty ||
          (token != null && token.trim().isNotEmpty)) {
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
      if (o.bookingId == bookingId) {
        o.status = status;
        if (status == OrderStatus.cancelled) {
          o.rawStatus = 'cancelled';
        } else if (status == OrderStatus.reschedule) {
          o.rawStatus = 'reschedule';
        }
      }
    }
    orders.value = List<OrderModel>.from(orders.value);
    _saveToStorage();
  }

  /// Merges remote orders retrieved from backend API into local store.
  /// The backend is the source of truth: orders that no longer exist on the
  /// server (e.g. deleted from admin) are removed from the local cache.
  /// Duplicate records sharing the same bookingId are never created.
  void mergeRemoteOrders(List<OrderModel> remoteOrders) {
    final effectiveUserId = _currentUserId;
    final List<OrderModel> filteredRemote = effectiveUserId.isNotEmpty
        ? remoteOrders
            .where((o) => o.userId == null || o.userId == effectiveUserId)
            .toList()
        : remoteOrders;

    final seen = <String>{};
    orders.value = filteredRemote.where((o) => seen.add(o.bookingId)).toList();
    _saveToStorage();
  }
}
