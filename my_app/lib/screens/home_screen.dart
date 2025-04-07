import 'package:flutter/material.dart';
import 'package:my_app/screens/disease/disease_screen.dart';
import 'package:my_app/screens/plants/plants_screen.dart';
import 'package:my_app/screens/plants/plant_detail_screen.dart';
import 'package:my_app/screens/profile/expert_profile.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/models/plant.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/base_api_service.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: const HomeTab(), 
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 0,
      ),
    );
  }

}
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final BaseApiService _apiService = BaseApiService();
  List<Plant> _recentPlants = [];
  bool _isLoadingPlants = true;

  @override
  void initState() {
    super.initState();
    _loadRecentPlants();
  }

  Future<void> _loadRecentPlants() async {
    try {
      final plants = await _apiService.getPlants();
      // Sort plants by created_at in descending order and take top 10
      plants.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _recentPlants = plants.take(10).toList();
        _isLoadingPlants = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPlants = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải danh sách cây thuốc: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
            _buildSection(
              'Top 10 Cây Thuốc Mới Phát Hiện',
              _isLoadingPlants
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentPlants.length,
                      itemBuilder: (context, index) => _buildPlantCard(
                        context,
                        _recentPlants[index],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
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
          height: title == 'Chuyên Gia Tiêu Biểu' ? 120 : 200,
          child: content,
        ),
      ],
    );
  }

  Widget _buildPlantCard(BuildContext context, Plant plant) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: SizedBox(
        width: 150,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                child: Image.asset(
                  'assets/images/plant_placeholder.png',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      plant.englishName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
