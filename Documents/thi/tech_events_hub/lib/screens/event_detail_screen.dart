import 'package:flutter/material.dart';
import '../models.dart';
import '../api_service.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      bool success = await ApiService().registerEvent(
        widget.event.id,
        _nameCtrl.text,
        _emailCtrl.text,
        _phoneCtrl.text,
      );

      setState(() => _isLoading = false);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Đăng ký thành công!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Lỗi hệ thống!'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200, width: double.infinity, color: Colors.grey[300],
              child: const Icon(Icons.image, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(widget.event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(widget.event.date.toString().split(' ')[0]),
              const SizedBox(width: 20),
              const Icon(Icons.folder, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(widget.event.categoryName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ]),
            const SizedBox(height: 16),
            const Text("Mô tả:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.event.description),
            const Divider(height: 40, thickness: 2),

            // FORM
            const Text("📝 Đăng ký tham gia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: "Họ và tên", prefixIcon: Icon(Icons.person)),
                    validator: (v) => v!.isEmpty ? "Vui lòng nhập tên" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                    validator: (v) {
                      if (v!.isEmpty) return "Nhập email";
                      if (!v.contains('@') || !v.contains('.')) return "Email không hợp lệ";
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(labelText: "Số điện thoại", prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v!.isEmpty) return "Nhập SĐT";
                      if (v.length < 10) return "SĐT tối thiểu 10 số";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("GỬI ĐĂNG KÝ", style: TextStyle(fontSize: 16)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}