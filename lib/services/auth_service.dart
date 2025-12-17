import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isVerified => _currentUser?.isVerified ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      await _loadUserData(user.uid);
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String nik,
    String? villageName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // First create the Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Now check if NIK already exists (user is authenticated now)
        final nikQuery = await _firestore
            .collection('users')
            .where('nik', isEqualTo: nik)
            .get();

        if (nikQuery.docs.isNotEmpty) {
          // NIK exists, delete the auth account we just created
          await credential.user!.delete();
          return 'NIK sudah terdaftar. Satu NIK hanya untuk satu akun.';
        }

        final user = UserModel(
          id: credential.user!.uid,
          name: name,
          email: email,
          nik: nik,
          villageName: villageName,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toFirestore());

        _currentUser = user;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<String?> uploadKtpImage(File imageFile) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _auth.currentUser?.uid;
      if (userId == null) return 'User tidak ditemukan';

      final ref = _storage.ref().child('ktp_images').child('$userId.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({
        'ktpImageUrl': downloadUrl,
      });

      // Reload user data
      await _loadUserData(userId);

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> verifyUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isVerified': true,
      });

      if (_currentUser?.id == userId) {
        await _loadUserData(userId);
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<UserModel>> getUnverifiedUsers() {
    return _firestore
        .collection('users')
        .where('isVerified', isEqualTo: false)
        .where('ktpImageUrl', isNull: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Future<void> refreshUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _loadUserData(userId);
      notifyListeners();
    }
  }
}
