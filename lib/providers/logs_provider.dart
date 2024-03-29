import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csi_door_logs/models/models.dart';
import 'package:flutter/material.dart';

class LogsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<AccessLog> _logs = [];
  List<AccessLog> _currentDayLogs = [];

  StreamSubscription? _logsSub;
  StreamSubscription? _currentDayLogsSub;

  List<AccessLog> get logs => _logs;
  List<AccessLog> get currentDayLogs => _currentDayLogs;

  LogsProvider({String? roomId}) {
    setRoom(roomId: roomId);
  }

  void setRoom({String? roomId}) {
    _logsSub?.cancel();
    _currentDayLogsSub?.cancel();

    if (roomId != null && roomId.isNotEmpty) {
      _initSubs(roomId);
    } else {
      _logsSub?.cancel();
      _currentDayLogsSub?.cancel();
    }
  }

  void _initSubs(String roomId) async {
    final now = DateTime.now();

    _logsSub = _firestore
        .collection("logs")
        .where("room", isEqualTo: roomId)
        .orderBy("timestamp", descending: true)
        .limit(20)
        .snapshots()
        .listen((logs) {
      final transformedLogs =
          logs.docs.map((log) => AccessLog.fromQueryDocSnapshot(log)).toList();

      if (transformedLogs.any((log) => log.room != roomId)) {
        return;
      }

      _logs = transformedLogs;
      notifyListeners();
    });

    _currentDayLogsSub = _firestore
        .collection("logs")
        .where("timestamp",
            isGreaterThanOrEqualTo: Timestamp.fromDate(
              DateTime(now.year, now.month, now.day),
            ))
        .where("room", isEqualTo: roomId)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((logs) {
      final transformedLogs =
          logs.docs.map((log) => AccessLog.fromQueryDocSnapshot(log)).toList();

      if (transformedLogs.any((log) => log.room != roomId)) {
        return;
      }

      _currentDayLogs = transformedLogs;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _logsSub?.cancel();
    _currentDayLogsSub?.cancel();
    super.dispose();
  }
}
