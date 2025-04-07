import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../home_screen.dart';
import '../auth/login_screen.dart'; 
import '../../widgets/custom_app_bar.dart'; 
import '../../widgets/custom_bottom_nav.dart';
import '../../services/auth_service.dart';

class ExpertProfile extends StatefulWidget {
  final User expert;

  const ExpertProfile({
    Key? key,
    required this.expert,
  }) : super(key: key);

  @override
  ExpertProfileState createState() => ExpertProfileState();
}

class ExpertProfileState extends State<ExpertProfile> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _specialtyController;
  late TextEditingController _titleController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với giá trị hiện tại
    _fullNameController = TextEditingController(text: widget.expert.fullName);
    _emailController = TextEditingController(text: widget.expert.email);
    _specialtyController = TextEditingController(text: widget.expert.specialty);
    _titleController = TextEditingController(text: widget.expert.title);
  }

  @override
  void dispose() {
    // Giải phóng các controller
    _fullNameController.dispose();
    _emailController.dispose();
    _specialtyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin chuyên gia'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _handleLogout(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.expert.avatar),
                child: widget.expert.avatar.isEmpty
                    ? Text(
                        widget.expert.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _buildEditableInfoSection('Họ và tên', _fullNameController),
            _buildEditableInfoSection('Email', _emailController),
            _buildEditableInfoSection('Chuyên ngành', _specialtyController),
            _buildEditableInfoSection('Chức danh', _titleController),
            if (!widget.expert.active)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Tài khoản chưa được kích hoạt',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            _isEditing
                ? ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text('Lưu'),
                  )
                : ElevatedButton(
                    onPressed: _editProfile,
                    child: const Text('Sửa'),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 3,
      ),
    );
  }

  Widget _buildEditableInfoSection(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          _isEditing
              ? TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                )
              : Text(
                  controller.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ],
      ),
    );
  }

  // Hàm sửa thông tin
  void _editProfile() {
    setState(() {
      _isEditing = true;
    });
  }

  // Hàm lưu thông tin
  void _saveChanges() {
    setState(() {
      _isEditing = false;
    });
   
  }

  // Hàm xử lý đăng xuất
  void _handleLogout(BuildContext context) {
    final authService = AuthService();
    authService.logout();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}
