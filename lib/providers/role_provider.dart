import 'dart:async';

import 'package:csi_door_logs/models/user_model.dart';
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

  RoleProvider({UserModel? user, String? roomId, bool isRoot = false}) {
    setData(user: user, roomId: roomId, isRoot: isRoot);
  }

  void setData({UserModel? user, String? roomId, bool isRoot = false}) {
    if (!isRoot && user != null && roomId != null && roomId.isNotEmpty) {
      _initializeSubscriptions(user, roomId, isRoot);
    }
  }

  Future<void> _initializeSubscriptions(
    UserModel user,
    String roomId,
    bool isRoot,
  ) async {
    final room = (await _firestore
        .collection("user_roles")
        .doc(user.key)
        .collection("room_roles")
        .doc(roomId)
        .get());

    if (room.exists) {
      final roleRef = room["roleId"] as DocumentReference<Map<String, dynamic>>;

      _roleSubscription = roleRef.snapshots().listen((role) {
        _userRole = RoleModel.fromDocSnapshot(role);
        user.setRole = _userRole;

        notifyListeners();
      });
    }

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
