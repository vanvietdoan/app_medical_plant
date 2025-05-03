import 'package:flutter/material.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/screens/profile/expert_profile.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:file_picker/file_picker.dart' as FilePicker;
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Plant App',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Giả sử bạn có logic tự động lấy lại thông tin user nếu đã login trước đó
    // Ví dụ: từ shared_preferences hoặc API /me
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    if (currentUser != null) {
      return ExpertProfile(expert: currentUser);
    } else {
      return const HomeScreen();
    }
  }
}
