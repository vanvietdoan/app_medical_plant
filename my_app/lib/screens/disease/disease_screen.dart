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
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredDiseases.isEmpty
                      ? const Center(
                          child: Text('Không tìm thấy bệnh phù hợp'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredDiseases.length,
                          itemBuilder: (context, index) {
                            final disease = _filteredDiseases[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor:
                                                Colors.red.shade100,
                                            child: ClipOval(
                                              child: SizedBox.expand(
                                                child: Image.asset(
                                                  'images/diseases/infec.jpg',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  disease.name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (disease.symptoms !=
                                                    null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    disease.symptoms!,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (disease.images.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: disease.images.length,
                                            itemBuilder: (context, imgIndex) {
                                              final image =
                                                  disease.images[imgIndex];
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                    right: 8),
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                    image:
                                                        NetworkImage(image.url),
                                                    fit: BoxFit.cover,
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
