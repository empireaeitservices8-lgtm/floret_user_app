class SettingsTileModel {
  final String title;
  final String subtitle;
  final String icon;
  final String routeName;

  const SettingsTileModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.routeName,
  });
}

class FaqItemModel {
  final String question;
  final String answer;

  const FaqItemModel({
    required this.question,
    required this.answer,
  });
}

class NotificationPreferencesModel {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsAlerts;
  final bool promotionalUpdates;

  const NotificationPreferencesModel({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsAlerts = false,
    this.promotionalUpdates = false,
  });

  NotificationPreferencesModel copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsAlerts,
    bool? promotionalUpdates,
  }) {
    return NotificationPreferencesModel(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsAlerts: smsAlerts ?? this.smsAlerts,
      promotionalUpdates: promotionalUpdates ?? this.promotionalUpdates,
    );
  }
}
