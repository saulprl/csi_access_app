import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_database/firebase_database.dart";

import "package:csi_door_logs/models/attempt.dart";

class AccessLog {
  late String key;
  late DocumentReference<Map<String, dynamic>>? user;
  late Timestamp timestamp;
  late DocumentReference<Map<String, dynamic>> room;
  late bool accessed;
  late bool bluetooth;
  late Attempt? attemptData;

  AccessLog({
    required this.key,
    required this.user,
    required this.timestamp,
    required this.room,
    required this.accessed,
    required this.bluetooth,
    required this.attemptData,
  });

  AccessLog.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return;

    key = snapshot.id;
    user = data["user"];
    room = data["room"];
    timestamp = data["timestamp"];
    accessed = data["accessed"];
    bluetooth = data["bluetooth"];
    attemptData = data["attemptData"] != null
        ? Attempt(
            csiId: (data["attemptData"] as Map<String, dynamic>)["csiId"],
            passcode: (data["attemptData"] as Map<String, dynamic>)["passcode"],
          )
        : null;
  }

  AccessLog.fromQueryDocSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    key = snapshot.id;
    user = data["user"];
    room = data["room"];
    timestamp = data["timestamp"];
    accessed = data["accessed"];
    bluetooth = data["bluetooth"];
    attemptData = data["attemptData"] != null
        ? Attempt(
            csiId: (data["attemptData"] as Map<String, dynamic>)["csiId"],
            passcode: (data["attemptData"] as Map<String, dynamic>)["passcode"],
          )
        : null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    Map<String, dynamic> data = <String, dynamic>{};

    data["user"] = user;
    data["room"] = room;
    data["accessed"] = accessed;
    data["bluetooth"] = bluetooth;
    data["timestamp"] = timestamp;
    data["attemptData"] = attemptData != null ? attemptData!.toJson() : null;

    json[key] = data;

    return json;
  }
}
