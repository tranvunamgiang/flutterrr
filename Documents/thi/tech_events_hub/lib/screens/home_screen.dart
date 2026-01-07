// File: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Event>> futureEvents;

  @override
  void initState() {
    super.initState();
    // Gọi API khi màn hình khởi tạo
    futureEvents = ApiService().getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tech-Events Hub')),
      body: FutureBuilder<List<Event>>(
        future: futureEvents,
        builder: (context, snapshot) {
          // Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Trạng thái lỗi
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text('Lỗi: ${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            futureEvents = ApiService().getEvents();
                          });
                        },
                        child: const Text("Thử lại")
                    )
                  ],
                ),
              ),
            );
          }
          // Trạng thái có dữ liệu nhưng rỗng
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có sự kiện nào'));
          }

          // Trạng thái hiển thị danh sách
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Event event = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.event_available, size: 40, color: Colors.blue),
                  title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${event.categoryName} • ${event.date.toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            futureEvents = ApiService().getEvents(); // Nút làm mới dữ liệu
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}