import 'package:flutter/material.dart';
import 'package:my_app/screens/plants/plant_detail_screen.dart';

class DiseaseScreen extends StatelessWidget {
  const DiseaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bệnh....',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Các bệnh thường gặp',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.healing,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text('Đau đầu'),
                    subtitle: const Text('Triệu chứng phổ biến'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Triệu chứng:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '- Đau nhức đầu\n- Chóng mặt\n- Buồn nôn',
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Cây thuốc được đề xuất:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PlantDetailScreen(),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: SizedBox(
                                        width: 100,
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                              child: Image.asset(
                                                'assets/images/plant_placeholder.png',
                                                height: 70,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Text(
                                                'Đinh lăng',
                                                style: TextStyle(fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Đề xuất của chuyên gia:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildExpertRecommendation(),
                            _buildExpertRecommendation(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertRecommendation() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TS. Nguyễn Văn A',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Chuyên khoa: Dược liệu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Sử dụng đinh lăng kết hợp với gừng tươi để điều trị đau đầu. Có thể dùng dưới dạng thuốc sắc hoặc ngâm rượu, tùy theo tình trạng bệnh.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Đề xuất ngày: 24/03/2024',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 