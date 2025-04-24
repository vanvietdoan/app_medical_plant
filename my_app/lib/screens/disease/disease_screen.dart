import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/disease_service.dart';
import '../../models/disease.dart';
import 'disease_detail_screen.dart';

class DiseaseScreen extends StatefulWidget {
  const DiseaseScreen({super.key});

  @override
  State<DiseaseScreen> createState() => _DiseaseScreenState();
}

class _DiseaseScreenState extends State<DiseaseScreen> {
  final DiseaseService _diseaseService = DiseaseService();
  List<Disease> _diseases = [];
  List<Disease> _filteredDiseases = [];
  List<String> _symptoms = [];
  List<String> _selectedSymptoms = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  Future<void> _loadDiseases() async {
    try {
      setState(() => _isLoading = true);
      final diseases = await _diseaseService.getDiseases();

      final allSymptoms = diseases
          .where((d) => d.symptoms != null)
          .map((d) => d.symptoms!.split(','))
          .expand((symptoms) => symptoms)
          .map((symptom) => symptom.trim())
          .where((symptom) => symptom.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _diseases = diseases;
        _filteredDiseases = diseases;
        _symptoms = allSymptoms;
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

  void _filterDiseases() {
    setState(() {
      _filteredDiseases = _diseases.where((disease) {
        final matchesSearch =
            disease.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (disease.symptoms
                        ?.toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false);

        final matchesSymptoms = _selectedSymptoms.isEmpty ||
            _selectedSymptoms.every((symptom) =>
                disease.symptoms
                    ?.toLowerCase()
                    .contains(symptom.toLowerCase()) ??
                false);

        return matchesSearch && matchesSymptoms;
      }).toList();
    });
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
      _filterDiseases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm bệnh....',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _filterDiseases();
                    },
                  ),
                  const SizedBox(height: 8),
                  if (_selectedSymptoms.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedSymptoms
                          .map((symptom) => Chip(
                                label: Text(symptom),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () => _toggleSymptom(symptom),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Tất cả'),
                          selected: _selectedSymptoms.isEmpty,
                          onSelected: (selected) {
                            setState(() => _selectedSymptoms.clear());
                            _filterDiseases();
                          },
                        ),
                        ..._symptoms
                            .map((symptom) => Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: FilterChip(
                                    label: Text(symptom),
                                    selected:
                                        _selectedSymptoms.contains(symptom),
                                    onSelected: (selected) =>
                                        _toggleSymptom(symptom),
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ],
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredDiseases.isEmpty
                      ? const Center(
                          child: Text('Không tìm thấy bệnh phù hợp'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredDiseases.length,
                          itemBuilder: (context, index) {
                            final disease = _filteredDiseases[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DiseaseDetailScreen(
                                        diseaseId: disease.disease_id,
                                      ),
                                    ),
                                  );
                                },
                                child: ExpansionTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: ClipOval(
                                      child: SizedBox.expand(
                                        child: Image.asset(
                                          'images/diseases/infec.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(disease.name),
                                  subtitle: Text(disease.symptoms ??
                                      'Không có triệu chứng'),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (disease.symptoms != null) ...[
                                            const Text(
                                              'Triệu chứng:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(disease.symptoms!),
                                            const SizedBox(height: 16),
                                          ],
                                          if (disease.instructions != null) ...[
                                            const Text(
                                              'Hướng dẫn điều trị:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(disease.instructions!),
                                            const SizedBox(height: 16),
                                          ],
                                          if (disease.images.isNotEmpty) ...[
                                            const Text(
                                              'Hình ảnh:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 120,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    disease.images.length,
                                                itemBuilder:
                                                    (context, imgIndex) {
                                                  final image =
                                                      disease.images[imgIndex];
                                                  return Card(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 8),
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: Column(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .vertical(
                                                              top: Radius
                                                                  .circular(4),
                                                            ),
                                                            child:
                                                                Image.network(
                                                              image.url,
                                                              height: 70,
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return Image
                                                                    .asset(
                                                                  '',
                                                                  height: 70,
                                                                  width: double
                                                                      .infinity,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: Text(
                                                              image.name,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 2,
      ),
    );
  }
}
