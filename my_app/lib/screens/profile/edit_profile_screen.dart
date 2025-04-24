import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_bottom_nav.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;

  const EditProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  late TextEditingController _full_nameController;
  late TextEditingController _emailController;
  late TextEditingController _specialtyController;
  late TextEditingController _titleController;

  bool _isLoading = false;
  String? _avatarPath;
  String? _proofPath;
  String? _avatarUrl;
  String? _proofUrl;
  int? _userId;
  int? _roleId;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _active = widget.user?.active ?? true;
    _avatarUrl = widget.user?.avatar;
    _proofUrl = widget.user?.proof;
    _userId = widget.user?.id;
    _roleId = widget.user?.role?.roleId;

    _full_nameController =
        TextEditingController(text: widget.user?.full_name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _specialtyController =
        TextEditingController(text: widget.user?.specialty ?? '');
    _titleController = TextEditingController(text: widget.user?.title ?? '');
  }

  @override
  void dispose() {
    _full_nameController.dispose();
    _emailController.dispose();
    _specialtyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Check file size (max 5MB)
        final file = File(image.path);
        final sizeInBytes = await file.length();
        if (sizeInBytes > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kích thước ảnh không được vượt quá 5MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _isLoading = true;
        });

        try {
          final avatarResponse = await _userService.uploadAvatar(image.path);
          if (kDebugMode) {
            debugPrint('📤 Avatar upload response: $avatarResponse');
          }

          if (avatarResponse['url'] != null) {
            setState(() {
              _avatarUrl = avatarResponse['url'];
              _avatarPath = null; // Clear local path after successful upload
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cập nhật ảnh đại diện thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Lỗi tải lên ảnh đại diện: $e');
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi tải lên ảnh: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking image: $e');
      }
    }
  }

  Future<void> _pickProofFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final sizeInBytes = await file.length();

        // Check file size (max 10MB)
        if (sizeInBytes > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kích thước file không được vượt quá 10MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _isLoading = true;
        });

        try {
          final proofResponse =
              await _userService.uploadProof(result.files.single.path!);
          if (kDebugMode) {
            debugPrint('📤 Proof upload response: $proofResponse');
          }

          if (proofResponse['url'] != null) {
            setState(() {
              _proofUrl = proofResponse['url'];
              _proofPath = null; // Clear local path after successful upload
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tải bằng cấp thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Lỗi tải lên bằng cấp: $e');
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi tải lên bằng cấp: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking proof file: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare user data with the latest URLs
      final updatedUser = User(
        id: _userId!,
        full_name: _full_nameController.text,
        email: _emailController.text,
        title: _titleController.text,
        specialty: _specialtyController.text,
        active: _active,
        avatar: _avatarUrl ?? widget.user?.avatar ?? '',
        proof: _proofUrl ?? widget.user?.proof ?? '',
        role: widget.user?.role,
      );

      if (kDebugMode) {
        debugPrint('📝 Data being sent to API: ${updatedUser.toJson()}');
      }

      // Update user profile
      await _userService.updateUserProfile(_userId!, updatedUser.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi cập nhật thông tin: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBF1),
        elevation: 0,
        leading: BackButton(color: Colors.green),
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(color: Colors.green),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _avatarPath != null
                                ? FileImage(File(_avatarPath!))
                                : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                    ? NetworkImage(_avatarUrl!)
                                        as ImageProvider<Object>
                                    : null,
                            child: (_avatarPath == null &&
                                    (_avatarUrl == null || _avatarUrl!.isEmpty))
                                ? Text(
                                    _full_nameController.text.isNotEmpty
                                        ? _full_nameController.text
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(fontSize: 32),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Fields
                    _buildTextField(
                      label: 'Họ và tên',
                      controller: _full_nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập họ và tên';
                        }
                        return null;
                      },
                    ),

                    _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),

                    _buildTextField(
                      label: 'Chức danh',
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập chức danh';
                        }
                        return null;
                      },
                    ),

                    _buildTextField(
                      label: 'Chuyên ngành',
                      controller: _specialtyController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập chuyên ngành';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Proof File Section
                    const Text(
                      'Giấy tờ chứng minh',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_proofUrl != null && _proofUrl!.isNotEmpty) ...[
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
                              const Icon(Icons.picture_as_pdf,
                                  color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Giấy tờ hiện tại: ${_proofUrl!.split('/').last}',
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
                      const SizedBox(height: 8),
                    ],

                    InkWell(
                      onTap: _pickProofFile,
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
                                _proofPath != null
                                    ? _proofPath!.split('/').last
                                    : 'Chọn file PDF',
                                style: TextStyle(
                                  decoration: _proofPath != null
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                            Icon(
                              _proofPath != null
                                  ? Icons.upload_file
                                  : Icons.add,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hỗ trợ: PDF (Tối đa 10MB)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Lưu thay đổi'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 3,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
