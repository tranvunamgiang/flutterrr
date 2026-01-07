class Config {
  // Dùng 10.0.2.2 cho Android Emulator
  static const String baseUrl = "http://10.0.2.2:1337/api";
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? 'Tất cả',
    );
  }
}

class Event {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime date;
  final String categoryName;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.categoryName,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Xử lý Category an toàn (tránh null)
    String catName = 'Chưa phân loại';
    if (json['category'] != null && json['category']['name'] != null) {
      catName = json['category']['name'];
    }

    return Event(
      id: json['id'],
      title: json['title'] ?? 'Không có tiêu đề',
      description: json['description'] ?? '',
      // Xử lý ảnh: Nếu Strapi trả về object ảnh thì lấy url, nếu không để rỗng
      imageUrl: json['imageUrl'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      categoryName: catName,
    );
  }
}