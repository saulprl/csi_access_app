import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:csi_door_logs/models/role_model.dart';

class RoleProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RoleModel? _userRole;
  List<RoleModel> _roles = [];
  StreamSubscription? _roleSubscription;
  StreamSubscription? _rolesSubscription;

  RoleModel? get userRole => _userRole;
  List<RoleModel> get roles => _roles;

  RoleProvider(String? userId, String? roomId) {
    if (userId != null && roomId != null) {
      _initializeSubscriptions(userId, roomId);
    }
  }

  Future<void> _initializeSubscriptions(String userId, String roomId) async {
    final roleRef = (await _firestore
        .collection("user_roles")
        .doc(userId)
        .collection("room_roles")
        .doc(roomId)
        .get())["roleId"] as DocumentReference<Map<String, dynamic>>;

    _roleSubscription = roleRef.snapshots().listen((role) {
      _userRole = RoleModel.fromDocSnapshot(role);
      notifyListeners();
    });

    _rolesSubscription = _firestore
        .collection("roles")
        .orderBy("level")
        .snapshots()
        .listen((roles) {
      _roles =
          roles.docs.map((role) => RoleModel.fromDocSnapshot(role)).toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _roleSubscription?.cancel();
    _rolesSubscription?.cancel();
    super.dispose();
  }
}
