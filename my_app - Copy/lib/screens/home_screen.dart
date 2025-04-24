import 'package:flutter/material.dart';
import 'package:my_app/screens/disease/disease_screen.dart';
import 'package:my_app/screens/plants/plants_screen.dart';
import 'package:my_app/screens/plants/plant_detail_screen.dart';
import 'package:my_app/screens/profile/expert_profile.dart';
import 'package:my_app/models/plant.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/plant_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final PlantService _plantService = PlantService();
  List<Plant> _recentPlants = [];
  List<Plant> _mostBeneficialPlants = [];
  List<Plant> _featuredPlants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);
    try {
      final plants = await _plantService.getPlants();
      setState(() {
        // Sort by creation date for recent plants
        _recentPlants = List.from(plants)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _recentPlants = _recentPlants.take(10).toList();

        // Sort by benefits length for most beneficial plants
        _mostBeneficialPlants = List.from(plants)
          ..sort((a, b) => b.benefits.length.compareTo(a.benefits.length));
        _mostBeneficialPlants = _mostBeneficialPlants.take(10).toList();

        // Sort by description length for featured plants
        _featuredPlants = List.from(plants)
          ..sort((a, b) => b.description.length.compareTo(a.description.length));
        _featuredPlants = _featuredPlants.take(10).toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Không thể tải cây thuốc: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _searchBar(),
            _buildPlantSection(
              'Top 10 Cây Thuốc Mới Phát Hiện',
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPlantList(_recentPlants),
            ),
            _buildPlantSection(
              'Top 10 Cây Thuốc Có Nhiều Công Dụng',
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPlantList(_mostBeneficialPlants),
            ),
            _buildPlantSection(
              'Top 10 Cây Thuốc Tiêu Biểu',
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPlantList(_featuredPlants),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm cây thuốc...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: content,
        ),
      ],
    );
  }

  Widget _buildPlantList(List<Plant> plants) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: plants.length,
        itemBuilder: (context, index) {
          return _buildPlantCard(plants[index]);
        },
      ),
    );
  }

  Widget _buildPlantCard(Plant plant) {
    return Card(
      margin: const EdgeInsets.all(8),
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
            Image.asset(
              'assets/images/sam.png',
              height: 120,
              width: 150,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    plant.englishName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
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
