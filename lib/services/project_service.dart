import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../models/vote_model.dart';

class ProjectService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProjectModel> _projects = [];
  bool _isLoading = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;

  Stream<List<ProjectModel>> getActiveProjects() {
    return _firestore
        .collection('projects')
        .where('status', isEqualTo: ProjectStatus.voting.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<ProjectModel>> getAllProjects() {
    return _firestore
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  Future<ProjectModel?> getProjectById(String projectId) async {
    try {
      final doc = await _firestore.collection('projects').doc(projectId).get();
      if (doc.exists) {
        return ProjectModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting project: $e');
      return null;
    }
  }

  Future<String?> createProject(ProjectModel project) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('projects').add(project.toFirestore());

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateProject(ProjectModel project) async {
    try {
      await _firestore
          .collection('projects')
          .doc(project.id)
          .update(project.toFirestore());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> vote({
    required String projectId,
    required String userId,
    required String userNik,
  }) async {
    try {
      // Check if user already voted for any project in this voting period
      final existingVote = await _firestore
          .collection('votes')
          .where('userNik', isEqualTo: userNik)
          .get();

      if (existingVote.docs.isNotEmpty) {
        return 'Anda sudah memberikan suara. Satu NIK hanya bisa vote sekali.';
      }

      // Create vote
      final vote = VoteModel(
        id: '',
        projectId: projectId,
        userId: userId,
        userNik: userNik,
        votedAt: DateTime.now(),
      );

      await _firestore.collection('votes').add(vote.toFirestore());

      // Update vote count
      await _firestore.collection('projects').doc(projectId).update({
        'voteCount': FieldValue.increment(1),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> hasUserVoted(String userNik) async {
    final votes = await _firestore
        .collection('votes')
        .where('userNik', isEqualTo: userNik)
        .get();
    return votes.docs.isNotEmpty;
  }

  Future<String?> getUserVotedProjectId(String userNik) async {
    final votes = await _firestore
        .collection('votes')
        .where('userNik', isEqualTo: userNik)
        .get();
    if (votes.docs.isNotEmpty) {
      return votes.docs.first.data()['projectId'] as String?;
    }
    return null;
  }

  Stream<int> getVoteCount(String projectId) {
    return _firestore
        .collection('votes')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<int> getTotalVotes() async {
    final votes = await _firestore.collection('votes').get();
    return votes.docs.length;
  }

  Future<Map<String, int>> getVoteDistribution() async {
    final projects = await _firestore.collection('projects').get();
    final distribution = <String, int>{};

    for (final doc in projects.docs) {
      final project = ProjectModel.fromFirestore(doc);
      distribution[project.title] = project.voteCount;
    }

    return distribution;
  }

  Future<String?> endVoting(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'status': ProjectStatus.completed.name,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> resetVotesForNewPeriod() async {
    try {
      // Delete all votes
      final votes = await _firestore.collection('votes').get();
      for (final doc in votes.docs) {
        await doc.reference.delete();
      }

      // Reset vote counts
      final projects = await _firestore.collection('projects').get();
      for (final doc in projects.docs) {
        await doc.reference.update({'voteCount': 0});
      }
    } catch (e) {
      debugPrint('Error resetting votes: $e');
    }
  }
}
