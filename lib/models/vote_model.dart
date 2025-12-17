import 'package:cloud_firestore/cloud_firestore.dart';

class VoteModel {
  final String id;
  final String projectId;
  final String userId;
  final String userNik;
  final DateTime votedAt;

  VoteModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userNik,
    required this.votedAt,
  });

  factory VoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VoteModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      userId: data['userId'] ?? '',
      userNik: data['userNik'] ?? '',
      votedAt: (data['votedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'userId': userId,
      'userNik': userNik,
      'votedAt': Timestamp.fromDate(votedAt),
    };
  }
}
