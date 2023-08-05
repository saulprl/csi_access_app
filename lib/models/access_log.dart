import "package:cloud_firestore/cloud_firestore.dart";

import "package:csi_door_logs/models/attempt.dart";

class AccessLog {
  final String key;
  final String? user;
  final Timestamp timestamp;
  final String room;
  final bool accessed;
  final bool bluetooth;
  final Attempt? attempt;

  AccessLog({
    required this.key,
    required this.user,
    required this.timestamp,
    required this.room,
    required this.accessed,
    required this.bluetooth,
    required this.attempt,
  });

  factory AccessLog.fromDocSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() as Map<String, dynamic>;
    return AccessLog(
      key: snapshot.id,
      user: data['user'],
      room: data['room'],
      timestamp: data['timestamp'] as Timestamp,
      attempt: Attempt(
        csiId: data["attemptData"]?["csiId"],
        passcode: data["attemptData"]?["passcode"],
      ),
      accessed: data['accessed'] as bool,
      bluetooth: data['bluetooth'] as bool,
    );
  }

  factory AccessLog.fromQueryDocSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return AccessLog(
      key: snapshot.id,
      user: data['user'],
      room: data['room'],
      timestamp: data['timestamp'] as Timestamp,
      attempt: Attempt(
        csiId: data["attemptData"]?["csiId"],
        passcode: data["attemptData"]?["passcode"],
      ),
      accessed: data['accessed'] as bool,
      bluetooth: data['bluetooth'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    Map<String, dynamic> data = <String, dynamic>{};

    data["user"] = user;
    data["room"] = room;
    data["accessed"] = accessed;
    data["bluetooth"] = bluetooth;
    data["timestamp"] = timestamp;
    data["attemptData"] = attempt != null ? attempt!.toJson() : null;

    json[key] = data;

    return json;
  }
}
