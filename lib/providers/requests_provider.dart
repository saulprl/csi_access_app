import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:csi_door_logs/models/request.dart';

class RequestsProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<Request> _userRequests = [];
  List<Request> _roomRequests = [];

  List<Request> get userRequests => [..._userRequests];
  List<Request> get roomRequests => [..._roomRequests];

  RequestsProvider({String? userId, String? roomId, bool isRoot = false}) {
    setData(userId: userId, roomId: roomId, isRoot: isRoot);
  }

  void setData({String? userId, String? roomId, bool isRoot = false}) {
    if (!isRoot && userId != null && roomId != null) {
      _initializeSubscriptions(userId, roomId, isRoot);
    }
  }

  Future<void> _initializeSubscriptions(
    String userId,
    String roomId,
    bool isRoot,
  ) async {
    final userRef =
        (await _firestore.collection("users").doc(userId).get()).reference;
    final userRequests = (await _firestore
            .collection("requests")
            .where("userId", isEqualTo: userRef)
            .orderBy("createdAt", descending: true)
            .get())
        .docs;

    _userRequests = userRequests
        .map((request) => Request.fromQueryDocSnapshot(request))
        .toList();

    if (roomId.isNotEmpty) {
      final roomRef =
          (await _firestore.collection("rooms").doc(roomId).get()).reference;
      final roomRequests = (await _firestore
              .collection("requests")
              .where("roomId", isEqualTo: roomRef)
              .orderBy("createdAt", descending: true)
              .get())
          .docs;

      _roomRequests = roomRequests
          .map((request) => Request.fromQueryDocSnapshot(request))
          .toList();
    }

    notifyListeners();
  }
}
