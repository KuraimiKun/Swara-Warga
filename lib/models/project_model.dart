import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus { voting, completed, cancelled }

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final double budget;
  final String imageUrl;
  final String category;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final DateTime createdAt;
  final int voteCount;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    this.imageUrl = '',
    required this.category,
    this.status = ProjectStatus.voting,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    required this.createdAt,
    this.voteCount = 0,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      budget: (data['budget'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ProjectStatus.voting,
      ),
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      voteCount: data['voteCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'budget': budget,
      'imageUrl': imageUrl,
      'category': category,
      'status': status.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'voteCount': voteCount,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    double? budget,
    String? imageUrl,
    String? category,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? createdBy,
    DateTime? createdAt,
    int? voteCount,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}
