import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:csi_door_logs/models/models.dart';

class CSIUsers with ChangeNotifier {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  CSIUser? _user;
  Role? _role;

  late StreamSubscription<User?> _authStream;
  late StreamSubscription _userStream;
  late StreamSubscription _roleStream;

  CSIUser? get user => _user;
  Role? get role => _role;

  CSIUsers() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;

    _authStream = _auth.authStateChanges().listen(onAuthStateChanged);
  }

  void _firestoreRole(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    _role = Role.fromDocSnapshot(snapshot);
    notifyListeners();
  }

  void _firestoreUser(DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    if (!snapshot.exists) return;

    _user = CSIUser.fromDocSnapshot(snapshot);
    _roleStream = _user!.role!.snapshots().listen(_firestoreRole);
    notifyListeners();
  }

  Future<void> onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) return;

    _userStream = _firestore
        .collection("users")
        .doc(firebaseUser.uid)
        .snapshots()
        .listen(_firestoreUser);
    notifyListeners();
  }

  @override
  void dispose() {
    _authStream.cancel();
    _userStream.cancel();
    _roleStream.cancel();

    super.dispose();
  }
}
