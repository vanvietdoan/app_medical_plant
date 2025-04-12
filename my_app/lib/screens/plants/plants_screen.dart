import 'package:flutter/material.dart';
import 'package:my_app/screens/plants/plant_detail_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_app_bar.dart';
import '../home_screen.dart';
import '../disease/disease_screen.dart';
import '../auth/login_screen.dart';
import '../profile/expert_profile.dart';
import '../../services/auth_service.dart';
import '../../services/plant_service.dart';
import '../../models/plant.dart';
import 'dart:async';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({Key? key}) : super(key: key);

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  final PlantService _plantService = PlantService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Plant> _plants = [];
  List<Plant> _filteredPlants = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _isSearching = false;
  Timer? _searchDebounce;

  String? _selectedBranch;
  String? _selectedClass;
  String? _selectedOrder;
  String? _selectedFamily;
  String? _selectedGenus;
  String? _selectedSpecies;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _scrollController.addListener(_onScroll);
    
    // Add listener for search text changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous debounce timer
    _searchDebounce?.cancel();
    
    // Set a new debounce timer
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _filterPlants();
    });
  }

  void _filterPlants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPlants = _plants;
      } else {
        _filteredPlants = _plants.where((plant) {
          return plant.name.toLowerCase().contains(query) ||
                 (plant.englishName?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _loadPlants({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _plants = [];
        _filteredPlants = [];
      });
    }

    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final plants = await _plantService.getPlants(
        page: _currentPage,
        limit: _pageSize,
      );

      setState(() {
        _plants.addAll(plants);
        _filterPlants(); // Apply current search filter to new plants
        _hasMore = plants.length >= _pageSize;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách cây: $e')),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_searchController.text.isNotEmpty) {
        _filterPlants();
      } else {
        _loadPlants();
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadPlants(refresh: true);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredPlants = _plants;
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm cây thuốc....',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  controller: _scrollController,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Danh sách cây thuốc',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            Text(
                              'Kết quả tìm kiếm: "${_searchController.text}"',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _plants.isEmpty && !_isLoading
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchController.text.isNotEmpty
                                          ? 'Không tìm thấy cây thuốc nào với từ khóa "${_searchController.text}"'
                                          : 'Không tìm thấy cây thuốc nào',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _plants.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _plants.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final plant = _plants[index];
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
                                    title: Text(plant.name),
                                    subtitle: Text(plant.englishName),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlantDetailScreen(plantId: plant.plantId),
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