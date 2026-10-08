class PreOrderProgressModel {
  final String id;
  final String preOrderId;
  final String stage; // e.g., 'Land Preparation', 'Seeds Planted', 'Fertilizer Applied', 'Flowering', 'Harvesting Soon'
  final String description;
  final List<String> images;
  final DateTime date;

  const PreOrderProgressModel({
    required this.id,
    required this.preOrderId,
    required this.stage,
    required this.description,
    this.images = const [],
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pre_order_id': preOrderId,
      'stage': stage,
      'description': description,
      'images': images,
      'date': date.toIso8601String(),
    };
  }

  factory PreOrderProgressModel.fromJson(Map<String, dynamic> map) {
    return PreOrderProgressModel(
      id: map['id'] as String? ?? 'prog_${DateTime.now().millisecondsSinceEpoch}',
      preOrderId: map['pre_order_id'] as String? ?? '',
      stage: map['stage'] as String? ?? 'Update',
      description: map['description'] as String? ?? '',
      images: (map['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      date: map['date'] != null
          ? DateTime.tryParse(map['date'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static List<PreOrderProgressModel> get sampleProgress => [
    PreOrderProgressModel(
      id: 'prog_1',
      preOrderId: 'po_sample_1',
      stage: 'Land Preparation',
      description: 'Cleared the field and prepared beds for planting carrots. The soil moisture is perfect.',
      images: [
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=400&auto=format&fit=crop&q=60'
      ],
      date: DateTime.now().subtract(const Duration(days: 8)),
    ),
    PreOrderProgressModel(
      id: 'prog_2',
      preOrderId: 'po_sample_1',
      stage: 'Seeds Planted',
      description: 'Planted premium carrot seeds today. Applied organic base fertilizer. Weather is good.',
      images: [
        'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&auto=format&fit=crop&q=60'
      ],
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}
