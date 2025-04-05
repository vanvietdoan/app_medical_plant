import 'package:flutter/material.dart';
import 'package:my_app/screens/auth/login_screen.dart';
import 'package:my_app/screens/auth/signup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual authentication check
    bool isLoggedIn = false;

    return SafeArea(
      child: isLoggedIn ? _buildLoggedInView(context) : _buildLoggedOutView(context),
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 100,
          ),
          const SizedBox(height: 40),
          const Text(
            'Đăng nhập để xem thông tin cá nhân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Đăng nhập để chia sẻ kiến thức và đóng góp cho cộng đồng',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              if (result == true) {
                // If login was successful, rebuild the screen to show logged in view
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text(
              'Đăng nhập',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: const BorderSide(color: Colors.green),
            ),
            child: const Text(
              'Đăng ký',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TS. Nguyễn Văn A',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Chuyên khoa: Dược liệu',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Navigate to edit profile
                },
                icon: const Icon(Icons.edit),
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Đơn vị công tác',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bệnh viện Y học cổ truyền Trung ương',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'Giới thiệu bản thân',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chuyên gia với hơn 20 năm kinh nghiệm trong lĩnh vực y học cổ truyền và dược liệu. Tham gia nghiên cứu và phát triển nhiều bài thuốc từ thảo dược.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          const Text(
            'Đề xuất gần đây',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.healing, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text(
                            'Đau đầu',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '24/03/2024',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sử dụng đinh lăng kết hợp với gừng tươi để điều trị đau đầu...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
} 