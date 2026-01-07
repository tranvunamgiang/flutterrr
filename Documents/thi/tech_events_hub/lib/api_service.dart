import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  // 1. Lấy danh sách danh mục
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/categories'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];
        return data.map((json) => Category.fromJson(json)).toList();
      }
    } catch (e) {
      print("Lỗi lấy danh mục: $e");
    }
    return [];
  }

  // 2. Lấy sự kiện (Có phân trang & Lọc)
  Future<List<Event>> getEvents({int page = 1, int pageSize = 5, int? categoryId}) async {
    // populate=* để lấy cả category
    String url = '${Config.baseUrl}/events?populate=*&pagination[page]=$page&pagination[pageSize]=$pageSize';

    // Thêm bộ lọc nếu có chọn category (ID khác 0)
    if (categoryId != null && categoryId != 0) {
      url += '&filters[category][id][\$eq]=$categoryId';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];
      return data.map((eventJson) => Event.fromJson(eventJson)).toList();
    } else {
      throw Exception('Lỗi tải dữ liệu: ${response.statusCode}');
    }
  }

  // 3. Gửi đăng ký tham gia
  Future<bool> registerEvent(int eventId, String name, String email, String phone) async {
    final url = Uri.parse('${Config.baseUrl}/registrations');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'data': {
            'event': eventId,
            'name': name,
            'email': email,
            'phone': phone,
            'registrationDate': DateTime.now().toIso8601String(),
          }
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Lỗi đăng ký: $e");
      return false;
    }
  }
}