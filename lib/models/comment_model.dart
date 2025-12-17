import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String projectId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final bool isApproved;
  final String? parentId; // For reply threads

  CommentModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.isApproved = false,
    this.parentId,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isApproved: data['isApproved'] ?? false,
      parentId: data['parentId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'isApproved': isApproved,
      'parentId': parentId,
    };
  }

  CommentModel copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? userName,
    String? content,
    DateTime? createdAt,
    bool? isApproved,
    String? parentId,
  }) {
    return CommentModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
      parentId: parentId ?? this.parentId,
    );
  }
}
