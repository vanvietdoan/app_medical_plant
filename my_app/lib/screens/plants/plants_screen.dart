import 'package:flutter/material.dart';
import 'package:my_app/screens/plants/plant_detail_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_app_bar.dart';
import '../home_screen.dart';
import '../disease/disease_screen.dart';
import '../auth/login_screen.dart';
import '../profile/expert_profile.dart';
import '../../services/auth_service.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  String? _selectedBranch;
  String? _selectedClass;
  String? _selectedOrder;
  String? _selectedFamily;
  String? _selectedGenus;
  String? _selectedSpecies;
  bool _isFilterExpanded = false;

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
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm cây thuốc....',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: ExpansionTile(
                        title: const Text('Bộ lọc tìm kiếm'),
                        initiallyExpanded: _isFilterExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _isFilterExpanded = expanded;
                          });
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildDropdown(
                                  'Ngành',
                                  _selectedBranch,
                                  ['Magnoliophyta', 'Pinophyta', 'Polypodiophyta', 'Ginkgophyta', 'Cycadophyta', 'Gnetophyta'],
                                  (value) {
                                    setState(() {
                                      _selectedBranch = value;
                                      _selectedClass = null;
                                      _selectedOrder = null;
                                      _selectedFamily = null;
                                      _selectedGenus = null;
                                      _selectedSpecies = null;
                                    });
                                  },
                                ),
                                if (_selectedBranch != null)
                                  _buildDropdown(
                                    'Lớp',
                                    _selectedClass,
                                    ['Magnoliopsida', 'Liliopsida'],
                                    (value) {
                                      setState(() {
                                        _selectedClass = value;
                                        _selectedOrder = null;
                                        _selectedFamily = null;
                                        _selectedGenus = null;
                                        _selectedSpecies = null;
                                      });
                                    },
                                  ),
                                if (_selectedClass != null)
                                  _buildDropdown(
                                    'Bộ',
                                    _selectedOrder,
                                    ['Apiales', 'Asterales', 'Fabales'],
                                    (value) {
                                      setState(() {
                                        _selectedOrder = value;
                                        _selectedFamily = null;
                                        _selectedGenus = null;
                                        _selectedSpecies = null;
                                      });
                                    },
                                  ),
                                if (_selectedOrder != null)
                                  _buildDropdown(
                                    'Họ',
                                    _selectedFamily,
                                    ['Araliaceae', 'Apiaceae', 'Asteraceae'],
                                    (value) {
                                      setState(() {
                                        _selectedFamily = value;
                                        _selectedGenus = null;
                                        _selectedSpecies = null;
                                      });
                                    },
                                  ),
                                if (_selectedFamily != null)
                                  _buildDropdown(
                                    'Chi',
                                    _selectedGenus,
                                    ['Polyscias', 'Panax', 'Schefflera'],
                                    (value) {
                                      setState(() {
                                        _selectedGenus = value;
                                        _selectedSpecies = null;
                                      });
                                    },
                                  ),
                                if (_selectedGenus != null)
                                  _buildDropdown(
                                    'Loài',
                                    _selectedSpecies,
                                    ['Polyscias fruticosa', 'Panax vietnamensis', 'Schefflera heptaphylla'],
                                    (value) {
                                      setState(() {
                                        _selectedSpecies = value;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Danh sách cây thuốc',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 10, // Show more items by default
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                'assets/images/plant_placeholder.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: const Text('Đinh lăng'),
                            subtitle: const Text('Polyscias fruticosa'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PlantDetailScreen(plantId: 1),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 1,
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
} 