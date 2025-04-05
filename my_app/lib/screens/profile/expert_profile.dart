import 'package:flutter/material.dart';
import '../../models/user.dart';

class ExpertProfile extends StatelessWidget {
  final User expert;

  const ExpertProfile({
    Key? key,
    required this.expert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ chuyên gia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: expert.avatarUrl != null
                    ? NetworkImage(expert.avatarUrl!)
                    : null,
                child: expert.avatarUrl == null
                    ? Text(
                        expert.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoSection('Họ và tên', expert.fullName),
            _buildInfoSection('Email', expert.email),
            _buildInfoSection('Chuyên ngành', expert.specialty),
            if (expert.title != null)
              _buildInfoSection('Chức danh', expert.title!),
            if (expert.phoneNumber != null)
              _buildInfoSection('Số điện thoại', expert.phoneNumber!),
            if (expert.specialization != null)
              _buildInfoSection('Chuyên môn', expert.specialization!),
            if (expert.experience != null)
              _buildInfoSection('Kinh nghiệm', '${expert.experience} năm'),
            if (expert.bio != null) 
              _buildInfoSection('Giới thiệu', expert.bio!),
          ],
        ),
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
        ],
      ),
    );
  }
} 