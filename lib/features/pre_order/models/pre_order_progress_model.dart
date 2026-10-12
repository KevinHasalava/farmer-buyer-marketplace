class PreOrderProgressModel {
  final String id;
  final String preOrderId;
  final String stage; // e.g., 'Land Preparation', 'Seeds Planted', 'Fertilizer Applied', 'Flowering', 'Harvesting Soon'
  final String description;
  final List<String> images;
  final DateTime date;
  
  // New fields for reporting Delays & Issues
  final String updateType; // 'Progress', 'Delay', 'Issue'
  final DateTime? newExpectedDate;
  final String? issueType;

  const PreOrderProgressModel({
    required this.id,
    required this.preOrderId,
    required this.stage,
    required this.description,
    this.images = const [],
    required this.date,
    this.updateType = 'Progress',
    this.newExpectedDate,
    this.issueType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pre_order_id': preOrderId,
      'stage': stage,
      'description': description,
      'images': images,
      'date': date.toIso8601String(),
      'update_type': updateType,
      'new_expected_date': newExpectedDate?.toIso8601String(),
      'issue_type': issueType,
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
      updateType: map['update_type'] as String? ?? 'Progress',
      newExpectedDate: map['new_expected_date'] != null
          ? DateTime.tryParse(map['new_expected_date'] as String)
          : null,
      issueType: map['issue_type'] as String?,
    );
  }

  static List<PreOrderProgressModel> get sampleProgress => const [];
}
