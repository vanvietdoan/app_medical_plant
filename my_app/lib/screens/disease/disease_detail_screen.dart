import 'package:flutter/material.dart';
import '../../models/disease.dart';
import '../../services/disease_service.dart';


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
  Disease? _disease;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDisease();
  }

  Future<void> _loadDisease() async {
    try {
      setState(() => _isLoading = true);
      final disease = await _diseaseService.getDiseaseById(widget.diseaseId);
      setState(() {
        _disease = disease;
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text(
                        _disease!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_disease!.symptoms != null) ...[
                        const Text(
                          'Triệu chứng:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _disease!.symptoms!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_disease!.description != null) ...[
                        const Text(
                          'Mô tả:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _disease!.description!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_disease!.instructions != null) ...[
                        const Text(
                          'Hướng dẫn điều trị:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _disease!.instructions!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
