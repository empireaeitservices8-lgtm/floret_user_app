class NotificationItemModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final String category; // 'All', 'Upcoming', 'Delivered'
  final bool isRead;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    this.isRead = false,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      time: json['time'] as String? ?? '',
      category: json['category'] as String? ?? 'All',
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'time': time,
        'category': category,
        'isRead': isRead,
      };
}
