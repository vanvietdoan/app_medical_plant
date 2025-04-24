import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/profile/expert_profile.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AuthService _authService = AuthService();

  CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return AppBar(
      backgroundColor: const Color(0xFFF7FBF1),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo app bên trái
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
              
            ],
          ),
          // Avatar và tên user bên phải
          Row(
            children: [
              if (currentUser != null) ...[
                Text(
                  currentUser.full_name,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: () {
                  if (currentUser == null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpertProfile(expert: currentUser),
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green,
                  child: currentUser?.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            currentUser!.avatar,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 