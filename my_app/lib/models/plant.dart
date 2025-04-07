class Plant {
  final int plantId;
  final String name;
  final String englishName;
  final String description;
  final String benefits;
  final String instructions;
  final int speciesId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Plant({
    required this.plantId,
    required this.name,
    required this.englishName,
    required this.description,
    required this.benefits,
    required this.instructions,
    required this.speciesId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantId: json['plant_id'],
      name: json['name'],
      englishName: json['english_name'],
      description: json['description'],
      benefits: json['benefits'],
      instructions: json['instructions'],
      speciesId: json['species_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'plant_id': plantId,
    'name': name,
    'english_name': englishName,
    'description': description,
    'benefits': benefits,
    'instructions': instructions,
    'species_id': speciesId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
} 