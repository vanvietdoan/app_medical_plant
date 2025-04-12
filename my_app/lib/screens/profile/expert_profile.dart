import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../home_screen.dart';
import '../auth/login_screen.dart'; 
import '../../widgets/custom_app_bar.dart'; 
import '../../widgets/custom_bottom_nav.dart';
import '../../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

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
    _fullNameController = TextEditingController(text: widget.expert.fullName);
    _emailController = TextEditingController(text: widget.expert.email);
    _specialtyController = TextEditingController(text: widget.expert.specialty);
    _titleController = TextEditingController(text: widget.expert.title);
  }

  @override
  void dispose() {
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
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.expert.avatar.isNotEmpty
                        ? NetworkImage(widget.expert.avatar)
                        : null,
                    child: widget.expert.avatar.isEmpty
                        ? Text(
                            widget.expert.fullName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                  if (widget.expert.avatar.isNotEmpty)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Role Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.expert.role?.name ?? 'Chuyên gia',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Information
            _buildInfoSection('Họ và tên', widget.expert.fullName),
            _buildInfoSection('Email', widget.expert.email),
            _buildInfoSection('Chức danh', widget.expert.title),
            _buildInfoSection('Chuyên ngành', widget.expert.specialty),

            // Proof File Section
            if (widget.expert.proof.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Giấy tờ chứng minh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // TODO: Implement PDF viewer
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.expert.proof,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Icon(Icons.download, size: 20),
                    ],
                  ),
                ),
              ),
            ],

            // Account Status
            if (!widget.expert.active)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tài khoản chưa được kích hoạt',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit),
                      label: const Text('Chỉnh sửa thông tin'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _changePassword,
                      icon: const Icon(Icons.lock),
                      label: const Text('Đổi mật khẩu'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 3,
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: widget.expert),
      ),
    );
  }

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
