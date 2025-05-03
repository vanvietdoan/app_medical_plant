import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_bottom_nav.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<User> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = UserService().getUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thông tin người dùng')),
      body: FutureBuilder<User>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  Text(snapshot.error.toString()),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    onPressed: () {
                      setState(() {
                        futureUser = UserService().getUserProfile(widget.userId);
                      });
                    },
                  )
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.avatar ?? 'https://your.domain/default-avatar.png'),
                  ),
                  const SizedBox(height: 16),
                  Text(user.full_name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  if (user.title != null) Text(user.title!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  buildInfoItem(Icons.email, 'Email', user.email),
                  buildInfoItem(Icons.school, 'Chuyên ngành', user.specialty),
                  buildInfoItem(Icons.picture_as_pdf, 'Chứng chỉ', user.proof != null
                      ? 'Nhấn để xem'
                      : 'Chưa có', onTap: user.proof != null
                      ? () => launchUrl(Uri.parse(user.proof!))
                      : null),
                  buildInfoItem(Icons.verified_user, 'Vai trò', user.role?.name ?? 'Chưa xác định'),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Không có dữ liệu'));
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 3,
      ),
    );
  }

  Widget buildInfoItem(IconData icon, String label, String? value,
      {VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(label),
      subtitle: Text(value ?? 'Không có'),
      onTap: onTap,
    );
  }

  String formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    return date != null ? '${date.day}/${date.month}/${date.year}' : 'Không xác định';
  }
}
