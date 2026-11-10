class PickupSlotModel {
  final int id;
  final String date;
  final String timeSlot;
  final int availableSpots;
  final String district;
  final String localBody;

  const PickupSlotModel({
    required this.id,
    required this.date,
    required this.timeSlot,
    required this.availableSpots,
    required this.district,
    required this.localBody,
  });

  factory PickupSlotModel.fromJson(Map<String, dynamic> json) {
    return PickupSlotModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      date: json['date']?.toString() ?? '',
      timeSlot: json['time_slot']?.toString() ?? '',
      availableSpots: json['available_spots'] is int
          ? json['available_spots'] as int
          : int.tryParse(json['available_spots']?.toString() ?? '0') ?? 0,
      district: json['district']?.toString() ?? '',
      localBody: json['local_body']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time_slot': timeSlot,
        'available_spots': availableSpots,
        'district': district,
        'local_body': localBody,
      };

  DateTime? get parsedDate {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } catch (_) {}
    return null;
  }
}

class AvailablePickupSlotsResponse {
  final int totalAvailable;
  final List<PickupSlotModel> slots;

  const AvailablePickupSlotsResponse({
    required this.totalAvailable,
    required this.slots,
  });

  factory AvailablePickupSlotsResponse.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'];
    final list = <PickupSlotModel>[];
    if (rawSlots is List) {
      for (final s in rawSlots) {
        if (s is Map<String, dynamic>) {
          list.add(PickupSlotModel.fromJson(s));
        } else if (s is Map) {
          list.add(PickupSlotModel.fromJson(Map<String, dynamic>.from(s)));
        }
      }
    }
    return AvailablePickupSlotsResponse(
      totalAvailable: json['total_available'] is int
          ? json['total_available'] as int
          : int.tryParse(json['total_available']?.toString() ?? '0') ??
              list.length,
      slots: list,
    );
  }
}

