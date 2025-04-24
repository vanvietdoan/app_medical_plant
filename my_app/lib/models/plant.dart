class Plant {
  final int plantId;
  final String name;
  final String? englishName;
  final String? description;
  final String? benefits;
  final String? instructions;
  final int? speciesId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Plant({
    required this.plantId,
    required this.name,
    this.englishName,
    this.description,
    this.benefits,
    this.instructions,
    this.speciesId,
    this.createdAt,
    this.updatedAt,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantId: json['plant_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      englishName: json['english_name']?.toString(),
      description: json['description']?.toString(),
      benefits: json['benefits']?.toString(),
      instructions: json['instructions']?.toString(),
      speciesId: json['species_id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'plant_id': plantId,
        'name': name,
        if (englishName != null) 'english_name': englishName,
        if (description != null) 'description': description,
        if (benefits != null) 'benefits': benefits,
        if (instructions != null) 'instructions': instructions,
        if (speciesId != null) 'species_id': speciesId,
        if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
      };
}
