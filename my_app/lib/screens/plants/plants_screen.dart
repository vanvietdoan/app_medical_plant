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
  List<Class> _Class = [];
  bool _isLoading = false;
  Timer? _searchDebounce;

  // Filter states
  String? _selectedDivision;
  String? _selectedClass;
  String? _selectedOrder;
  String? _selectedFamily;
  String? _selectedGenus;
  String? _selectedSpecies;
  bool _isFilterExpanded = false;
  bool _isLoadingFilters = false;

  // Filter data
  List<Division> _divisions = [];
  List<Class> _classes = [];
  List<Order> _orders = [];
  List<Family> _families = [];
  List<Genus> _genera = [];
  List<Species> _species = [];

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
    // Cancel previous debounce timer
    _searchDebounce?.cancel();

    // Set a new debounce timer
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _filterPlants();
    });
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
      String query = '';
      if (_selectedDivision != null) {
        query = 'divisionId=${_selectedDivision}';
        if (_selectedClass != null) {
          query += '&classId=${_selectedClass}';
        }
        if (_selectedOrder != null) {
          query += '&orderId=${_selectedOrder}';
        }
        if (_selectedFamily != null) {
          query += '&familyId=${_selectedFamily}';
        }
        if (_selectedGenus != null) {
          query += '&genusId=${_selectedGenus}';
        }
        if (_selectedSpecies != null) {
          query += '&speciesId=${_selectedSpecies}';
        }
      }

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
        _divisions = divisions.cast<Division>();
        _classes = classes.cast<Class>();
        _orders = orders.cast<Order>();
        _families = families.cast<Family>();
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
        _genera = genera.where((genus) => genus.familyId == familyId).toList();
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
        _species = species.where((s) => s.genusId == genusId).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách loài: $e')),
        );
      }
    }
  }

  void _handleDivisionChange(String? value) {
    setState(() {
      _selectedDivision = value;
      _selectedClass = null; // Reset class when division changes
      _selectedOrder = null; // Reset order when division changes
      _selectedFamily = null; // Reset family when division changes
    });
    _loadPlants();
  }

  void _handleClassChange(String? value) {
    setState(() {
      _selectedClass = value;
      _selectedOrder = null; // Reset order when class changes
      _selectedFamily = null; // Reset family when class changes
    });
    _loadPlants();
  }

  void _handleOrderChange(String? value) {
    setState(() {
      _selectedOrder = value;
      _selectedFamily = null; // Reset family when order changes
    });
    _loadPlants();
  }

  void _handleFamilyChange(String? value) {
    setState(() {
      _selectedFamily = value;
      _selectedGenus = null; // Reset genus when family changes
      _genera = []; // Clear genera list
    });
    if (value != null) {
      _loadGeneraByFamily(int.parse(value));
    }
    _loadPlants();
  }

  void _handleGenusChange(String? value) {
    setState(() {
      _selectedGenus = value;
      _selectedSpecies = null; // Reset species when genus changes
      _species = []; // Clear species list
    });
    if (value != null) {
      _loadSpeciesByGenus(int.parse(value));
    }
    _loadPlants();
  }

  void _handleSpeciesChange(String? value) {
    setState(() {
      _selectedSpecies = value;
    });
    _loadPlants();
  }

  void _clearDivision() {
    setState(() {
      _selectedDivision = null;
      _selectedClass = null;
      _selectedOrder = null;
      _selectedFamily = null;
      _selectedGenus = null;
      _selectedSpecies = null;
    });
    _loadPlants();
  }

  void _clearClass() {
    setState(() {
      _selectedClass = null;
      _selectedOrder = null;
      _selectedFamily = null;
      _selectedGenus = null;
      _selectedSpecies = null;
    });
    _loadPlants();
  }

  void _clearOrder() {
    setState(() {
      _selectedOrder = null;
      _selectedFamily = null;
      _selectedGenus = null;
      _selectedSpecies = null;
    });
    _loadPlants();
  }

  void _clearFamily() {
    setState(() {
      _selectedFamily = null;
      _selectedGenus = null;
      _selectedSpecies = null;
    });
    _loadPlants();
  }

  void _clearGenus() {
    setState(() {
      _selectedGenus = null;
      _selectedSpecies = null;
    });
    _loadPlants();
  }

  void _clearSpecies() {
    setState(() {
      _selectedSpecies = null;
    });
    _loadPlants();
  }

  Widget _buildFilterDropdown(
    String label,
    String? value,
    List<DropdownMenuItem<String>> items,
    Function(String?) onChanged,
    VoidCallback onClear,
    bool isLoading,
  ) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
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
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            _isFilterExpanded
                                ? Icons.filter_list_off
                                : Icons.filter_list,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            setState(
                                () => _isFilterExpanded = !_isFilterExpanded);
                          },
                          tooltip:
                              _isFilterExpanded ? 'Ẩn bộ lọc' : 'Hiện bộ lọc',
                        ),
                      ],
                    ),
                  ),
                  if (_isFilterExpanded) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // First row: Ngành, Lớp, Bộ
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _divisions.isNotEmpty
                                    ? _buildFilterDropdown(
                                        'Ngành',
                                        _selectedDivision,
                                        _divisions
                                            .map(
                                                (d) => DropdownMenuItem<String>(
                                                      value: d.divisionId
                                                          .toString(),
                                                      child: Text(d.name),
                                                    ))
                                            .toList(),
                                        _handleDivisionChange,
                                        _clearDivision,
                                        _isLoadingFilters,
                                      )
                                    : const SizedBox(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _selectedDivision != null &&
                                        _classes.isNotEmpty
                                    ? _buildFilterDropdown(
                                        'Lớp',
                                        _selectedClass,
                                        _classes
                                            .where((c) =>
                                                c.divisionId.toString() ==
                                                _selectedDivision)
                                            .map((c) =>
                                                DropdownMenuItem<String>(
                                                  value: c.classId.toString(),
                                                  child: Text(c.name),
                                                ))
                                            .toList(),
                                        _handleClassChange,
                                        _clearClass,
                                        _isLoadingFilters,
                                      )
                                    : const SizedBox(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _selectedClass != null &&
                                        _orders.isNotEmpty
                                    ? _buildFilterDropdown(
                                        'Bộ',
                                        _selectedOrder,
                                        _orders
                                            .where((o) =>
                                                o.classId.toString() ==
                                                _selectedClass)
                                            .map((o) =>
                                                DropdownMenuItem<String>(
                                                  value: o.orderId.toString(),
                                                  child: Text(o.name),
                                                ))
                                            .toList(),
                                        _handleOrderChange,
                                        _clearOrder,
                                        _isLoadingFilters,
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Second row: Họ, Chi, Loài
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _selectedOrder != null &&
                                        _families.isNotEmpty
                                    ? _buildFilterDropdown(
                                        'Họ',
                                        _selectedFamily,
                                        _families
                                            .where((f) =>
                                                f.orderId.toString() ==
                                                _selectedOrder)
                                            .map((f) =>
                                                DropdownMenuItem<String>(
                                                  value: f.familyId.toString(),
                                                  child: Text(f.name),
                                                ))
                                            .toList(),
                                        _handleFamilyChange,
                                        _clearFamily,
                                        _isLoadingFilters,
                                      )
                                    : const SizedBox(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _selectedFamily != null &&
                                        _genera.isNotEmpty
                                    ? _buildFilterDropdown(
                                        'Chi',
                                        _selectedGenus,
                                        _genera
                                            .map((g) =>
                                                DropdownMenuItem<String>(
                                                  value: g.genusId.toString(),
                                                  child: Text(g.name),
                                                ))
                                            .toList(),
                                        _handleGenusChange,
                                        _clearGenus,
                                        _isLoadingFilters,
                                      )
                                    : const SizedBox(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _selectedGenus != null &&
                                        _species.isNotEmpty
                                    ? _buildFilterDropdown(
                                        'Loài',
                                        _selectedSpecies,
                                        _species
                                            .map((s) =>
                                                DropdownMenuItem<String>(
                                                  value: s.speciesId.toString(),
                                                  child: Text(s.name),
                                                ))
                                            .toList(),
                                        _handleSpeciesChange,
                                        _clearSpecies,
                                        _isLoadingFilters,
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
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
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _plants.length,
                              itemBuilder: (context, index) {
                                final plant = _plants[index];
                                return Card(
                                  margin: EdgeInsets.zero,
                                  child: InkWell(
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
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: plant.images != null &&
                                                  plant.images!.isNotEmpty
                                              ? Image.network(
                                                  plant.images![0].url,
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
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
                                                    fontSize: 12),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
}
