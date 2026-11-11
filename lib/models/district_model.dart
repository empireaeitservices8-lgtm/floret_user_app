class DistrictModel {
  final int id;
  final String name;
  final dynamic state;

  const DistrictModel({
    required this.id,
    required this.name,
    this.state,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
      };

  static List<String> parseDistricts(dynamic data) {
    final List<String> list = [];
    if (data is List) {
      for (final item in data) {
        if (item is Map) {
          final model = DistrictModel.fromJson(Map<String, dynamic>.from(item));
          if (model.name.trim().isNotEmpty && !list.contains(model.name.trim())) {
            list.add(model.name.trim());
          }
        } else if (item is String &&
            item.trim().isNotEmpty &&
            !list.contains(item.trim())) {
          list.add(item.trim());
        }
      }
    } else if (data is Map) {
      final rawList = data['districts'] ?? data['results'] ?? data['data'];
      if (rawList is List) {
        for (final item in rawList) {
          if (item is Map) {
            final model =
                DistrictModel.fromJson(Map<String, dynamic>.from(item));
            if (model.name.trim().isNotEmpty &&
                !list.contains(model.name.trim())) {
              list.add(model.name.trim());
            }
          } else if (item is String &&
              item.trim().isNotEmpty &&
              !list.contains(item.trim())) {
            list.add(item.trim());
          }
        }
      }
    }
    return list;
  }
}

