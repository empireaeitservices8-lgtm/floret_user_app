class NotificationItemModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final String category; // 'All', 'Upcoming', 'Delivered'
  final bool isRead;
  final String? userId;
  final DateTime? scheduledDate;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    this.isRead = false,
    this.userId,
    this.scheduledDate,
  });

  /// Helper to get the effective scheduled date, falling back to parsing [time]
  DateTime? get effectiveScheduledDate {
    if (scheduledDate != null) return scheduledDate;
    return parseFlexibleDate(time);
  }

  static DateTime? parseFlexibleDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    final trimmed = dateStr.trim();
    final direct = DateTime.tryParse(trimmed);
    if (direct != null) return direct;

    final parts = trimmed.split(RegExp(r'[\s\-/,]+'));
    if (parts.length >= 3) {
      int? year;
      int? month;
      int? day;

      if (parts[0].length == 4) {
        year = int.tryParse(parts[0]);
        month = _parseMonth(parts[1]);
        day = int.tryParse(parts[2]);
      } else {
        day = int.tryParse(parts[0]);
        month = _parseMonth(parts[1]);
        year = int.tryParse(parts[2]);
      }

      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  static int? _parseMonth(String str) {
    final direct = int.tryParse(str);
    if (direct != null && direct >= 1 && direct <= 12) return direct;
    const months = {
      'jan': 1, 'january': 1,
      'feb': 2, 'february': 2,
      'mar': 3, 'march': 3,
      'apr': 4, 'april': 4,
      'may': 5,
      'jun': 6, 'june': 6,
      'jul': 7, 'july': 7,
      'aug': 8, 'august': 8,
      'sep': 9, 'september': 9,
      'oct': 10, 'october': 10,
      'nov': 11, 'november': 11,
      'dec': 12, 'december': 12,
    };
    return months[str.toLowerCase()];
  }

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    final scheduledDateRaw = json['scheduledDate'] ??
        json['scheduled_date'] ??
        json['pickup_date'] ??
        json['pickupDate'];
    DateTime? parsedScheduledDate;
    if (scheduledDateRaw is String && scheduledDateRaw.isNotEmpty) {
      parsedScheduledDate = DateTime.tryParse(scheduledDateRaw);
    } else if (scheduledDateRaw is DateTime) {
      parsedScheduledDate = scheduledDateRaw;
    }

    return NotificationItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      time: json['time'] as String? ??
          json['completed_at'] as String? ??
          json['created_at'] as String? ??
          '',
      category: json['category'] as String? ?? 'All',
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      userId: json['userId']?.toString() ??
          json['user_id']?.toString() ??
          json['user']?.toString(),
      scheduledDate: parsedScheduledDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'time': time,
        'category': category,
        'isRead': isRead,
        if (userId != null) 'userId': userId,
        if (scheduledDate != null)
          'scheduledDate': scheduledDate!.toIso8601String(),
      };

  NotificationItemModel copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    String? category,
    bool? isRead,
    String? userId,
    DateTime? scheduledDate,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }
}
