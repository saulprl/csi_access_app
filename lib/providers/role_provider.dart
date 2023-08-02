import 'dart:async';

import 'package:csi_door_logs/models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:csi_door_logs/models/role_model.dart';

class RoleProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;

  final List<String> _subbedTopics = [];

  RoleModel? _userRole;
  List<RoleModel> _roles = [];

  StreamSubscription? _currentRoleSub;
  StreamSubscription? _rolesSub;
  StreamSubscription? _userRolesSub;

  RoleModel? get userRole => _userRole;
  List<RoleModel> get roles => _roles;

  RoleProvider({
    UserModel? user,
    String? roomId,
    bool isRoot = false,
  }) {
    setData(user: user, roomId: roomId, isRoot: isRoot);
  }

  void setData({
    UserModel? user,
    String? roomId,
    bool isRoot = false,
  }) {
    if (user != null && roomId != null && roomId.isNotEmpty) {
      _initializeSubscriptions(user, roomId, isRoot);
    } else {
      _unsubFromAllTopics();
      _currentRoleSub?.cancel();
      _rolesSub?.cancel();
      _userRolesSub?.cancel();
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
      final roleRef = _firestore.collection("roles").doc(room["roleId"]);

      _currentRoleSub = roleRef.snapshots().listen((role) {
        _userRole = RoleModel.fromDocSnapshot(role);
        user.setRole = _userRole;

        notifyListeners();
      });
    }

    _rolesSub = _firestore
        .collection("roles")
        .orderBy("level")
        .snapshots()
        .listen((roles) {
      if (user.role == null && !user.isRootUser) return;

      _roles =
          roles.docs.map((role) => RoleModel.fromDocSnapshot(role)).toList();
      notifyListeners();
    });

    _userRolesSub = _firestore
        .collection("user_roles")
        .doc(user.key)
        .collection("room_roles")
        .snapshots()
        .listen((snapshot) async {
      for (final doc in snapshot.docs) {
        final roleId = _firestore.collection("roles").doc(doc["roleId"]);
        final role = RoleModel.fromDocSnapshot(await roleId.get());

        if (role.canHandleRequests &&
            !_subbedTopics.contains("requests_${doc.id}")) {
          _messaging.subscribeToTopic("requests_${doc.id}");
          _subbedTopics.add("requests_${doc.id}");
        } else if (_subbedTopics.contains("requests_${doc.id}")) {
          _messaging.unsubscribeFromTopic("requests_${doc.id}");
          _subbedTopics.remove("requests_${doc.id}");
        }
      }
    });
  }

  void _unsubFromAllTopics() {
    for (final topic in _subbedTopics) {
      _messaging.unsubscribeFromTopic(topic);
    }

    _subbedTopics.clear();
  }

  @override
  void dispose() {
    _currentRoleSub?.cancel();
    _rolesSub?.cancel();
    _userRolesSub?.cancel();
    _unsubFromAllTopics();

    super.dispose();
  }
}
