import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/plant.dart' as plant_model;
import '../../models/advice.dart';
import '../../models/user.dart';
import '../../services/plant_service.dart';
import '../../services/advice_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../screens/disease/disease_detail_screen.dart';
import '../../screens/profile/visit_profile.dart';
import '../../screens/advice/advice_create_screen.dart';
import '../../screens/advice/advice_edit_screen.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlantDetailScreen extends StatefulWidget {
  final int plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final PlantService _plantService = PlantService();
  final AdviceService _adviceService = AdviceService();

  plant_model.Plant? _plant;
  List<Advice> _advices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final plant = await _plantService.getPlantById(widget.plantId);
      final advices = await _adviceService.getAdvicesByPlant(widget.plantId);

      if (mounted) {
        setState(() {
          _plant = plant;
          _advices = advices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Lỗi tải dữ liệu: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_plant?.name ?? 'Chi tiết cây'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plant == null
              ? const Center(child: Text('Không tìm thấy thông tin cây'))
              : Column(
                  children: [
                    if (_plant?.images != null && _plant!.images!.isNotEmpty)
                      PlantImage(plant: _plant!),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: PlantDetails(plant: _plant!),
                          ),
                          Expanded(
                            flex: 1,
                            child: AdviceList(
                                advices: _advices,
                                plantId: widget.plantId,
                                onRefresh: _loadData),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: const CustomBottomNav(
        currentIndex: 1,
      ),
    );
  }
}

class PlantImage extends StatefulWidget {
  final plant_model.Plant plant;

  const PlantImage({super.key, required this.plant});

  @override
  State<PlantImage> createState() => _PlantImageState();
}

class _PlantImageState extends State<PlantImage> {
  int _selectedIndex = 0;

  String _ensureHttps(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plant.images == null || widget.plant.images!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Main large image
        Container(
          height: 200,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: _ensureHttps(widget.plant.images![_selectedIndex].url),
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) {
              debugPrint('Error loading image: $error');
              return Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.grey,
                  size: 48,
                ),
              );
            },
          ),
        ),
        // Thumbnails row
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.plant.images!.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: _ensureHttps(widget.plant.images![index].url),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      debugPrint('Error loading thumbnail: $error');
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PlantDetails extends StatelessWidget {
  final plant_model.Plant plant;

  const PlantDetails({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plant.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (plant.englishName != null) ...[
            const SizedBox(height: 8),
            Text(
              plant.englishName!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (plant.description != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Mô tả:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(plant.description!),
          ],
          if (plant.benefits != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Công dụng:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(plant.benefits!),
          ],
          if (plant.instructions != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Cách sử dụng:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(plant.instructions!),
          ],
        ],
      ),
    );
  }
}

class AdviceList extends StatelessWidget {
  final List<Advice> advices;
  final int plantId;
  final VoidCallback onRefresh;

  const AdviceList({
    super.key,
    required this.advices,
    required this.plantId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lời khuyên từ chuyên gia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (currentUser != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdviceCreateScreen(
                            expertId: currentUser.id,
                            plantId: plantId,
                            fromPlantDetail: true,
                          ),
                        ),
                      );
                      if (result == true) {
                        onRefresh();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo lời khuyên'),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: advices.length,
            itemBuilder: (context, index) {
              return AdviceCard(
                advice: advices[index],
                currentUserId: currentUser?.id,
                onRefresh: onRefresh,
              );
            },
          ),
        ),
      ],
    );
  }
}

class AdviceCard extends StatelessWidget {
  final Advice advice;
  final int? currentUserId;
  final VoidCallback onRefresh;

  const AdviceCard({
    super.key,
    required this.advice,
    this.currentUserId,
    required this.onRefresh,
  });

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('HH:mm - dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUserAdvice =
        currentUserId != null && advice.user?.userId == currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (advice.user != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green,
                    backgroundImage: advice.user?.avatar?.isNotEmpty == true
                        ? NetworkImage(advice.user!.avatar!)
                        : null,
                    child: advice.user?.avatar?.isEmpty != false
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfilePage(
                                  userId: advice.user!.userId,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            advice.user!.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          advice.user!.title,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isCurrentUserAdvice)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdviceEditScreen(
                              advice: advice,
                              expertId: currentUserId!,
                              fromPlantDetail: true,
                            ),
                          ),
                        );
                        if (result == true) {
                          onRefresh();
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text(
              advice.title ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(
              advice.content ?? '',
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
            if (advice.disease != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiseaseDetailScreen(
                        diseaseId: advice.disease!.diseaseId,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.healing,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        advice.disease!.name,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _formatDate(advice.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
