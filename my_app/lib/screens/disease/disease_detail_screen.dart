import 'package:flutter/material.dart';
import '../../models/disease.dart' as disease_model;
import '../../models/advice.dart';
import '../../models/user.dart';
import '../../services/disease_service.dart';
import '../../services/advice_service.dart';
import '../../screens/plants/plant_detail_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'package:intl/intl.dart';

class DiseaseDetailScreen extends StatefulWidget {
  final int diseaseId;

  const DiseaseDetailScreen({
    super.key,
    required this.diseaseId,
  });

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  final DiseaseService _diseaseService = DiseaseService();
  final AdviceService _adviceService = AdviceService();
  disease_model.Disease? _disease;
  List<Advice> _advices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final disease = await _diseaseService.getDiseaseById(widget.diseaseId);
      final advices =
          await _adviceService.getAdvicesByDisease(widget.diseaseId);
      setState(() {
        _disease = disease;
        _advices = advices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_disease?.name ?? 'Chi tiết bệnh'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _disease == null
              ? const Center(child: Text('Không tìm thấy thông tin bệnh'))
              : Column(
                  children: [
                    if (_disease!.images.isNotEmpty) ...[
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _disease!.images.length,
                          itemBuilder: (context, index) {
                            final image = _disease!.images[index];
                            return Container(
                              width: 300,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(image.url),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    // Handle image loading error
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: DiseaseDetails(disease: _disease!),
                          ),
                          Expanded(
                            flex: 1,
                            child: AdviceList(advices: _advices),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 2,
      ),
    );
  }
}

class DiseaseDetails extends StatelessWidget {
  final disease_model.Disease disease;

  const DiseaseDetails({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            disease.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (disease.symptoms != null) ...[
            const Text(
              'Triệu chứng:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              disease.symptoms!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
          ],
          if (disease.description != null) ...[
            const Text(
              'Mô tả:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              disease.description!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
          ],
          if (disease.instructions != null) ...[
            const Text(
              'Hướng dẫn điều trị:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              disease.instructions!,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class AdviceList extends StatelessWidget {
  final List<Advice> advices;

  const AdviceList({super.key, required this.advices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Lời khuyên từ chuyên gia',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: advices.length,
            itemBuilder: (context, index) {
              return AdviceCard(advice: advices[index]);
            },
          ),
        ),
      ],
    );
  }
}

class AdviceCard extends StatelessWidget {
  final Advice advice;

  const AdviceCard({super.key, required this.advice});

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('HH:mm - dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (advice.user != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: advice.user!.avatar.isNotEmpty
                        ? NetworkImage(advice.user!.avatar)
                        : null,
                    backgroundColor: Colors.green,
                    child: advice.user!.avatar.isEmpty
                        ? Text(
                            advice.user!.fullName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advice.user!.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          advice.user!.title,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text(
              advice.title ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(
              advice.content ?? '',
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
            if (advice.plant != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlantDetailScreen(
                        plantId: advice.plant!.plantId,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_florist,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        advice.plant!.name,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _formatDate(advice.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
