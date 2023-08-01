import 'dart:async';

import 'package:csi_door_logs/models/user_model.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:csi_door_logs/models/request.dart';

class RequestsProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<Request> _userRequests = [];
  List<Request> _roomRequests = [];

  List<Request> get userRequests => [..._userRequests];
  List<Request> get roomRequests => [..._roomRequests];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _userRequestsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _roomRequestsSub;

  RequestsProvider({UserModel? user, String? roomId, bool isRoot = false}) {
    setData(user: user, roomId: roomId, isRoot: isRoot);
  }

  void setData({UserModel? user, String? roomId, bool isRoot = false}) {
    if (user != null && roomId != null) {
      _initializeSubscriptions(user, roomId, isRoot);
    }
  }

  Future<void> _initializeSubscriptions(
    UserModel user,
    String roomId,
    bool isRoot,
  ) async {
    final userRef =
        (await _firestore.collection("users").doc(user.key).get()).reference;
    _userRequestsSub = (_firestore
        .collection("requests")
        .where("userId", isEqualTo: userRef)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) {
      _userRequests = snapshot.docs
          .map((request) => Request.fromQueryDocSnapshot(request))
          .toList();
      notifyListeners();
    }));

    if (roomId.isNotEmpty) {
      final roomRef =
          (await _firestore.collection("rooms").doc(roomId).get()).reference;
      final roomRequests = (_firestore
          .collection("requests")
          .where("roomId", isEqualTo: roomRef)
          .orderBy("createdAt", descending: true)
          .snapshots()
          .listen((snapshot) {
        _roomRequests = snapshot.docs
            .map((request) => Request.fromQueryDocSnapshot(request))
            .toList();
        notifyListeners();
      }));
    }
  }

  @override
  void dispose() {
    _userRequestsSub?.cancel();
    _roomRequestsSub?.cancel();

    super.dispose();
  }
}
