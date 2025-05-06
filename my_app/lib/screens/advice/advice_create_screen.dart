import 'package:flutter/material.dart';
import '../../models/advice.dart' as advice_model;
import '../../models/plant.dart' as plant_model;
import '../../models/disease.dart' as disease_model;
import '../../services/advice_service.dart';
import '../../services/plant_service.dart';
import '../../services/disease_service.dart';

class AdviceCreateScreen extends StatefulWidget {
  final int expertId;

  const AdviceCreateScreen({
    super.key,
    required this.expertId,
  });

  @override
  State<AdviceCreateScreen> createState() => _AdviceCreateScreenState();
}

class _AdviceCreateScreenState extends State<AdviceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _adviceService = AdviceService();
  final _plantService = PlantService();
  final _diseaseService = DiseaseService();

  List<plant_model.Plant> _plants = [];
  List<disease_model.Disease> _diseases = [];
  plant_model.Plant? _selectedPlant;
  disease_model.Disease? _selectedDisease;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load plants and diseases
      final plants = await _plantService.getPlants();
      final diseases = await _diseaseService.getDiseases();

      setState(() {
        _plants = plants;
        _diseases = diseases;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAdvice() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _adviceService.createAdvice(
        title: _titleController.text,
        content: _contentController.text,
        plantId: _selectedPlant?.plantId ?? 0,
        diseaseId: _selectedDisease?.disease_id ?? 0,
        userId: widget.expertId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo lời khuyên thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo lời khuyên: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo lời khuyên'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tiêu đề';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Nội dung',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập nội dung';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<plant_model.Plant>(
                      value: _selectedPlant,
                      decoration: const InputDecoration(
                        labelText: 'Cây thuốc',
                        border: OutlineInputBorder(),
                      ),
                      items: _plants.map((plant) {
                        return DropdownMenuItem<plant_model.Plant>(
                          value: plant,
                          child: Text(plant.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPlant = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Vui lòng chọn cây thuốc';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<disease_model.Disease>(
                      value: _selectedDisease,
                      decoration: const InputDecoration(
                        labelText: 'Bệnh',
                        border: OutlineInputBorder(),
                      ),
                      items: _diseases.map((disease) {
                        return DropdownMenuItem<disease_model.Disease>(
                          value: disease,
                          child: Text(disease.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedDisease = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Vui lòng chọn bệnh';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveAdvice,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Tạo lời khuyên',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
