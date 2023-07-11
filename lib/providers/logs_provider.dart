import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csi_door_logs/models/models.dart';
import 'package:flutter/material.dart';

class LogsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _logsSubscription;
  List<AccessLog> _logs = [];
  bool _isLoading = false;

  List<AccessLog> get logs => _logs;
  bool get isLoading => _isLoading;

  LogsProvider({String? roomId}) {
    setRoom(roomId: roomId);
  }

  void setRoom({String? roomId}) {
    if (roomId != null) {
      _initializeSubscriptions(roomId);
    } else {
      _logsSubscription?.cancel();
    }
  }

  void _initializeSubscriptions(String roomId) async {
    _isLoading = true;
    notifyListeners();

    final roomRef =
        (await _firestore.collection("rooms").doc(roomId).get()).reference;

    _isLoading = false;
    notifyListeners();

    _logsSubscription = _firestore
        .collection("logs")
        .where("room", isEqualTo: roomRef)
        .orderBy("timestamp", descending: true)
        .limit(20)
        .snapshots()
        .listen((logs) {
      _logs =
          logs.docs.map((log) => AccessLog.fromQueryDocSnapshot(log)).toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _logsSubscription?.cancel();
    super.dispose();
  }
}
