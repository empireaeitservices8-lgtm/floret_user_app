class NotificationItemModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final String category; // 'All', 'Upcoming', 'Delivered'
  final bool isRead;
  final String? userId;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    this.isRead = false,
    this.userId,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
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
      };
}
