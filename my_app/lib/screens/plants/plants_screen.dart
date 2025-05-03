import 'package:flutter/material.dart';
import 'package:my_app/screens/plants/plant_detail_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/plant_service.dart';
import '../../models/plant.dart';
import 'dart:async';
import '../../services/division_service.dart';
import '../../models/division.dart';
import '../../services/class_service.dart';
import '../../models/class.dart';
import 'package:flutter/foundation.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';
import '../../services/family_service.dart';
import '../../models/family.dart';
import '../../services/genus_service.dart';
import '../../models/genus.dart';
import '../../services/species_service.dart';
import '../../models/species.dart';

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
  List<Plant> _allPlants = [];
  bool _isLoading = false;
  Timer? _searchDebounce;

  // Filter states
  final Map<String, String?> _selectedFilters = {
    'division': null,
    'class': null,
    'order': null,
    'family': null,
    'genus': null,
    'species': null,
  };
  bool _isFilterExpanded = false;
  bool _isLoadingFilters = false;

  // Filter data
  final Map<String, List<dynamic>> _filterData = {
    'divisions': [],
    'classes': [],
    'orders': [],
    'families': [],
    'genera': [],
    'species': [],
  };

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _loadFilterData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _filterPlants);
  }

  void _clearSearch() {
    _searchController.clear();
    _filterPlants();
  }

  void _filterPlants() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _plants = List.from(_allPlants);
      } else {
        final searchText = _searchController.text.toLowerCase();
        _plants = _allPlants.where((plant) {
          final name = plant.name.toLowerCase();
          final englishName = plant.englishName?.toLowerCase() ?? '';
          return name.contains(searchText) || englishName.contains(searchText);
        }).toList();
      }
    });
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);

    try {
      final query = _buildFilterQuery();
      final plants = query.isEmpty
          ? await _plantService.getPlants()
          : await _plantService.getPlantSearch(query);

      setState(() {
        _allPlants = plants;
        _plants = List.from(_allPlants);
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

  String _buildFilterQuery() {
    final filters = _selectedFilters.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}Id=${entry.value}')
        .join('&');
    return filters;
  }

  Future<void> _onRefresh() async {
    await _loadPlants();
  }

  Future<void> _loadFilterData() async {
    if (_isLoadingFilters) return;

    setState(() => _isLoadingFilters = true);

    try {
      final divisions = await DivisionService().getDivisions();
      final classes = await ClassService().getClasses();
      final orders = await OrderService().getOrders();
      final families = await FamilyService().getFamilies();

      if (kDebugMode) {
        debugPrint('Loaded divisions: ${divisions.length} items');
        debugPrint('Loaded classes: ${classes.length} items');
        debugPrint('Loaded orders: ${orders.length} items');
        debugPrint('Loaded families: ${families.length} items');
      }

      setState(() {
        _filterData['divisions'] = divisions;
        _filterData['classes'] = classes;
        _filterData['orders'] = orders;
        _filterData['families'] = families;
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

  Future<void> _loadGeneraByFamily(int familyId) async {
    try {
      final genera = await GenusService().getGenuses();
      setState(() {
        _filterData['genera'] =
            genera.where((genus) => genus.familyId == familyId).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách chi: $e')),
        );
      }
    }
  }

  Future<void> _loadSpeciesByGenus(int genusId) async {
    try {
      final species = await SpeciesService().getSpecies();
      setState(() {
        _filterData['species'] =
            species.where((s) => s.genusId == genusId).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách loài: $e')),
        );
      }
    }
  }

  void _handleFilterChange(String filterType, String? value) {
    setState(() {
      _selectedFilters[filterType] = value;

      // Reset dependent filters
      switch (filterType) {
        case 'division':
          _selectedFilters['class'] = null;
          _selectedFilters['order'] = null;
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'class':
          _selectedFilters['order'] = null;
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'order':
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'family':
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          _filterData['genera'] = [];
          if (value != null) {
            _loadGeneraByFamily(int.parse(value));
          }
          break;
        case 'genus':
          _selectedFilters['species'] = null;
          _filterData['species'] = [];
          if (value != null) {
            _loadSpeciesByGenus(int.parse(value));
          }
          break;
      }
    });
    _loadPlants();
  }

  void _clearFilter(String filterType) {
    setState(() {
      _selectedFilters[filterType] = null;
      // Clear dependent filters
      switch (filterType) {
        case 'division':
          _selectedFilters['class'] = null;
          _selectedFilters['order'] = null;
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'class':
          _selectedFilters['order'] = null;
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'order':
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'family':
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          _filterData['genera'] = [];
          break;
        case 'genus':
          _selectedFilters['species'] = null;
          _filterData['species'] = [];
          break;
      }
    });
    _loadPlants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchAndFilterCard(
              searchController: _searchController,
              isFilterExpanded: _isFilterExpanded,
              onFilterToggle: () =>
                  setState(() => _isFilterExpanded = !_isFilterExpanded),
              onClearSearch: _clearSearch,
              filterContent: _isFilterExpanded
                  ? FilterContent(
                      filterData: _filterData,
                      selectedFilters: _selectedFilters,
                      isLoadingFilters: _isLoadingFilters,
                      onFilterChange: _handleFilterChange,
                      onClearFilter: _clearFilter,
                    )
                  : null,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: PlantsGrid(
                  plants: _plants,
                  isLoading: _isLoading,
                  searchText: _searchController.text,
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
}

class SearchAndFilterCard extends StatelessWidget {
  final TextEditingController searchController;
  final bool isFilterExpanded;
  final VoidCallback onFilterToggle;
  final VoidCallback onClearSearch;
  final Widget? filterContent;

  const SearchAndFilterCard({
    super.key,
    required this.searchController,
    required this.isFilterExpanded,
    required this.onFilterToggle,
    required this.onClearSearch,
    this.filterContent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm cây thuốc....',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: onClearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFilterExpanded
                        ? Icons.filter_list_off
                        : Icons.filter_list,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: onFilterToggle,
                  tooltip: isFilterExpanded ? 'Ẩn bộ lọc' : 'Hiện bộ lọc',
                ),
              ],
            ),
          ),
          if (isFilterExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: filterContent,
            ),
          ],
        ],
      ),
    );
  }
}

class FilterContent extends StatelessWidget {
  final Map<String, List<dynamic>> filterData;
  final Map<String, String?> selectedFilters;
  final bool isLoadingFilters;
  final Function(String, String?) onFilterChange;
  final Function(String) onClearFilter;

  const FilterContent({
    super.key,
    required this.filterData,
    required this.selectedFilters,
    required this.isLoadingFilters,
    required this.onFilterChange,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFilterDropdown(
                'division',
                'Ngành',
                filterData['divisions'] as List<Division>,
                selectedFilters['division'],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFilterDropdown(
                'class',
                'Lớp',
                filterData['classes'] as List<Class>,
                selectedFilters['class'],
                parentValue: selectedFilters['division'],
                parentField: 'divisionId',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFilterDropdown(
                'order',
                'Bộ',
                filterData['orders'] as List<Order>,
                selectedFilters['order'],
                parentValue: selectedFilters['class'],
                parentField: 'classId',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFilterDropdown(
                'family',
                'Họ',
                filterData['families'] as List<Family>,
                selectedFilters['family'],
                parentValue: selectedFilters['order'],
                parentField: 'orderId',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFilterDropdown(
                'genus',
                'Chi',
                filterData['genera'] as List<Genus>,
                selectedFilters['genus'],
                parentValue: selectedFilters['family'],
                parentField: 'familyId',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFilterDropdown(
                'species',
                'Loài',
                filterData['species'] as List<Species>,
                selectedFilters['species'],
                parentValue: selectedFilters['genus'],
                parentField: 'genusId',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    String filterType,
    String label,
    List<dynamic> items,
    String? selectedValue, {
    String? parentValue,
    String? parentField,
  }) {
    if (items.isEmpty || (parentValue != null && parentValue.isEmpty)) {
      return const SizedBox();
    }

    final filteredItems = parentValue != null && parentField != null
        ? items
            .where(
                (item) => item.toJson()[parentField].toString() == parentValue)
            .toList()
        : items;

    if (filteredItems.isEmpty) {
      return const SizedBox();
    }

    return FilterDropdown(
      label: label,
      value: selectedValue,
      items: filteredItems
          .map((item) => DropdownMenuItem<String>(
                value: item.toJson()['${filterType}Id'].toString(),
                child: Text(item.toJson()['name']),
              ))
          .toList(),
      onChanged: (value) => onFilterChange(filterType, value),
      onClear: () => onClearFilter(filterType),
      isLoading: isLoadingFilters,
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final Function(String?) onChanged;
  final VoidCallback onClear;
  final bool isLoading;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.onClear,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                if (value != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onClear,
                    tooltip: 'Xóa lọc $label',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            hint: isLoading
                ? const Text('Đang tải...', style: TextStyle(fontSize: 14))
                : const Text('Chọn', style: TextStyle(fontSize: 14)),
            style: const TextStyle(fontSize: 14),
            icon: const Icon(Icons.arrow_drop_down, size: 20),
          ),
        ],
      ),
    );
  }
}

class PlantsGrid extends StatelessWidget {
  final List<Plant> plants;
  final bool isLoading;
  final String searchText;

  const PlantsGrid({
    super.key,
    required this.plants,
    required this.isLoading,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              if (searchText.isNotEmpty)
                Text(
                  'Kết quả tìm kiếm: "$searchText"',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          plants.isEmpty && !isLoading
              ? const EmptyState()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    return PlantCard(plant: plants[index]);
                  },
                ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
            const Text(
              'Không tìm thấy cây thuốc nào',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlantDetailScreen(plantId: plant.plantId),
            ),
          );
        },
        child: Column(
          children: [
            Expanded(
              child: plant.images != null && plant.images!.isNotEmpty
                  ? Image.network(
                      plant.images![0].url,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/plant_placeholder.png',
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/plant_placeholder.png',
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (plant.englishName != null &&
                      plant.englishName!.isNotEmpty)
                    Text(
                      plant.englishName!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
