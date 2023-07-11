import 'dart:async';

import 'package:csi_door_logs/models/user_model.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? _authUser;
  UserModel? _user;
  StreamSubscription? _userSub;
  StreamSubscription? _isRootSub;

  User? get user => _authUser;
  UserModel? get userData => _user;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _authUser = user;
      _initializeSubscriptions();
      notifyListeners();
    });
  }

  void _initializeSubscriptions() {
    if (_authUser == null) return;

    _userSub = _firestore
        .collection('users')
        .doc(_authUser!.uid)
        .snapshots()
        .listen((userData) {
      if (_authUser == null) return;

      _user = UserModel.fromDocSnapshot(userData);
      notifyListeners();
    });

    _isRootSub = _firestore
        .collection('user_roles')
        .doc(_authUser!.uid)
        .snapshots()
        .listen((userRoles) {
      if (_user == null || _authUser == null) return;

      _user!.setIsRoot = userRoles.data()?['isRoot'];
      notifyListeners();
    });
  }

  Future<void> fetchUserData() async {
    if (_authUser == null) return;

    try {
      final userData =
          await _firestore.collection('users').doc(_authUser!.uid).get();
      _user = UserModel.fromDocSnapshot(userData);

      final userRolesSnapshot =
          await _firestore.collection('user_roles').doc(_authUser!.uid).get();
      _user!.setIsRoot = userRolesSnapshot.data()?['isRoot'];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
      });
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _authUser = null;
      _userSub?.cancel();
      _isRootSub?.cancel();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _isRootSub?.cancel();

    super.dispose();
  }
}
