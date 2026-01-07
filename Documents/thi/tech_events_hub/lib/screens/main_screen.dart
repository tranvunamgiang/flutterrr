import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models.dart';
import 'event_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Tab hiện tại

  // Biến dữ liệu
  List<Event> _events = [];
  List<Category> _categories = [];
  int _selectedCategoryId = 0; // 0 = Tất cả

  // Biến phân trang
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true; // Còn dữ liệu để tải ko?
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadEvents();

    // Lắng nghe cuộn xuống đáy
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadEvents();
      }
    });
  }

  Future<void> _loadCategories() async {
    final cats = await ApiService().getCategories();
    setState(() {
      _categories = [Category(id: 0, name: "Tất cả"), ...cats];
    });
  }

  Future<void> _loadEvents() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      List<Event> newEvents = await ApiService().getEvents(
        page: _page,
        categoryId: _selectedCategoryId,
      );

      setState(() {
        _page++;
        _events.addAll(newEvents);
        if (newEvents.length < 5) _hasMore = false; // Nếu tải về < 5 tin nghĩa là hết rồi
      });
    } catch (e) {
      print("Lỗi tải events: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onCategorySelected(int id) {
    if (_selectedCategoryId == id) return;
    setState(() {
      _selectedCategoryId = id;
      _events.clear(); // Xóa list cũ
      _page = 1;       // Reset trang
      _hasMore = true;
    });
    _loadEvents();
  }

  // --- UI TAB HOME ---
  Widget _buildHomeTab() {
    return Column(
      children: [
        // 1. Thanh lọc Category
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey[100],
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = cat.id == _selectedCategoryId;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(cat.name),
                  selected: isSelected,
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  onSelected: (_) => _onCategorySelected(cat.id),
                ),
              );
            },
          ),
        ),

        // 2. Danh sách Event
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _onCategorySelected(_selectedCategoryId); // Load lại từ đầu
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _events.length + 1,
              itemBuilder: (context, index) {
                if (index == _events.length) {
                  return _hasMore
                      ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
                      : const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Đã hết sự kiện")));
                }

                final event = _events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: Container(
                      width: 60, height: 60,
                      color: Colors.blue[100],
                      child: const Icon(Icons.event_note, color: Colors.blue),
                    ),
                    title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text("📅 ${event.date.toString().split(' ')[0]}"),
                        Text("📂 ${event.categoryName}", style: const TextStyle(color: Colors.blueGrey)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- SCAFFOLD CHÍNH ---
  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildHomeTab(),
      const Center(child: Text("Màn hình Cá nhân (Đang phát triển)")),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech-Events Hub', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue[800],
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Sự kiện'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}