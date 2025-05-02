class Genus {
  final int genusId;
  final String name;
  final int familyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Genus({
    required this.genusId,
    required this.name,
    required this.familyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Genus.fromJson(Map<String, dynamic> json) {
    return Genus(
      genusId: json['genus_id'] ?? 0,
      name: json['name'] ?? '',
      familyId: json['family_id'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'genus_id': genusId,
        'name': name,
        'family_id': familyId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class GenusResponse {
  final String createdAt;
  final String updatedAt;
  final int genusId;
  final String name;
  final int familyId;

  GenusResponse({
    required this.createdAt,
    required this.updatedAt,
    required this.genusId,
    required this.name,
    required this.familyId,
  });

  factory GenusResponse.fromJson(Map<String, dynamic> json) {
    return GenusResponse(
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      genusId: json['genus_id'],
      name: json['name'],
      familyId: json['family_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'updated_at': updatedAt,
      'genus_id': genusId,
      'name': name,
      'family_id': familyId,
    };
  }
}
