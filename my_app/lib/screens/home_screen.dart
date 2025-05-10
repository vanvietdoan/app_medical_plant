import 'package:flutter/material.dart';
import 'package:my_app/screens/disease/disease_screen.dart';
import 'package:my_app/screens/plants/plants_screen.dart';
import 'package:my_app/screens/plants/plant_detail_screen.dart';
import 'package:my_app/screens/profile/expert_profile.dart';
import 'package:my_app/models/plant.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/plant_service.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final PlantService _plantService = PlantService();
  List<Plant> _recentPlants = [];
  List<Plant> _mostBeneficialPlants = [];
  List<Plant> _featuredPlants = [];
  bool _isLoading = true;
  int _currentSlide = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  List<ImageProvider> _slideImages = [];

  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/images/slide/1.webp',
      'title': 'Khám Phá Thế Giới Cây Thuốc Việt Nam',
      'description':
          'Tìm hiểu về các loại cây thuốc quý hiếm và công dụng của chúng'
    },
    {
      'image': 'assets/images/slide/2.webp',
      'title': 'Cây Thuốc Quý Hiếm',
      'description':
          'Những loại cây thuốc có giá trị dược liệu cao và đang có nguy cơ tuyệt chủng'
    },
    {
      'image': 'assets/images/slide/3.webp',
      'title': 'Y Học Cổ Truyền',
      'description':
          'Khám phá tri thức y học cổ truyền Việt Nam qua các bài thuốc dân gian'
    },
    {
      'image': 'assets/images/slide/4.jpg',
      'title': 'Nghiên Cứu Khoa Học',
      'description':
          'Những phát hiện mới về công dụng của cây thuốc trong y học hiện đại'
    },
    {
      'image': 'assets/images/slide/5.jpg',
      'title': 'Bảo Tồn Đa Dạng Sinh Học',
      'description':
          'Góp phần bảo vệ và phát triển nguồn gen cây thuốc quý hiếm'
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        _nextSlide();
      }
    });
    _preloadImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (_currentSlide < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevSlide() {
    if (_currentSlide > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        _slides.length - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);
    try {
      // Load multi-use plants
      final multiUsePlants = await _plantService.getMultiUsePlants();
      setState(() {
        _mostBeneficialPlants = multiUsePlants.take(6).toList();
      });

      // Load new plants
      final newPlants = await _plantService.getNewPlants();
      setState(() {
        _recentPlants = newPlants.take(6).toList();
      });

      // Load featured plants (keep existing logic)
      final plants = await _plantService.getPlants();
      setState(() {
        _featuredPlants = List.from(plants)
          ..sort((a, b) =>
              b.description?.length.compareTo(a.description?.length ?? 0) ?? 0);
        _featuredPlants = _featuredPlants.take(6).toList();
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

  Future<void> _preloadImages() async {
    for (var slide in _slides) {
      try {
        final image = AssetImage(slide['image']!);
        await precacheImage(image, context);
        setState(() {
          _slideImages.add(image);
        });
      } catch (e) {
        print('Error loading image ${slide['image']}: $e');
        setState(() {
          _slideImages
              .add(const AssetImage('assets/images/plant_placeholder.png'));
        });
      }
    }
  }

  String _ensureHttps(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _imageSlider(),
            _buildPlantSection(
              'Top  Cây Thuốc Mới Phát Hiện',
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPlantList(_recentPlants),
            ),
            _buildPlantSection(
              'Top  Cây Thuốc Có Nhiều Công Dụng',
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPlantList(_mostBeneficialPlants),
            ),
            _buildPlantSection(
              'Top  Cây Thuốc Tiêu Biểu',
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

  Widget _imageSlider() {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    child: Image.asset(
                      _slides[index]['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint(
                            'Error loading image: ${_slides[index]['image']}: $error');
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _slides[index]['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _slides[index]['description']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            left: 10,
            top: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: _prevSlide,
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed: _nextSlide,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentSlide == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Widget _userSection(String title, Widget content) {
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
        child: SizedBox(
          width: 150,
          height: 200,
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: plant.images != null && plant.images!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: _ensureHttps(plant.images![0].url),
                        height: 120,
                        width: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint('Error loading plant image: $error');
                          return Container(
                            height: 120,
                            width: 150,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 120,
                        width: 150,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      plant.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (plant.englishName != null &&
                        plant.englishName!.isNotEmpty)
                      Text(
                        plant.englishName!,
                        style: TextStyle(
                          fontSize: 13,
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
      ),
    );
  }
}
