class PickupOptionModel {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final String estimatedWeight;

  const PickupOptionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.estimatedWeight,
  });
}

class PickupBookingModel {
  final String optionId;
  final String pickupDate;
  final String timeSlot;
  final String addressId;
  final String? notes;

  const PickupBookingModel({
    required this.optionId,
    required this.pickupDate,
    required this.timeSlot,
    required this.addressId,
    this.notes,
  });
}

class HomeBannerModel {
  final String title;
  final String subtitle;
  final String actionText;

  const HomeBannerModel({
    required this.title,
    required this.subtitle,
    required this.actionText,
  });
}
