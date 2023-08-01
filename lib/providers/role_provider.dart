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

  RoleProvider({String? userId, String? roomId, bool isRoot = false}) {
    setData(userId: userId, roomId: roomId, isRoot: isRoot);
  }

  void setData({String? userId, String? roomId, bool isRoot = false}) {
    if (!isRoot && userId != null && roomId != null && roomId.isNotEmpty) {
      _initializeSubscriptions(userId, roomId, isRoot);
    }
  }

  Future<void> _initializeSubscriptions(
    String userId,
    String roomId,
    bool isRoot,
  ) async {
    final room = (await _firestore
        .collection("user_roles")
        .doc(userId)
        .collection("room_roles")
        .doc(roomId)
        .get());

    if (room.exists) {
      final roleRef = room["roleId"] as DocumentReference<Map<String, dynamic>>;

      _roleSubscription = roleRef.snapshots().listen((role) {
        _userRole = RoleModel.fromDocSnapshot(role);
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
