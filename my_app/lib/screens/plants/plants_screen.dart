import 'package:flutter/material.dart';
import 'package:my_app/screens/plants/plant_detail_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/plant_service.dart';
import '../../models/plant.dart';
import 'dart:async';
import '../../services/division_service.dart';
import '../../models/division.dart';
import 'package:flutter/foundation.dart';

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
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 10;
  Timer? _searchDebounce;

  // Filter states
  String? _selectedDivision;
  bool _isFilterExpanded = false;
  bool _isLoadingFilters = false;

  // Filter data
  List<Division> _divisions = [];

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _loadFilterData();
    _scrollController.addListener(_onScroll);
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
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _loadPlants(refresh: true);
    });
  }

  Future<void> _loadPlants({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _plants = [];
      });
    }

    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      String query = '';
      if (_searchController.text.isNotEmpty) {
        query = 'name=${_searchController.text}';
      } else if (_selectedDivision != null) {
        query = 'divisionId=${_selectedDivision}';
      }

      final plants = query.isEmpty
          ? await _plantService.getPlants(page: _currentPage, limit: _pageSize)
          : await _plantService
              .getPlantSearch('$query&page=$_currentPage&limit=$_pageSize');

      setState(() {
        if (refresh) {
          _plants = plants;
        } else {
          _plants.addAll(plants);
        }
        _hasMore = plants.length >= _pageSize;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách cây: $e')),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadPlants();
    }
  }

  Future<void> _onRefresh() async {
    await _loadPlants(refresh: true);
  }

  void _clearSearch() {
    _searchController.clear();
    _loadPlants(refresh: true);
  }

  Future<void> _loadFilterData() async {
    if (_isLoadingFilters) return;

    setState(() => _isLoadingFilters = true);

    try {
      final divisions = await DivisionService().getDivisions();

      if (kDebugMode) {
        debugPrint('Loaded divisions: ${divisions.length} items');
        for (var division in divisions.cast<Division>()) {
          debugPrint('Division: ${division.name} (${division.divisionId})');
        }
      }

      setState(() {
        _divisions = divisions.cast<Division>();
        _isLoadingFilters = false;
      });
    } catch (e) {
      setState(() => _isLoadingFilters = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu bộ lọc: $e')),
        );
      }
    }
  }

  void _handleDivisionChange(String? value) {
    setState(() {
      _selectedDivision = value;
    });
    _loadPlants(refresh: true);
  }

  void _clearDivision() {
    setState(() {
      _selectedDivision = null;
    });
    _loadPlants(refresh: true);
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
                            setState(() => _isFilterExpanded = expanded);
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  if (_divisions.isNotEmpty)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildDropdown(
                                            'Ngành',
                                            _selectedDivision,
                                            _divisions
                                                .map((d) =>
                                                    DropdownMenuItem<String>(
                                                      value: d.divisionId
                                                          .toString(),
                                                      child: Text(d.name),
                                                    ))
                                                .toList(),
                                            _handleDivisionChange,
                                          ),
                                        ),
                                        if (_selectedDivision != null)
                                          IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: _clearDivision,
                                            tooltip: 'Hủy chọn ngành',
                                          ),
                                      ],
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
                                      child: plant.images != null &&
                                              plant.images!.isNotEmpty
                                          ? Image.network(
                                              plant.images![0].url,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/images/plant_placeholder.png',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                          : Image.asset(
                                              'assets/images/plant_placeholder.png',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    title: Text(plant.name),
                                    subtitle: Text(plant.englishName ?? ''),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PlantDetailScreen(
                                                  plantId: plant.plantId),
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

  Widget _buildDropdown(
    String label,
    String? value,
    List<DropdownMenuItem<String>> items,
    Function(String?) onChanged,
  ) {
    if (kDebugMode) {
      debugPrint('Building dropdown for $label');
      debugPrint('Current value: $value');
      debugPrint('Items count: ${items.length}');
      for (var item in items) {
        debugPrint('Item: ${item.value} - ${item.child}');
      }
    }

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
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          hint: _isLoadingFilters
              ? const Text('Đang tải...')
              : const Text('Chọn'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
