import 'package:flutter/material.dart';

class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết cây thuốc'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/plant_placeholder.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đinh lăng',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Polyscias fruticosa',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Mô tả',
                    'Đinh lăng là cây thân gỗ nhỏ, cao 2-3m. Thân cây có nhiều đốt và phân cành. Lá kép lông chim 2-3 lần, mọc so le...',
                  ),
                  _buildSection(
                    'Phân loại khoa học',
                    '''Ngành: Magnoliophyta
Lớp: Magnoliopsida
Bộ: Apiales
Họ: Araliaceae
Chi: Polyscias
Loài: P. fruticosa''',
                  ),
                  _buildSection(
                    'Công dụng',
                    '''- Tăng cường sức đề kháng
- Chống mệt mỏi
- Giảm stress
- Tăng trí nhớ
- Điều hòa huyết áp''',
                  ),
                  _buildSection(
                    'Hướng dẫn sử dụng',
                    '''1. Dạng thuốc sắc:
- Liều dùng: 10-15g/ngày
- Đun với 400ml nước còn 100ml
- Chia 2-3 lần uống trong ngày

2. Dạng rượu ngâm:
- 100g rễ đinh lăng
- Ngâm với 1 lít rượu 35-40 độ
- Ngâm trong 1 tháng
- Uống 15-20ml/lần, ngày 2-3 lần''',
                  ),
                  _buildSection(
                    'Thời gian thu hoạch',
                    '''- Thời điểm tốt nhất: Mùa thu - đông
- Tuổi cây: 3-5 năm
- Nhận biết: Rễ to, vỏ nâu vàng, thịt rễ trắng ngà
- Bảo quản: Nơi khô ráo, thoáng mát''',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.green,
                width: 4,
              ),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }
} 