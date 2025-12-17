import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/comment_model.dart';

class CommentService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CommentModel>> getComments(String projectId, {bool onlyApproved = true}) {
    Query query = _firestore
        .collection('comments')
        .where('projectId', isEqualTo: projectId)
        .where('parentId', isNull: true);

    if (onlyApproved) {
      query = query.where('isApproved', isEqualTo: true);
    }

    return query.orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList());
  }

  Stream<List<CommentModel>> getReplies(String commentId) {
    return _firestore
        .collection('comments')
        .where('parentId', isEqualTo: commentId)
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList());
  }

  Stream<List<CommentModel>> getPendingComments() {
    return _firestore
        .collection('comments')
        .where('isApproved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList());
  }

  Future<String?> addComment({
    required String projectId,
    required String userId,
    required String userName,
    required String content,
    String? parentId,
  }) async {
    try {
      final comment = CommentModel(
        id: '',
        projectId: projectId,
        userId: userId,
        userName: userName,
        content: content,
        createdAt: DateTime.now(),
        isApproved: true, // Auto-approved
        parentId: parentId,
      );

      await _firestore.collection('comments').add(comment.toFirestore());

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> approveComment(String commentId) async {
    try {
      await _firestore.collection('comments').doc(commentId).update({
        'isApproved': true,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> rejectComment(String commentId) async {
    try {
      await _firestore.collection('comments').doc(commentId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteComment(String commentId) async {
    try {
      // Delete replies first
      final replies = await _firestore
          .collection('comments')
          .where('parentId', isEqualTo: commentId)
          .get();

      for (final doc in replies.docs) {
        await doc.reference.delete();
      }

      // Delete the comment
      await _firestore.collection('comments').doc(commentId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<int> getCommentCount(String projectId) async {
    final snapshot = await _firestore
        .collection('comments')
        .where('projectId', isEqualTo: projectId)
        .where('isApproved', isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }
}
